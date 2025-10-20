import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/group_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';

class AddExpensePage extends StatefulWidget {
  final Group? group;
  final Expense? expense; // Para edição

  const AddExpensePage({Key? key, this.group, this.expense}) : super(key: key);

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedGroupId;
  ExpenseStatus _selectedStatus = ExpenseStatus.pending;
  DateTime _selectedDate = DateTime.now();
  ExpenseType _selectedType = ExpenseType.variable;
  bool _isLoading = false;

  // Categorias predefinidas
  final List<Map<String, String>> _predefinedCategories = [
    {
      'id': 'alimentacao',
      'name': 'Alimentação',
      'color': '#FF6B6B',
      'icon': '🍽️',
    },
    {
      'id': 'transporte',
      'name': 'Transporte',
      'color': '#4ECDC4',
      'icon': '🚗',
    },
    {
      'id': 'moradia',
      'name': 'Moradia',
      'color': '#45B7D1',
      'icon': '🏠',
    },
    {
      'id': 'saude',
      'name': 'Saúde',
      'color': '#96CEB4',
      'icon': '💊',
    },
    {
      'id': 'educacao',
      'name': 'Educação',
      'color': '#FECA57',
      'icon': '📚',
    },
    {
      'id': 'lazer',
      'name': 'Lazer',
      'color': '#FF9FF3',
      'icon': '🎮',
    },
    {
      'id': 'compras',
      'name': 'Compras',
      'color': '#54A0FF',
      'icon': '🛍️',
    },
    {
      'id': 'servicos',
      'name': 'Serviços',
      'color': '#5F27CD',
      'icon': '🔧',
    },
    {
      'id': 'outros',
      'name': 'Outros',
      'color': '#C8D6E5',
      'icon': '📦',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Se tem um grupo específico, usar esse grupo
    if (widget.group != null) {
      _selectedGroupId = widget.group!.id;
    }

    // Se está editando uma despesa, preencher os campos
    if (widget.expense != null) {
      final expense = widget.expense!;
      _nameController.text = expense.name;
      _descriptionController.text = expense.description ?? '';
      _amountController.text = expense.amount.toString();
      _selectedCategoryId = expense.categoryId;
      _selectedGroupId = expense.groupId;
      _selectedStatus = expense.status;
      _selectedType = expense.type;
      _selectedDate = expense.date;
    }

    // Carregar grupos disponíveis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadUserGroups('user_id_placeholder');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? 'Editar Despesa'
            : widget.group != null
                ? 'Nova Despesa - ${widget.group!.name}'
                : 'Nova Despesa'),
        actions: [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nome da despesa
              CustomTextField(
                controller: _nameController,
                label: 'Nome da despesa',
                hintText: 'Ex: Almoço no restaurante',
                prefixIcon: const Icon(Icons.receipt),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da despesa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descrição (opcional)
              CustomTextField(
                controller: _descriptionController,
                label: 'Descrição (opcional)',
                hintText: 'Detalhes sobre a despesa',
                prefixIcon: const Icon(Icons.description),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Valor
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  hintText: '0,00',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor';
                  }
                  final amount = double.tryParse(value.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seletor de Categoria
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _predefinedCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'],
                    child: Row(
                      children: [
                        Text(
                          category['icon']!,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(category['name']!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione uma categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seletor de Grupo com interface melhorada
              Consumer<GroupProvider>(
                builder: (context, groupProvider, child) {
                  if (groupProvider.isLoading) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Carregando grupos...'),
                          ],
                        ),
                      ),
                    );
                  }

                  final groups = groupProvider.groups;
                  final currentUser = context.read<AuthProvider>().currentUser;
                  final availableGroups = [
                    // Adicionar grupo pessoal
                    Group(
                      id: 'personal_${currentUser?.id ?? ''}',
                      name: 'Pessoal',
                      description: 'Despesas pessoais',
                      adminId: currentUser?.id ?? '',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      members: [],
                    ),
                    ...groups,
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.group, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Selecionar Grupo',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...availableGroups
                          .map((group) => _buildGroupSelectionCard(group)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Seletor de Status
              DropdownButtonFormField<ExpenseStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                items: ExpenseStatus.values.map((status) {
                  return DropdownMenuItem<ExpenseStatus>(
                    value: status,
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(status),
                            color: _getStatusColor(status)),
                        const SizedBox(width: 8),
                        Text(_getStatusText(status)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Seletor de Tipo
              DropdownButtonFormField<ExpenseType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.timeline),
                  border: OutlineInputBorder(),
                ),
                items: ExpenseType.values.map((type) {
                  return DropdownMenuItem<ExpenseType>(
                    value: type,
                    child: Text(_getTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Seletor de Data
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 16),
                      Text(
                        'Data: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botão de salvar
              CustomButton(
                text: isEditing ? 'Atualizar Despesa' : 'Criar Despesa',
                onPressed: _saveExpense,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final expenseProvider = context.read<ExpenseProvider>();

      if (authProvider.currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      final amount = double.parse(_amountController.text.replaceAll(',', '.'));

      // Criar participante simples (apenas o usuário atual)
      final participant = ExpenseParticipant(
        userId: authProvider.currentUser!.id,
        amount: amount,
        percentage: 100.0,
        hasPaid: _selectedStatus == ExpenseStatus.paid,
      );

      bool success;
      if (widget.expense != null) {
        // Atualizar apenas o status da despesa existente
        success = await expenseProvider.updateExpenseStatus(
          widget.expense!.id,
          _selectedStatus,
        );
      } else {
        // Criar nova despesa
        success = await expenseProvider.createExpense(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          amount: amount,
          categoryId: _selectedCategoryId!,
          groupId: _selectedGroupId!,
          createdByUserId: authProvider.currentUser!.id,
          participants: [participant],
          type: _selectedType,
          date: _selectedDate,
        );
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.expense != null
                  ? 'Despesa atualizada com sucesso!'
                  : 'Despesa criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar despesa: \$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getStatusText(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.pending:
        return 'Pendente';
      case ExpenseStatus.paid:
        return 'Pago';
    }
  }

  IconData _getStatusIcon(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.pending:
        return Icons.schedule;
      case ExpenseStatus.paid:
        return Icons.check_circle;
    }
  }

  Color _getStatusColor(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.pending:
        return Colors.orange;
      case ExpenseStatus.paid:
        return Colors.green;
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

  Widget _buildGroupSelectionCard(Group group) {
    final isSelected = _selectedGroupId == group.id;
    final isPersonal = group.id.startsWith('personal_');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color:
          isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGroupId = group.id;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPersonal
                      ? Colors.blue.withOpacity(0.2)
                      : Theme.of(context).primaryColor.withOpacity(0.2),
                ),
                child: Icon(
                  isPersonal ? Icons.person : Icons.group,
                  color:
                      isPersonal ? Colors.blue : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color:
                            isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    if (group.description.isNotEmpty)
                      Text(
                        group.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    if (!isPersonal)
                      Text(
                        '${group.members.length} ${group.members.length == 1 ? 'membro' : 'membros'}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
