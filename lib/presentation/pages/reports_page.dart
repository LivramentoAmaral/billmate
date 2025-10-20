import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/group_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final expenseProvider = context.read<ExpenseProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.currentUser != null) {
      expenseProvider.loadMonthlyExpenses(_selectedYear, _selectedMonth);
      expenseProvider.loadUserExpenses(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showMonthYearPicker,
          ),
          IconButton(
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Alternar tema',
          ),
        ],
      ),
      body: Consumer4<ExpenseProvider, CategoryProvider, GroupProvider,
          AuthProvider>(
        builder: (context, expenseProvider, categoryProvider, groupProvider,
            authProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seletor de período
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Período: ${_getMonthName(_selectedMonth)} $_selectedYear',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _showMonthYearPicker,
                            child: const Text('Alterar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resumo geral
                  _buildSummaryCard(expenseProvider),
                  const SizedBox(height: 16),

                  // Gráfico por categoria
                  _buildCategoryChart(expenseProvider, categoryProvider),
                  const SizedBox(height: 16),

                  // Gráfico de tendência mensal
                  _buildTrendChart(expenseProvider),
                  const SizedBox(height: 16),

                  // Top categorias
                  _buildTopCategoriesCard(expenseProvider, categoryProvider),
                  const SizedBox(height: 16),

                  // Despesas recentes
                  _buildRecentExpensesCard(expenseProvider, categoryProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(ExpenseProvider expenseProvider) {
    final totalExpenses = expenseProvider.currentMonthTotal;
    final paidExpenses = expenseProvider.expenses
        .where((e) =>
            e.status == ExpenseStatus.paid &&
            e.date.month == _selectedMonth &&
            e.date.year == _selectedYear)
        .fold(0.0, (sum, e) => sum + e.amount);
    final pendingExpenses = totalExpenses - paidExpenses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo Financeiro',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total',
                    totalExpenses,
                    Icons.account_balance_wallet,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Pago',
                    paidExpenses,
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Pendente',
                    pendingExpenses,
                    Icons.pending,
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

  Widget _buildSummaryItem(
      String label, double value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'R\$ ${value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(
      ExpenseProvider expenseProvider, CategoryProvider categoryProvider) {
    final monthlyExpenses = expenseProvider.expenses
        .where((e) =>
            e.date.month == _selectedMonth && e.date.year == _selectedYear)
        .toList();

    if (monthlyExpenses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma despesa encontrada',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    // Agrupar despesas por categoria
    final categoryTotals = <String, double>{};
    for (final expense in monthlyExpenses) {
      final category = categoryProvider.getCategoryById(expense.categoryId);
      final categoryName = category?.name ?? 'Sem categoria';
      categoryTotals[categoryName] =
          (categoryTotals[categoryName] ?? 0) + expense.amount;
    }

    final sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title:
            '${(entry.value / expenseProvider.currentMonthTotal * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Despesas por Categoria',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...categoryTotals.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(entry.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.key)),
                      Text(
                        'R\$ ${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(ExpenseProvider expenseProvider) {
    // Criar dados para os últimos 6 meses
    final now = DateTime.now();
    final months = <String>[];
    final values = <double>[];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add('${date.month}/${date.year.toString().substring(2)}');

      final monthTotal = expenseProvider.expenses
          .where((e) => e.date.month == date.month && e.date.year == date.year)
          .fold(0.0, (sum, e) => sum + e.amount);
      values.add(monthTotal);
    }

    final spots = values.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendência dos Últimos 6 Meses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= months.length)
                            return const Text('');
                          return Text(months[index]);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('R\$${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategoriesCard(
      ExpenseProvider expenseProvider, CategoryProvider categoryProvider) {
    final monthlyExpenses = expenseProvider.expenses
        .where((e) =>
            e.date.month == _selectedMonth && e.date.year == _selectedYear)
        .toList();

    final categoryTotals = <String, double>{};
    for (final expense in monthlyExpenses) {
      final category = categoryProvider.getCategoryById(expense.categoryId);
      final categoryName = category?.name ?? 'Sem categoria';
      categoryTotals[categoryName] =
          (categoryTotals[categoryName] ?? 0) + expense.amount;
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
              'Top Categorias do Mês',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (sortedCategories.isEmpty)
              const Text('Nenhuma despesa encontrada')
            else
              ...sortedCategories.take(5).map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          'R\$ ${entry.value.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpensesCard(
      ExpenseProvider expenseProvider, CategoryProvider categoryProvider) {
    final recentExpenses = expenseProvider.expenses
        .where((e) =>
            e.date.month == _selectedMonth && e.date.year == _selectedYear)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Despesas Recentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (recentExpenses.isEmpty)
              const Text('Nenhuma despesa encontrada')
            else
              ...recentExpenses.take(5).map((expense) {
                final category =
                    categoryProvider.getCategoryById(expense.categoryId);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            _getCategoryColor(category?.name ?? 'Outros'),
                        child: Text(
                          category?.iconCode ?? '💰',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R\$ ${expense.amount.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: expense.status == ExpenseStatus.paid
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              expense.status == ExpenseStatus.paid
                                  ? 'Pago'
                                  : 'Pendente',
                              style: TextStyle(
                                fontSize: 10,
                                color: expense.status == ExpenseStatus.paid
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

  Color _getCategoryColor(String categoryName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];

    final index = categoryName.hashCode % colors.length;
    return colors[index];
  }

  String _getMonthName(int month) {
    const monthNames = [
      '',
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
    return monthNames[month];
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Período'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<int>(
              value: _selectedMonth,
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value!;
                });
              },
              items: List.generate(
                  12,
                  (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text(_getMonthName(index + 1)),
                      )),
            ),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: _selectedYear,
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
              },
              items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                        value: DateTime.now().year - index,
                        child: Text((DateTime.now().year - index).toString()),
                      )),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadData();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}
