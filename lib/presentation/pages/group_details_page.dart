import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/expense.dart';
import '../../core/constants/app_constants.dart';
import '../providers/expense_provider.dart';
import 'add_expense_page.dart';
import 'group_members_page.dart';

class GroupDetailsPage extends StatefulWidget {
  final Group group;

  const GroupDetailsPage({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<ExpenseProvider>().loadGroupExpenses(widget.group.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onSecondary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(153),
          splashFactory: InkRipple.splashFactory,
          enableFeedback: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Estatísticas',
            ),
            Tab(
              icon: Icon(Icons.group),
              text: 'Membros',
            ),
            Tab(
              icon: Icon(Icons.qr_code),
              text: 'Convite',
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _addExpense(),
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Despesa',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(),
          _buildMembersTab(),
          _buildInviteTab(),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final groupExpenses = expenseProvider.expenses
            .where((expense) => expense.groupId == widget.group.id)
            .toList();

        if (groupExpenses.isEmpty) {
          final colorScheme = Theme.of(context).colorScheme;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assessment,
                    size: 64, color: colorScheme.onSurface.withAlpha(128)),
                SizedBox(height: 16),
                Text(
                  'Nenhuma despesa encontrada',
                  style: TextStyle(fontSize: 18, color: colorScheme.onSurface),
                ),
                SizedBox(height: 8),
                Text(
                  'Adicione despesas para ver as estatísticas',
                  style: TextStyle(color: colorScheme.onSurface.withAlpha(128)),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _addExpense(),
                  icon: Icon(Icons.add),
                  label: Text('Adicionar Primeira Despesa'),
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _createSampleData(),
                  icon: Icon(Icons.data_object),
                  label: Text('Criar Dados de Exemplo'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(groupExpenses),
              const SizedBox(height: 24),
              _buildExpensesByMemberChart(groupExpenses),
              const SizedBox(height: 24),
              _buildExpensesByStatusChart(groupExpenses),
              const SizedBox(height: 24),
              _buildRecentExpenses(groupExpenses),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards(List<Expense> expenses) {
    final totalExpenses = expenses.length;
    final totalAmount =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final paidAmount = expenses
        .where((expense) => expense.status == ExpenseStatus.paid)
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final pendingAmount = totalAmount - paidAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo Geral',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total de Despesas',
                        totalExpenses.toString(),
                        Icons.receipt_long,
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Valor Total',
                        'R\$ ${totalAmount.toStringAsFixed(2)}',
                        Icons.attach_money,
                        colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Valor Pago',
                        'R\$ ${paidAmount.toStringAsFixed(2)}',
                        Icons.check_circle,
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Valor Pendente',
                        'R\$ ${pendingAmount.toStringAsFixed(2)}',
                        Icons.schedule,
                        colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withAlpha(128)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpensesByMemberChart(List<Expense> expenses) {
    final memberExpenses = <String, double>{};

    for (final expense in expenses) {
      final member = widget.group.members
          .where((m) => m.userId == expense.createdByUserId)
          .firstOrNull;
      final memberName = member?.userId ?? 'Usuário Desconhecido';
      memberExpenses[memberName] =
          (memberExpenses[memberName] ?? 0) + expense.amount;
    }

    if (memberExpenses.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Despesas por Membro',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  final colors = [
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.tertiary,
                    colorScheme.error,
                    colorScheme.primary.withAlpha(128),
                  ];
                  return PieChart(
                    PieChartData(
                      sections: memberExpenses.entries.map((entry) {
                        final index =
                            memberExpenses.keys.toList().indexOf(entry.key);
                        return PieChartSectionData(
                          value: entry.value,
                          title: 'R\$ ${entry.value.toStringAsFixed(0)}',
                          color: colors[index % colors.length],
                          radius: 60,
                        );
                      }).toList(),
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final colorScheme = Theme.of(context).colorScheme;
                final colors = [
                  colorScheme.primary,
                  colorScheme.secondary,
                  colorScheme.tertiary,
                  colorScheme.error,
                  colorScheme.primary.withAlpha(128),
                ];
                return Column(
                  children: memberExpenses.entries.map((entry) {
                    final index =
                        memberExpenses.keys.toList().indexOf(entry.key);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(entry.key),
                          ),
                          Text(
                            'R\$ ${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesByStatusChart(List<Expense> expenses) {
    final paidExpenses =
        expenses.where((e) => e.status == ExpenseStatus.paid).length;
    final pendingExpenses =
        expenses.where((e) => e.status == ExpenseStatus.pending).length;

    if (paidExpenses == 0 && pendingExpenses == 0) {
      return const SizedBox();
    }

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
            SizedBox(
              height: 200,
              child: Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return PieChart(
                    PieChartData(
                      sections: [
                        if (paidExpenses > 0)
                          PieChartSectionData(
                            value: paidExpenses.toDouble(),
                            title: '$paidExpenses',
                            color: colorScheme.secondary,
                            radius: 60,
                          ),
                        if (pendingExpenses > 0)
                          PieChartSectionData(
                            value: pendingExpenses.toDouble(),
                            title: '$pendingExpenses',
                            color: colorScheme.error,
                            radius: 60,
                          ),
                      ],
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final colorScheme = Theme.of(context).colorScheme;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (paidExpenses > 0)
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Pagas ($paidExpenses)'),
                        ],
                      ),
                    if (pendingExpenses > 0)
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Pendentes ($pendingExpenses)'),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(List<Expense> expenses) {
    final recentExpenses = expenses.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Despesas Recentes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...recentExpenses
                .map((expense) => _buildExpenseListItem(expense))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseListItem(Expense expense) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: expense.status == ExpenseStatus.paid
                ? colorScheme.secondary.withAlpha(51)
                : colorScheme.error.withAlpha(51),
            child: Icon(
              expense.status == ExpenseStatus.paid
                  ? Icons.check_circle
                  : Icons.schedule,
              color: expense.status == ExpenseStatus.paid
                  ? colorScheme.secondary
                  : colorScheme.error,
            ),
          ),
          title: Text(
            expense.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${expense.description ?? ''} • ${_formatDate(expense.date)}',
            style: TextStyle(color: colorScheme.onSurface.withAlpha(128)),
          ),
          trailing: GestureDetector(
            onLongPress: () => _showExpenseStatusMenu(context, expense),
            onTap: () => _toggleExpenseStatus(context, expense),
            child: Tooltip(
              message: 'Toque para alternar status\nPressione para mais opções',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: expense.status == ExpenseStatus.paid
                          ? colorScheme.secondary.withAlpha(26)
                          : colorScheme.error.withAlpha(26),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      expense.status == ExpenseStatus.paid
                          ? 'Pago'
                          : 'Pendente',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: expense.status == ExpenseStatus.paid
                            ? colorScheme.secondary
                            : colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExpenseStatusMenu(BuildContext context, Expense expense) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  expense.status == ExpenseStatus.paid
                      ? Icons.schedule
                      : Icons.check_circle,
                  color: colorScheme.primary,
                ),
                title: Text(
                  expense.status == ExpenseStatus.paid
                      ? 'Marcar como Pendente'
                      : 'Marcar como Pago',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleExpenseStatus(context, expense);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleExpenseStatus(BuildContext context, Expense expense) async {
    final expenseProvider = context.read<ExpenseProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    try {
      final newStatus = expense.status == ExpenseStatus.paid
          ? ExpenseStatus.pending
          : ExpenseStatus.paid;

      final success = await expenseProvider.updateExpenseStatus(
        expense.id,
        newStatus,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == ExpenseStatus.paid
                  ? 'Despesa marcada como Paga'
                  : 'Despesa marcada como Pendente',
            ),
            backgroundColor: colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar status: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildMembersTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final groupExpenses = expenseProvider.expenses
            .where((expense) => expense.groupId == widget.group.id)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Membros do Grupo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => _manageMembers(),
                    icon: const Icon(Icons.settings),
                    label: const Text('Gerenciar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...widget.group.members
                  .map((member) => _buildMemberStatCard(member, groupExpenses))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberStatCard(GroupMember member, List<Expense> groupExpenses) {
    final memberExpenses = groupExpenses
        .where((expense) => expense.createdByUserId == member.userId)
        .toList();

    final totalExpenses = memberExpenses.length;
    final totalAmount =
        memberExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final paidAmount = memberExpenses
        .where((expense) => expense.status == ExpenseStatus.paid)
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primary.withAlpha(51),
                      child: Text(
                        member.userId.length >= 2
                            ? member.userId.substring(0, 2).toUpperCase()
                            : member.userId.toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member
                                .userId, // Em um app real, seria o nome do usuário
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            member.role == UserRole.admin
                                ? 'Administrador'
                                : 'Membro',
                            style: TextStyle(
                              color: member.role == UserRole.admin
                                  ? colorScheme.error
                                  : colorScheme.onSurface.withAlpha(128),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (member.role == UserRole.admin)
                      Icon(Icons.admin_panel_settings,
                          color: colorScheme.error),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Despesas',
                            style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(128),
                                fontSize: 12),
                          ),
                          Text(
                            totalExpenses.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Gasto',
                            style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(128),
                                fontSize: 12),
                          ),
                          Text(
                            'R\$ ${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pago',
                            style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(128),
                                fontSize: 12),
                          ),
                          Text(
                            'R\$ ${paidAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInviteTab() {
    final inviteLink = _generateInviteLink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header moderno
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withAlpha(26),
                      colorScheme.primary.withAlpha(26),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withAlpha(77),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.group_add,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Convide Novos Membros',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Compartilhe o QR Code ou link para adicionar membros ao grupo "${widget.group.name}"',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // QR Code Card com animação
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.grey[50]!,
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(26),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: inviteLink,
                                  version: QrVersions.auto,
                                  size: MediaQuery.of(context).size.width > 600
                                      ? 250.0
                                      : MediaQuery.of(context).size.width * 0.5,
                                  backgroundColor: Colors.white,
                                  foregroundColor: colorScheme.primary,
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withAlpha(26),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.qr_code_scanner,
                                          color: colorScheme.primary,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'QR Code do Convite',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Escaneie para entrar no grupo',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Link Card melhorado
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.link,
                              color: colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Link de Convite',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  fontSize: 17,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                inviteLink,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withAlpha(77),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () => _copyInviteLink(inviteLink),
                                icon: const Icon(Icons.copy,
                                    color: Colors.white, size: 20),
                                tooltip: 'Copiar Link de Convite',
                                padding: const EdgeInsets.all(10),
                                constraints: const BoxConstraints(
                                    minWidth: 44, minHeight: 44),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botões de ação modernos
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withAlpha(77),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _shareInviteLink(inviteLink),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: const Text(
                          'Compartilhar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: colorScheme.primary, width: 2),
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () => _showInviteInstructions(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(Icons.help_outline,
                            color: colorScheme.primary),
                        label: Text(
                          'Como Usar',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Informações adicionais
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dica',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Os novos membros serão automaticamente adicionados ao grupo quando usarem o link ou QR Code.',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _generateInviteLink() {
    // Em um app real, isso seria um deep link verdadeiro
    return 'https://billmate.app/join/${widget.group.id}?invite=${DateTime.now().millisecondsSinceEpoch}';
  }

  void _copyInviteLink(String link) {
    final colorScheme = Theme.of(context).colorScheme;
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Link copiado para a área de transferência',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareInviteLink(String link) {
    Share.share(
      'Junte-se ao meu grupo "${widget.group.name}" no Billmate!\n\n$link',
      subject: 'Convite para o grupo ${widget.group.name}',
    );
  }

  void _showInviteInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como Usar o Convite'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '• Compartilhe o QR Code ou link com as pessoas que deseja adicionar'),
            SizedBox(height: 8),
            Text('• Elas devem ter o app Billmate instalado'),
            SizedBox(height: 8),
            Text(
                '• Ao escanear o QR Code ou clicar no link, serão automaticamente adicionadas ao grupo'),
            SizedBox(height: 8),
            Text('• Apenas administradores podem gerar convites'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  void _addExpense() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddExpensePage(
          group: widget.group,
        ),
      ),
    )
        .then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  void _manageMembers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupMembersPage(group: widget.group),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _createSampleData() async {
    final expenseProvider = context.read<ExpenseProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Criando dados de exemplo...'),
          ],
        ),
      ),
    );

    try {
      // Criar algumas despesas de exemplo
      final sampleExpenses = [
        {
          'name': 'Supermercado',
          'description': 'Compras mensais',
          'amount': 250.00,
          'categoryId': 'alimentacao',
        },
        {
          'name': 'Internet',
          'description': 'Conta mensal',
          'amount': 89.90,
          'categoryId': 'moradia',
        },
        {
          'name': 'Cinema',
          'description': 'Filme em família',
          'amount': 60.00,
          'categoryId': 'lazer',
        },
        {
          'name': 'Farmácia',
          'description': 'Medicamentos',
          'amount': 45.50,
          'categoryId': 'saude',
        },
        {
          'name': 'Uber',
          'description': 'Transporte',
          'amount': 25.00,
          'categoryId': 'transporte',
        },
      ];

      for (int i = 0; i < sampleExpenses.length; i++) {
        final expense = sampleExpenses[i];
        await expenseProvider.createExpense(
          name: expense['name'] as String,
          description: expense['description'] as String,
          amount: expense['amount'] as double,
          categoryId: expense['categoryId'] as String,
          groupId: widget.group.id,
          createdByUserId: 'sample_user_$i',
          participants: [
            ExpenseParticipant(
              userId: 'sample_user_$i',
              amount: expense['amount'] as double,
              percentage: 100.0,
              hasPaid: i % 2 == 0, // Algumas pagas, outras pendentes
            ),
          ],
          type: ExpenseType.variable,
          date: DateTime.now().subtract(Duration(days: i * 5)),
        );
      }

      // Recarregar dados
      _loadData();

      if (mounted) {
        Navigator.of(context).pop(); // Fechar dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados de exemplo criados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Fechar dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
