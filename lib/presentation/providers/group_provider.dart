import '../../domain/entities/group.dart';
import '../../domain/usecases/group_usecases.dart';
import '../../core/constants/app_constants.dart';
import 'base_provider.dart';

class GroupProvider extends BaseProvider with CacheMixin<List<Group>> {
  final CreateGroupUseCase _createGroupUseCase;
  final GetUserGroupsUseCase _getUserGroupsUseCase;
  final AddMemberToGroupUseCase _addMemberToGroupUseCase;
  final RemoveMemberFromGroupUseCase _removeMemberFromGroupUseCase;
  final UpdateMemberRoleUseCase _updateMemberRoleUseCase;

  List<Group> _groups = [];
  Group? _selectedGroup;
  String? _currentUserId;

  List<Group> get groups => List.unmodifiable(_groups);
  Group? get selectedGroup => _selectedGroup;

  GroupProvider({
    required CreateGroupUseCase createGroupUseCase,
    required GetUserGroupsUseCase getUserGroupsUseCase,
    required AddMemberToGroupUseCase addMemberToGroupUseCase,
    required RemoveMemberFromGroupUseCase removeMemberFromGroupUseCase,
    required UpdateMemberRoleUseCase updateMemberRoleUseCase,
  })  : _createGroupUseCase = createGroupUseCase,
        _getUserGroupsUseCase = getUserGroupsUseCase,
        _addMemberToGroupUseCase = addMemberToGroupUseCase,
        _removeMemberFromGroupUseCase = removeMemberFromGroupUseCase,
        _updateMemberRoleUseCase = updateMemberRoleUseCase;

  void setSelectedGroup(Group? group) {
    if (_selectedGroup?.id != group?.id && !isDisposed) {
      _selectedGroup = group;
      notifyListeners();
    }
  }

  Future<void> loadUserGroups(String userId,
      {bool forceRefresh = false}) async {
    // Evitar carregamento duplicado
    if (userId == _currentUserId && !forceRefresh && _groups.isNotEmpty) {
      return;
    }

    // Tentar cache
    if (!forceRefresh) {
      final cached = getCached('user_groups_$userId');
      if (cached != null) {
        _groups = cached;
        _currentUserId = userId;

        // Selecionar primeiro grupo se necessário
        if (_selectedGroup == null && _groups.isNotEmpty) {
          _selectedGroup = _groups.first;
        }

        notifyListeners();
        return;
      }
    }

    final groups = await runAsync<List<Group>>(
      operation: () => _getUserGroupsUseCase(userId),
      errorMessage: 'Erro ao carregar grupos do usuário',
      showLoading: true,
    );

    if (!isDisposed && groups != null) {
      _groups = groups;
      _currentUserId = userId;
      setCached('user_groups_$userId', groups);

      // Se não há grupo selecionado e há grupos disponíveis, selecionar o primeiro
      if (_selectedGroup == null && _groups.isNotEmpty) {
        _selectedGroup = _groups.first;
      }

      notifyListeners();
    }
  }

  Future<bool> createGroup({
    required String name,
    required String description,
    required String adminId,
  }) async {
    return await runAsyncBool(
      operation: () async {
        final group = await _createGroupUseCase(name, description, adminId);
        if (!isDisposed && group != null) {
          _groups.insert(0, group);
          _selectedGroup = group;

          // Invalidar cache
          if (_currentUserId != null) {
            clearCacheKey('user_groups_$_currentUserId');
          }

          notifyListeners();
          return true;
        }
        return false;
      },
      errorMessage: 'Erro ao criar grupo',
    );
  }

  Future<bool> addMemberToGroup(String groupId, String userId) async {
    return await runAsyncBool(
      operation: () async {
        final updatedGroup = await _addMemberToGroupUseCase(groupId, userId);
        if (!isDisposed && updatedGroup != null) {
          _updateGroupInList(updatedGroup);
          notifyListeners();
          return true;
        }
        return false;
      },
      errorMessage: 'Erro ao adicionar membro',
      showLoading: false,
    );
  }

  Future<bool> removeMemberFromGroup(String groupId, String userId) async {
    return await runAsyncBool(
      operation: () async {
        final updatedGroup =
            await _removeMemberFromGroupUseCase(groupId, userId);
        if (!isDisposed && updatedGroup != null) {
          _updateGroupInList(updatedGroup);
          notifyListeners();
          return true;
        }
        return false;
      },
      errorMessage: 'Erro ao remover membro',
      showLoading: false,
    );
  }

  Future<bool> updateMemberRole(
      String groupId, String userId, UserRole role) async {
    return await runAsyncBool(
      operation: () async {
        final updatedGroup =
            await _updateMemberRoleUseCase(groupId, userId, role);
        if (!isDisposed && updatedGroup != null) {
          _updateGroupInList(updatedGroup);
          notifyListeners();
          return true;
        }
        return false;
      },
      errorMessage: 'Erro ao atualizar função do membro',
      showLoading: false,
    );
  }

  /// Atualiza um grupo na lista e no grupo selecionado se necessário
  void _updateGroupInList(Group updatedGroup) {
    final index = _groups.indexWhere((g) => g.id == updatedGroup.id);
    if (index != -1) {
      _groups[index] = updatedGroup;
    }

    if (_selectedGroup?.id == updatedGroup.id) {
      _selectedGroup = updatedGroup;
    }

    // Invalidar cache
    if (_currentUserId != null) {
      clearCacheKey('user_groups_$_currentUserId');
    }
  }

  bool isUserAdmin(String userId) {
    return _selectedGroup?.adminId == userId;
  }

  bool isUserMember(String userId) {
    return _selectedGroup?.members.any((member) => member.userId == userId) ??
        false;
  }

  UserRole? getUserRole(String userId) {
    try {
      final member = _selectedGroup?.members.firstWhere(
        (member) => member.userId == userId,
      );
      return member?.role;
    } catch (e) {
      return null;
    }
  }

  List<GroupMember> get selectedGroupMembers {
    return _selectedGroup?.members ?? [];
  }

  int get selectedGroupMemberCount {
    return _selectedGroup?.members.length ?? 0;
  }

  void refresh() {
    if (!isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}
