import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import 'login_page.dart';
import 'add_expense_page.dart';
import 'groups_page.dart';
import 'reports_page.dart';
import 'personal_expenses_page.dart';
import '../../core/constants/app_constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardTab(),
    ExpensesTab(),
    GroupsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withAlpha(128),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Despesas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Tabs temporárias - serão implementadas posteriormente
class DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Consumer2<AuthProvider, ExpenseProvider>(
        builder: (context, authProvider, expenseProvider, child) {
          final user = authProvider.currentUser;

          // Carregar despesas do usuário
          if (user != null &&
              expenseProvider.userExpenses.isEmpty &&
              !expenseProvider.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              expenseProvider.loadUserExpenses(user.id);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saudação
                Text(
                  'Olá, ${user?.name.split(' ').first ?? 'Usuário'}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bem-vindo ao Billmate',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withAlpha(128),
                  ),
                ),
                const SizedBox(height: 32),

                // Cards de resumo
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Despesas do Mês',
                        'R\$ ${expenseProvider.currentMonthTotal.toStringAsFixed(2)}',
                        Icons.receipt_long,
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Despesas',
                        '${expenseProvider.userExpenses.length}',
                        Icons.list_alt,
                        colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Pendências',
                        '${expenseProvider.pendingExpensesCount}',
                        Icons.pending_actions,
                        Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Status',
                        expenseProvider.isLoading ? 'Carregando...' : 'Ativo',
                        Icons.check_circle,
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Seção de ações rápidas
                const Text(
                  'Ações Rápidas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildQuickActionCard(
                  'Adicionar Despesa',
                  'Registre uma nova despesa rapidamente',
                  Icons.add_circle,
                  Theme.of(context).colorScheme.primary,
                  () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => AddExpensePage()),
                    );

                    // Se a despesa foi criada com sucesso, recarregar dados
                    if (result == true && context.mounted) {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      final expenseProvider =
                          Provider.of<ExpenseProvider>(context, listen: false);

                      if (authProvider.currentUser != null) {
                        expenseProvider
                            .loadUserExpenses(authProvider.currentUser!.id);
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),

                _buildQuickActionCard(
                  'Despesas Pessoais',
                  'Gerencie suas despesas pessoais com estatísticas',
                  Icons.person_outline,
                  Theme.of(context).colorScheme.secondary,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PersonalExpensesPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _buildQuickActionCard(
                  'Criar Grupo',
                  'Crie um novo grupo para compartilhar despesas',
                  Icons.group_add,
                  Theme.of(context).colorScheme.secondary,
                  () {
                    // TODO: Implementar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Em desenvolvimento')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withAlpha(128),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(26),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class ExpensesTab extends StatefulWidget {
  @override
  _ExpensesTabState createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  @override
  void initState() {
    super.initState();
    // Carregar despesas quando a aba for inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        expenseProvider.loadUserExpenses(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PersonalExpensesPage(),
                ),
              );
            },
            icon: const Icon(Icons.analytics),
            tooltip: 'Despesas Pessoais',
          ),
          IconButton(
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final expenseProvider =
                  Provider.of<ExpenseProvider>(context, listen: false);

              if (authProvider.currentUser != null) {
                expenseProvider.loadUserExpenses(authProvider.currentUser!.id);
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final colorScheme = Theme.of(context).colorScheme;

          if (expenseProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (expenseProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar despesas',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    expenseProvider.error!,
                    style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(128),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      expenseProvider.clearError();
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      if (authProvider.currentUser != null) {
                        expenseProvider
                            .loadUserExpenses(authProvider.currentUser!.id);
                      }
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (expenseProvider.userExpenses.isEmpty) {
            return Builder(
              builder: (context) {
                final colorScheme = Theme.of(context).colorScheme;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: colorScheme.onSurface.withAlpha(128),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma despesa encontrada',
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.onSurface.withAlpha(128),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicione sua primeira despesa para começar',
                        style: TextStyle(
                            color: colorScheme.onSurface.withAlpha(128)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(builder: (_) => AddExpensePage()),
                          );

                          // Se a despesa foi criada com sucesso, recarregar a lista
                          if (result == true && context.mounted) {
                            final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false);
                            final expenseProvider =
                                Provider.of<ExpenseProvider>(context,
                                    listen: false);

                            if (authProvider.currentUser != null) {
                              expenseProvider.loadUserExpenses(
                                  authProvider.currentUser!.id);
                            }
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Despesa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          // Lista de despesas
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenseProvider.userExpenses.length,
            itemBuilder: (context, index) {
              final expense = expenseProvider.userExpenses[index];
              return _buildExpenseCard(expense, context);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => AddExpensePage()),
          );

          // Se a despesa foi criada com sucesso, recarregar a lista
          if (result == true && context.mounted) {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final expenseProvider =
                Provider.of<ExpenseProvider>(context, listen: false);

            if (authProvider.currentUser != null) {
              expenseProvider.loadUserExpenses(authProvider.currentUser!.id);
            }
          }
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpenseCard(expense, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: expense.status == ExpenseStatus.paid
              ? colorScheme.secondary.withAlpha(26)
              : colorScheme.error.withAlpha(26),
          child: Icon(
            expense.status == ExpenseStatus.paid
                ? Icons.check_circle
                : Icons.pending,
            color: expense.status == ExpenseStatus.paid
                ? colorScheme.secondary
                : colorScheme.error,
          ),
        ),
        title: Text(
          expense.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expense.description?.isNotEmpty == true)
              Text(expense.description!),
            const SizedBox(height: 4),
            Text(
              '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withAlpha(128),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              expense.status == ExpenseStatus.paid ? 'Pago' : 'Pendente',
              style: TextStyle(
                fontSize: 12,
                color: expense.status == ExpenseStatus.paid
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        onTap: () => _showExpenseOptions(context, expense),
      ),
    );
  }

  void _showExpenseOptions(BuildContext context, expense) {
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
              ListTile(
                leading: Icon(Icons.edit, color: colorScheme.primary),
                title: const Text('Editar despesa'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpensePage(expense: expense),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleExpenseStatus(BuildContext context, expense) async {
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
}

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const GroupsPage();
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Avatar
                Builder(
                  builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Nome do usuário
                Text(
                  user?.name ?? 'Usuário',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Email do usuário
                Builder(
                  builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withAlpha(128),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Informações do usuário
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow('Membro desde',
                            '${user?.createdAt.day.toString().padLeft(2, '0')}/${user?.createdAt.month.toString().padLeft(2, '0')}/${user?.createdAt.year}'),
                        const Divider(),
                        _buildInfoRow('Status', 'Ativo'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botão de Relatórios
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.analytics),
                    title: const Text('Relatórios'),
                    subtitle: const Text('Visualize suas estatísticas'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReportsPage()),
                      );
                    },
                  ),
                ),

                const Spacer(),

                // Botão de logout
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final colorScheme = Theme.of(context).colorScheme;
                      return ElevatedButton.icon(
                        onPressed: () async {
                          await authProvider.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => LoginPage()),
                            );
                          }
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Sair'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withAlpha(128),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
