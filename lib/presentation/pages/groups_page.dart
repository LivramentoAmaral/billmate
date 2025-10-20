import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/group.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'group_members_page.dart';
import 'group_expenses_page.dart';
import 'group_details_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroups();
    });
  }

  void _loadGroups() {
    final authProvider = context.read<AuthProvider>();
    final groupProvider = context.read<GroupProvider>();

    if (authProvider.currentUser != null) {
      groupProvider.loadUserGroups(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
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
      body: Consumer2<GroupProvider, AuthProvider>(
        builder: (context, groupProvider, authProvider, child) {
          if (groupProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    groupProvider.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadGroups,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadGroups(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Card para criar novo grupo
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.group_add,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Criar Novo Grupo',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Nome do Grupo',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.group),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Descrição',
                          controller: _descriptionController,
                          prefixIcon: const Icon(Icons.description),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Criar Grupo',
                            onPressed: () =>
                                _createGroup(groupProvider, authProvider),
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de grupos
                if (groupProvider.groups.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum grupo encontrado',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crie seu primeiro grupo para começar a gerenciar despesas compartilhadas',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...groupProvider.groups.map((group) => _buildGroupCard(
                        context,
                        group,
                        groupProvider,
                        authProvider,
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    Group group,
    GroupProvider groupProvider,
    AuthProvider authProvider,
  ) {
    final isSelected = groupProvider.selectedGroup?.id == group.id;
    final isAdmin = group.adminId == authProvider.currentUser?.id;

    return Card(
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        onTap: () => groupProvider.setSelectedGroup(group),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.group,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                        if (group.description.isNotEmpty)
                          Text(
                            group.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Admin',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${group.members.length} ${group.members.length == 1 ? 'membro' : 'membros'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Criado em ${group.createdAt.day}/${group.createdAt.month}/${group.createdAt.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 8.0,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showGroupDetails(context, group),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Detalhes'),
                    ),
                    TextButton.icon(
                      onPressed: () => _showExpenses(context, group),
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text('Despesas'),
                    ),
                    if (isAdmin)
                      TextButton.icon(
                        onPressed: () => _showManageMembers(context, group),
                        icon: const Icon(Icons.manage_accounts, size: 18),
                        label: const Text('Gerenciar'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createGroup(
      GroupProvider groupProvider, AuthProvider authProvider) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome do grupo é obrigatório')),
      );
      return;
    }

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    final success = await groupProvider.createGroup(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      adminId: authProvider.currentUser!.id,
    );

    if (success) {
      _nameController.clear();
      _descriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grupo criado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(groupProvider.error ?? 'Erro ao criar grupo')),
      );
    }
  }

  void _showGroupDetails(BuildContext context, Group group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(group: group),
      ),
    );
  }

  void _showExpenses(BuildContext context, Group group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupExpensesPage(group: group),
      ),
    );
  }

  void _showManageMembers(BuildContext context, Group group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupMembersPage(group: group),
      ),
    );
  }
}
