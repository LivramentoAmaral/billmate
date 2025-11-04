import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/expense.dart';
import '../../core/constants/app_constants.dart';
import 'add_expense_page.dart';
import '../../domain/entities/group.dart';

class PersonalExpensesPage extends StatefulWidget {
  const PersonalExpensesPage({Key? key}) : super(key: key);

  @override
  State<PersonalExpensesPage> createState() => _PersonalExpensesPageState();
}

class _PersonalExpensesPageState extends State<PersonalExpensesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filtros
  ExpenseStatus? _selectedStatus;
  String? _selectedCategoryId;
  String? _selectedGroupId; // Novo: filtro de grupo
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;

  // Ordenação
  String _sortBy = 'date'; // date, amount, name
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserExpenses();
    });
  }

  void _loadUserExpenses() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      context
          .read<ExpenseProvider>()
          .loadUserExpenses(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    var filtered = expenses.where((expense) {
      // Filtrar por grupo selecionado, ou todas se nenhum selecionado
      if (_selectedGroupId != null && expense.groupId != _selectedGroupId) {
        return false;
      }
      // Se nenhum grupo selecionado, mostrar todas as despesas do usuário (pessoais + grupos)
      // Filtro por status
      if (_selectedStatus != null && expense.status != _selectedStatus) {
        return false;
      }

      // Filtro por categoria
      if (_selectedCategoryId != null &&
          expense.categoryId != _selectedCategoryId) {
        return false;
      }

      // Filtro por data
      if (_startDate != null && expense.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && expense.date.isAfter(_endDate!)) {
        return false;
      }

      // Filtro por valor
      if (_minAmount != null && expense.amount < _minAmount!) {
        return false;
      }
      if (_maxAmount != null && expense.amount > _maxAmount!) {
        return false;
      }

      return true;
    }).toList();

    // Ordenação
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
      }
      return _ascending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Despesas'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onSecondary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadUserExpenses,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtros',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(153),
          splashFactory: InkRipple.splashFactory,
          enableFeedback: true,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Estatísticas'),
            Tab(icon: Icon(Icons.list_alt), text: 'Lista'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Gráficos'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Seletor de Grupo
          _buildGroupSelector(),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatisticsTab(),
                _buildListTab(),
                _buildChartsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPersonalExpense,
        icon: const Icon(Icons.add),
        label: const Text('Nova Despesa'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredExpenses =
            _getFilteredExpenses(expenseProvider.userExpenses);

        if (filteredExpenses.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterChips(filteredExpenses),
              const SizedBox(height: 16),
              _buildSummaryCards(filteredExpenses),
              const SizedBox(height: 16),
              _buildStatusBreakdown(filteredExpenses),
              const SizedBox(height: 16),
              _buildCategoryBreakdown(filteredExpenses),
              const SizedBox(height: 16),
              _buildMonthlyTrend(filteredExpenses),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredExpenses =
            _getFilteredExpenses(expenseProvider.userExpenses);

        if (filteredExpenses.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildSortingOptions(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  return _buildExpenseCard(filteredExpenses[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredExpenses =
            _getFilteredExpenses(expenseProvider.userExpenses);

        if (filteredExpenses.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatusPieChart(filteredExpenses),
              const SizedBox(height: 24),
              _buildCategoryPieChart(filteredExpenses),
              const SizedBox(height: 24),
              _buildMonthlyBarChart(filteredExpenses),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma despesa encontrada',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione suas primeiras despesas pessoais',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addPersonalExpense,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Despesa'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(List<Expense> expenses) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_selectedStatus != null)
          Chip(
            label: Text('Status: ${_getStatusText(_selectedStatus!)}'),
            onDeleted: () => setState(() => _selectedStatus = null),
            deleteIcon: const Icon(Icons.close, size: 18),
          ),
        if (_selectedCategoryId != null)
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              final category =
                  categoryProvider.getCategoryById(_selectedCategoryId!);
              return Chip(
                label: Text('Categoria: ${category?.name ?? 'Desconhecida'}'),
                onDeleted: () => setState(() => _selectedCategoryId = null),
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            },
          ),
        if (_startDate != null || _endDate != null)
          Chip(
            label: Text('Período: ${_getDateRangeText()}'),
            onDeleted: () => setState(() {
              _startDate = null;
              _endDate = null;
            }),
            deleteIcon: const Icon(Icons.close, size: 18),
          ),
        if (_minAmount != null || _maxAmount != null)
          Chip(
            label: Text('Valor: ${_getAmountRangeText()}'),
            onDeleted: () => setState(() {
              _minAmount = null;
              _maxAmount = null;
            }),
            deleteIcon: const Icon(Icons.close, size: 18),
          ),
        Text(
          '${expenses.length} despesa${expenses.length != 1 ? 's' : ''} encontrada${expenses.length != 1 ? 's' : ''}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(List<Expense> expenses) {
    final totalAmount =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final paidAmount = expenses
        .where((e) => e.status == ExpenseStatus.paid)
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final pendingAmount = totalAmount - paidAmount;
    final averageAmount =
        expenses.isEmpty ? 0.0 : totalAmount / expenses.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.9,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Gasto',
          'R\$ ${totalAmount.toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          Colors.blue,
        ),
        _buildStatCard(
          'Valor Pago',
          'R\$ ${paidAmount.toStringAsFixed(2)}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Valor Pendente',
          'R\$ ${pendingAmount.toStringAsFixed(2)}',
          Icons.schedule,
          Colors.orange,
        ),
        _buildStatCard(
          'Média por Despesa',
          'R\$ ${averageAmount.toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildGroupSelector() {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<ExpenseProvider, AuthProvider>(
      builder: (context, expenseProvider, authProvider, child) {
        final allExpenses = expenseProvider.userExpenses;

        // Agrupar despesas por grupo
        final groupsMap = <String, (String name, int count, double total)>{};

        for (final expense in allExpenses) {
          if (!groupsMap.containsKey(expense.groupId)) {
            groupsMap[expense.groupId] = (
              expense.groupId.startsWith('personal_')
                  ? 'Pessoal'
                  : expense.groupId,
              0,
              0.0,
            );
          }
          final current = groupsMap[expense.groupId]!;
          groupsMap[expense.groupId] = (
            current.$1,
            current.$2 + 1,
            current.$3 + expense.amount,
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                // Botão "Todos"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGroupId = null;
                      });
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedGroupId == null
                            ? colorScheme.primary
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.all_inclusive,
                            size: 18,
                            color: _selectedGroupId == null
                                ? Colors.white
                                : colorScheme.onSurface,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Todos',
                            style: TextStyle(
                              color: _selectedGroupId == null
                                  ? Colors.white
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Grupos
                ...groupsMap.entries.map((entry) {
                  final groupId = entry.key;
                  final (name, count, total) = entry.value;
                  final isSelected = _selectedGroupId == groupId;
                  final isPersonal = groupId.startsWith('personal_');

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGroupId = groupId;
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPersonal ? Icons.person : Icons.group,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.onSurface,
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '$count despesa${count != 1 ? 's' : ''}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white.withAlpha(204)
                                        : colorScheme.onSurface.withAlpha(128),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withAlpha(26),
              color.withAlpha(13),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: expense.status == ExpenseStatus.paid
              ? Colors.green.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
          child: Icon(
            expense.status == ExpenseStatus.paid
                ? Icons.check_circle
                : Icons.schedule,
            color: expense.status == ExpenseStatus.paid
                ? Colors.green
                : Colors.orange,
          ),
        ),
        title: Text(
          expense.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expense.description != null)
              Text(
                expense.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(expense.date),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: expense.status == ExpenseStatus.paid
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(expense.status),
                      style: TextStyle(
                        color: expense.status == ExpenseStatus.paid
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'R\$ ${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleExpenseAction(value, expense),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: expense.status == ExpenseStatus.paid
                      ? 'mark_pending'
                      : 'mark_paid',
                  child: Row(
                    children: [
                      Icon(
                        expense.status == ExpenseStatus.paid
                            ? Icons.schedule
                            : Icons.check_circle,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          expense.status == ExpenseStatus.paid
                              ? 'Marcar como Pendente'
                              : 'Marcar como Pago',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Editar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Detalhes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortingOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          const Text('Ordenar por:'),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'date', child: Text('Data')),
              DropdownMenuItem(value: 'amount', child: Text('Valor')),
              DropdownMenuItem(value: 'name', child: Text('Nome')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _sortBy = value);
              }
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => setState(() => _ascending = !_ascending),
            icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: _ascending ? 'Crescente' : 'Decrescente',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(List<Expense> expenses) {
    final paidCount =
        expenses.where((e) => e.status == ExpenseStatus.paid).length;
    final pendingCount = expenses.length - paidCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status das Despesas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressIndicator(
                    'Pagas',
                    paidCount,
                    expenses.length,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressIndicator(
                    'Pendentes',
                    pendingCount,
                    expenses.length,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
      String label, int count, int total, Color color) {
    final percentage = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(List<Expense> expenses) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categoryTotals = <String, double>{};

        for (final expense in expenses) {
          categoryTotals[expense.categoryId] =
              (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
        }

        final sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gastos por Categoria',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ...sortedCategories.take(5).map((entry) {
                  final category = categoryProvider.getCategoryById(entry.key);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color:
                                _getCategoryColor(category?.name ?? 'Outros'),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                              category?.name ?? 'Categoria não encontrada'),
                        ),
                        Text(
                          'R\$ ${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthlyTrend(List<Expense> expenses) {
    final monthlyTotals = <String, double>{};

    for (final expense in expenses) {
      final monthKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }

    final sortedMonths = monthlyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendência Mensal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...sortedMonths.reversed.take(6).toList().reversed.map((entry) {
              final parts = entry.key.split('-');
              final month = int.parse(parts[1]);
              final year = int.parse(parts[0]);
              final monthName = _getMonthName(month);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$monthName $year'),
                    Text(
                      'R\$ ${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPieChart(List<Expense> expenses) {
    final paidAmount = expenses
        .where((e) => e.status == ExpenseStatus.paid)
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final pendingAmount = expenses
        .where((e) => e.status == ExpenseStatus.pending)
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Distribuição por Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    if (paidAmount > 0)
                      PieChartSectionData(
                        value: paidAmount,
                        title: 'Pago\nR\$ ${paidAmount.toStringAsFixed(2)}',
                        color: Colors.green,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (pendingAmount > 0)
                      PieChartSectionData(
                        value: pendingAmount,
                        title:
                            'Pendente\nR\$ ${pendingAmount.toStringAsFixed(2)}',
                        color: Colors.orange,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(List<Expense> expenses) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categoryTotals = <String, double>{};

        for (final expense in expenses) {
          categoryTotals[expense.categoryId] =
              (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
        }

        final sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Distribuição por Categoria',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sortedCategories.take(5).map((entry) {
                        final category =
                            categoryProvider.getCategoryById(entry.key);
                        final color =
                            _getCategoryColor(category?.name ?? 'Outros');

                        return PieChartSectionData(
                          value: entry.value,
                          title:
                              '${category?.name ?? 'Outros'}\nR\$ ${entry.value.toStringAsFixed(2)}',
                          color: color,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthlyBarChart(List<Expense> expenses) {
    final monthlyTotals = <int, double>{};

    for (final expense in expenses) {
      final month = expense.date.month;
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + expense.amount;
    }

    final maxAmount = monthlyTotals.values.isEmpty
        ? 0.0
        : monthlyTotals.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Gastos por Mês',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxAmount * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            _getMonthAbbr(value.toInt()),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(12, (index) {
                    final month = index + 1;
                    final amount = monthlyTotals[month] ?? 0;

                    return BarChartGroupData(
                      x: month,
                      barRods: [
                        BarChartRodData(
                          toY: amount,
                          color: Theme.of(context).colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedStatus: _selectedStatus,
        selectedCategoryId: _selectedCategoryId,
        startDate: _startDate,
        endDate: _endDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        onFiltersChanged:
            (status, categoryId, startDate, endDate, minAmount, maxAmount) {
          setState(() {
            _selectedStatus = status;
            _selectedCategoryId = categoryId;
            _startDate = startDate;
            _endDate = endDate;
            _minAmount = minAmount;
            _maxAmount = maxAmount;
          });
        },
      ),
    );
  }

  void _addPersonalExpense() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    final personalGroup = Group(
      id: 'personal_${authProvider.currentUser!.id}',
      name: 'Pessoal',
      description: 'Despesas pessoais',
      adminId: authProvider.currentUser!.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      members: [],
    );

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpensePage(group: personalGroup),
      ),
    );

    // Verificar se o widget ainda está montado após a navegação
    if (mounted && result == true) {
      _loadUserExpenses();
    }
  }

  void _handleExpenseAction(String action, Expense expense) async {
    final expenseProvider = context.read<ExpenseProvider>();

    switch (action) {
      case 'mark_paid':
        await expenseProvider.updateExpenseStatus(
            expense.id, ExpenseStatus.paid);
        break;
      case 'mark_pending':
        await expenseProvider.updateExpenseStatus(
            expense.id, ExpenseStatus.pending);
        break;
      case 'edit':
        // Extrair context-dependent values ANTES da operação assíncrona
        final authProvider = context.read<AuthProvider>();
        if (authProvider.currentUser == null) return;

        final personalGroup = Group(
          id: 'personal_${authProvider.currentUser!.id}',
          name: 'Pessoal',
          description: 'Despesas pessoais',
          adminId: authProvider.currentUser!.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          members: [],
        );

        // Usar context.read<NavigatorState>() não funciona bem
        // Então apenas garantir que verificamos mounted após o await
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddExpensePage(
              group: personalGroup,
              expense: expense,
            ),
          ),
        );

        // Verificar se o widget ainda está montado após a navegação
        if (mounted && result == true) {
          _loadUserExpenses();
        }
        break;
      case 'details':
        _showExpenseDetails(expense);
        break;
    }
  }

  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expense.description != null) ...[
              Text('Descrição:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(expense.description!),
              const SizedBox(height: 12),
            ],
            Text('Valor:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('R\$ ${expense.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            Text('Status:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(_getStatusText(expense.status)),
            const SizedBox(height: 12),
            Text('Data:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(_formatDate(expense.date)),
            const SizedBox(height: 12),
            Text('Tipo:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(_getTypeText(expense.type)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.pending:
        return 'Pendente';
      case ExpenseStatus.paid:
        return 'Pago';
    }
  }

  String _getTypeText(ExpenseType type) {
    switch (type) {
      case ExpenseType.fixed:
        return 'Fixa';
      case ExpenseType.variable:
        return 'Variável';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}';
    } else if (_startDate != null) {
      return 'A partir de ${_formatDate(_startDate!)}';
    } else if (_endDate != null) {
      return 'Até ${_formatDate(_endDate!)}';
    }
    return '';
  }

  String _getAmountRangeText() {
    if (_minAmount != null && _maxAmount != null) {
      return 'R\$ ${_minAmount!.toStringAsFixed(2)} - R\$ ${_maxAmount!.toStringAsFixed(2)}';
    } else if (_minAmount != null) {
      return 'Mín: R\$ ${_minAmount!.toStringAsFixed(2)}';
    } else if (_maxAmount != null) {
      return 'Máx: R\$ ${_maxAmount!.toStringAsFixed(2)}';
    }
    return '';
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return months[month - 1];
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return month >= 1 && month <= 12 ? months[month - 1] : '';
  }

  Color _getCategoryColor(String categoryName) {
    // Cores fixas baseadas no hash do nome da categoria para consistência
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lightGreen,
    ];
    return colors[categoryName.hashCode % colors.length];
  }
}

class _FilterDialog extends StatefulWidget {
  final ExpenseStatus? selectedStatus;
  final String? selectedCategoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final Function(
          ExpenseStatus?, String?, DateTime?, DateTime?, double?, double?)
      onFiltersChanged;

  const _FilterDialog({
    required this.selectedStatus,
    required this.selectedCategoryId,
    required this.startDate,
    required this.endDate,
    required this.minAmount,
    required this.maxAmount,
    required this.onFiltersChanged,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late ExpenseStatus? _status;
  late String? _categoryId;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late double? _minAmount;
  late double? _maxAmount;

  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _categoryId = widget.selectedCategoryId;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _minAmount = widget.minAmount;
    _maxAmount = widget.maxAmount;

    _minAmountController.text = _minAmount?.toStringAsFixed(2) ?? '';
    _maxAmountController.text = _maxAmount?.toStringAsFixed(2) ?? '';
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtros'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtro por Status
            Text('Status:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _status == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _status = null);
                  },
                ),
                FilterChip(
                  label: const Text('Pago'),
                  selected: _status == ExpenseStatus.paid,
                  onSelected: (selected) {
                    setState(
                        () => _status = selected ? ExpenseStatus.paid : null);
                  },
                ),
                FilterChip(
                  label: const Text('Pendente'),
                  selected: _status == ExpenseStatus.pending,
                  onSelected: (selected) {
                    setState(() =>
                        _status = selected ? ExpenseStatus.pending : null);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filtro por Categoria
            Text('Categoria:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                return DropdownButtonFormField<String?>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                    hintText: 'Selecionar categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todas as categorias'),
                    ),
                    ...categoryProvider.categories.map((category) {
                      return DropdownMenuItem<String?>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }),
                  ],
                  onChanged: (value) => setState(() => _categoryId = value),
                );
              },
            ),
            const SizedBox(height: 16),

            // Filtro por Data
            Text('Período:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data inicial',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Selecionar',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data final',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Selecionar',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filtro por Valor
            Text('Faixa de Valor:',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Valor mínimo',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _minAmount = double.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _maxAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Valor máximo',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxAmount = double.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _status = null;
              _categoryId = null;
              _startDate = null;
              _endDate = null;
              _minAmount = null;
              _maxAmount = null;
              _minAmountController.clear();
              _maxAmountController.clear();
            });
          },
          child: const Text('Limpar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onFiltersChanged(
              _status,
              _categoryId,
              _startDate,
              _endDate,
              _minAmount,
              _maxAmount,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }
}
