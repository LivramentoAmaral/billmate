import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/group_provider.dart';
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
      final authProvider = context.read<AuthProvider>();
      final groupProvider = context.read<GroupProvider>();

      groupProvider.loadUserGroups(
          authProvider.currentUser?.id ?? 'user_id_placeholder');

      // Pré-selecionar um grupo se nenhum foi selecionado
      if (_selectedGroupId == null) {
        // Selecionar o grupo pessoal por padrão
        _selectedGroupId = 'personal_${authProvider.currentUser?.id ?? ''}';
      }
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? 'Editar Despesa'
            : widget.group != null
                ? 'Nova Despesa - ${widget.group!.name}'
                : 'Nova Despesa'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
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

              // Seletor de Grupo com Bottom Sheet
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

                  // Encontrar o grupo selecionado
                  final selectedGroup = availableGroups.firstWhere(
                    (g) => g.id == _selectedGroupId,
                    orElse: () => availableGroups.first,
                  );

                  final colorScheme = Theme.of(context).colorScheme;
                  final isPersonal = selectedGroup.id.startsWith('personal_');

                  return GestureDetector(
                    onTap: () => _showGroupSelectionBottomSheet(
                      context,
                      availableGroups,
                    ),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary.withAlpha(51),
                                    colorScheme.primary.withAlpha(26),
                                  ],
                                ),
                              ),
                              child: Icon(
                                isPersonal ? Icons.person : Icons.group,
                                color: colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Grupo da Despesa',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withAlpha(128),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedGroup.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedGroup.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          colorScheme.onSurface.withAlpha(102),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.expand_more,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Seletor de Status com Cards
              Text(
                'Status da Despesa',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: ExpenseStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;
                  final statusColor = _getStatusColor(status, context);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStatus = status;
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        elevation: isSelected ? 8 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                isSelected ? statusColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? statusColor.withAlpha(26)
                                : Colors.grey[100],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                color: statusColor,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: statusColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                child: Builder(
                  builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
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
                    );
                  },
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

    // Validar se um grupo foi selecionado
    if (_selectedGroupId == null || _selectedGroupId!.isEmpty) {
      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor, selecione um grupo para a despesa'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
      return;
    }

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
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.expense != null
                  ? 'Despesa atualizada com sucesso!'
                  : 'Despesa criada com sucesso!'),
              backgroundColor: colorScheme.primary,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar despesa: \$e'),
            backgroundColor: colorScheme.error,
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

  Color _getStatusColor(ExpenseStatus status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case ExpenseStatus.pending:
        return colorScheme.error;
      case ExpenseStatus.paid:
        return colorScheme.secondary;
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

  void _showGroupSelectionBottomSheet(
      BuildContext context, List<Group> groups) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header com título
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withAlpha(51),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.groups, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecionar Grupo',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Escolha o grupo para esta despesa',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Lista de grupos
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final isSelected = _selectedGroupId == group.id;
                  final isPersonal = group.id.startsWith('personal_');

                  return ListTile(
                    onTap: () {
                      setState(() {
                        _selectedGroupId = group.id;
                      });
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                    },
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPersonal
                            ? colorScheme.secondary.withAlpha(51)
                            : colorScheme.primary.withAlpha(51),
                      ),
                      child: Icon(
                        isPersonal ? Icons.person : Icons.group,
                        color: isPersonal
                            ? colorScheme.secondary
                            : colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      group.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isSelected
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : null,
                    selected: isSelected,
                    selectedTileColor: colorScheme.primary.withAlpha(26),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
