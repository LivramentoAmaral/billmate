import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/group.dart';
import '../../core/constants/app_constants.dart';
import '../providers/group_provider.dart';
import '../widgets/custom_button.dart';

class GroupMembersPage extends StatefulWidget {
  final Group group;

  const GroupMembersPage({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membros - ${widget.group.name}'),
        actions: [
          // IconButton(
          //   onPressed: _scanQRCode,
          //   icon: const Icon(Icons.qr_code_scanner),
          //   tooltip: 'Escanear QR Code',
          // ),
          IconButton(
            onPressed: _showAddMemberDialog,
            icon: const Icon(Icons.person_add),
            tooltip: 'Adicionar membro',
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Estatísticas do grupo
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo do Grupo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatCard('Total de Membros',
                            '${widget.group.members.length}', Icons.people),
                        const SizedBox(width: 16),
                        _buildStatCard('Administradores', '${_getAdminCount()}',
                            Icons.admin_panel_settings),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de membros
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.group.members.length,
                  itemBuilder: (context, index) {
                    final member = widget.group.members[index];
                    final isCurrentUserAdmin = _isCurrentUserAdmin();
                    final isMemberAdmin = member.role == UserRole.admin;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            member.userId.isNotEmpty
                                ? member.userId[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text('Usuário ${member.userId}'),
                        subtitle: Row(
                          children: [
                            Icon(
                              isMemberAdmin
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              size: 16,
                              color: isMemberAdmin
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isMemberAdmin ? 'Administrador' : 'Membro',
                              style: TextStyle(
                                color: isMemberAdmin
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                fontWeight: isMemberAdmin
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        trailing: isCurrentUserAdmin && !isMemberAdmin
                            ? PopupMenuButton<String>(
                                onSelected: (value) =>
                                    _handleMemberAction(value, member),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'promote',
                                    child: Row(
                                      children: [
                                        Icon(Icons.admin_panel_settings),
                                        SizedBox(width: 8),
                                        Text('Promover a Admin'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(Icons.person_remove,
                                            color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Remover',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : isMemberAdmin && isCurrentUserAdmin
                                ? PopupMenuButton<String>(
                                    onSelected: (value) =>
                                        _handleMemberAction(value, member),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'demote',
                                        child: Row(
                                          children: [
                                            Icon(Icons.person),
                                            SizedBox(width: 8),
                                            Text('Remover Admin'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _getAdminCount() {
    return widget.group.members
        .where((member) => member.role == UserRole.admin)
        .length;
  }

  bool _isCurrentUserAdmin() {
    // TODO: Implementar verificação do usuário atual
    // Por enquanto, assumir que o primeiro admin é o usuário atual
    return widget.group.members.any((member) => member.role == UserRole.admin);
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Membro'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email do usuário',
                  hintText: 'usuario@email.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'O usuário receberá um convite para participar do grupo.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          CustomButton(
            text: 'Enviar Convite',
            onPressed: _addMember,
            isLoading: context.watch<GroupProvider>().isLoading,
          ),
        ],
      ),
    );
  }

  Future<void> _addMember() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final groupProvider = context.read<GroupProvider>();

    try {
      await groupProvider.addMemberToGroup(widget.group.id, email);

      if (mounted) {
        Navigator.of(context).pop();
        _emailController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Convite enviado para $email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar convite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleMemberAction(String action, GroupMember member) async {
    final groupProvider = context.read<GroupProvider>();

    switch (action) {
      case 'promote':
        await _confirmAndExecute(
          'Promover Membro',
          'Tem certeza que deseja promover o usuário ${member.userId} a administrador?',
          () => groupProvider.updateMemberRole(
              widget.group.id, member.userId, UserRole.admin),
        );
        break;
      case 'demote':
        await _confirmAndExecute(
          'Remover Administrador',
          'Tem certeza que deseja remover o usuário ${member.userId} da administração?',
          () => groupProvider.updateMemberRole(
              widget.group.id, member.userId, UserRole.member),
        );
        break;
      case 'remove':
        await _confirmAndExecute(
          'Remover Membro',
          'Tem certeza que deseja remover o usuário ${member.userId} do grupo?',
          () => groupProvider.removeMemberFromGroup(
              widget.group.id, member.userId),
        );
        break;
    }
  }

  Future<void> _confirmAndExecute(
      String title, String message, Future<void> Function() action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          CustomButton(
            text: 'Confirmar',
            onPressed: () => Navigator.of(context).pop(true),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await action();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ação executada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
