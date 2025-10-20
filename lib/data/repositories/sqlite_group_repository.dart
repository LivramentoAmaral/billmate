import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/local_database.dart';
import '../models/group_model.dart';

class SqliteGroupRepository implements GroupRepository {
  final LocalDatabase _database;

  SqliteGroupRepository(this._database);

  @override
  Future<Group?> getGroupById(String id) async {
    final db = await _database.database;

    try {
      // Buscar o grupo
      final groupResults = await db.query(
        'groups_table',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (groupResults.isEmpty) return null;

      // Buscar membros do grupo
      final memberResults = await db.query(
        'group_members',
        where: 'groupId = ?',
        whereArgs: [id],
      );

      final members =
          memberResults.map((map) => GroupMemberModel.fromMap(map)).toList();
      final groupData = groupResults.first;

      return GroupModel.fromMap({
        ...groupData,
        'members': members.map((m) => m.toMap()).toList(),
      }).toEntity();
    } catch (e) {
      print('Error getting group by id: $e');
      return null;
    }
  }

  @override
  Future<List<Group>> getGroupsByUserId(String userId) async {
    final db = await _database.database;

    try {
      // Buscar grupos onde o usuário é membro
      final results = await db.rawQuery('''
        SELECT DISTINCT g.* FROM groups_table g
        INNER JOIN group_members gm ON g.id = gm.groupId
        WHERE gm.userId = ?
        ORDER BY g.updatedAt DESC
      ''', [userId]);

      final groups = <Group>[];

      for (final groupData in results) {
        // Buscar membros de cada grupo
        final memberResults = await db.query(
          'group_members',
          where: 'groupId = ?',
          whereArgs: [groupData['id']],
        );

        final members =
            memberResults.map((map) => GroupMemberModel.fromMap(map)).toList();

        final group = GroupModel.fromMap({
          ...groupData,
          'members': members.map((m) => m.toMap()).toList(),
        }).toEntity();

        groups.add(group);
      }

      return groups;
    } catch (e) {
      print('Error getting groups by user id: $e');
      return [];
    }
  }

  @override
  Future<Group?> createGroup(Group group) async {
    final db = await _database.database;

    try {
      await db.transaction((txn) async {
        // Inserir o grupo
        final groupModel = GroupModel.fromEntity(group);
        await txn.insert('groups_table', groupModel.toMap());

        // Inserir membros (incluindo o admin)
        for (final member in group.members) {
          await txn.insert('group_members', {
            'groupId': group.id,
            'userId': member.userId,
            'role': member.role.name,
            'joinedAt': member.joinedAt.millisecondsSinceEpoch,
          });
        }
      });

      return group;
    } catch (e) {
      print('Error creating group: $e');
      return null;
    }
  }

  @override
  Future<Group?> updateGroup(Group group) async {
    final db = await _database.database;

    try {
      final groupModel =
          GroupModel.fromEntity(group).copyWith(updatedAt: DateTime.now());

      final count = await db.update(
        'groups_table',
        groupModel.toMap(),
        where: 'id = ?',
        whereArgs: [group.id],
      );

      if (count > 0) {
        return groupModel.toEntity();
      }
      return null;
    } catch (e) {
      print('Error updating group: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteGroup(String id) async {
    final db = await _database.database;

    try {
      await db.transaction((txn) async {
        // Verificar se há despesas associadas ao grupo
        final expenseCount = await txn.query(
          'expenses',
          where: 'groupId = ?',
          whereArgs: [id],
        );

        if (expenseCount.isNotEmpty) {
          throw Exception('Cannot delete group: it has associated expenses');
        }

        // Remover membros do grupo
        await txn.delete(
          'group_members',
          where: 'groupId = ?',
          whereArgs: [id],
        );

        // Remover o grupo
        await txn.delete(
          'groups_table',
          where: 'id = ?',
          whereArgs: [id],
        );
      });

      return true;
    } catch (e) {
      print('Error deleting group: $e');
      return false;
    }
  }

  @override
  Future<Group?> addMemberToGroup(String groupId, String userId) async {
    final db = await _database.database;

    try {
      // Verificar se o usuário já é membro
      final existingMember = await db.query(
        'group_members',
        where: 'groupId = ? AND userId = ?',
        whereArgs: [groupId, userId],
      );

      if (existingMember.isNotEmpty) {
        throw Exception('User is already a member of this group');
      }

      // Adicionar membro
      await db.insert('group_members', {
        'groupId': groupId,
        'userId': userId,
        'role': UserRole.member.name,
        'joinedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Atualizar timestamp do grupo
      await db.update(
        'groups_table',
        {'updatedAt': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [groupId],
      );

      return await getGroupById(groupId);
    } catch (e) {
      print('Error adding member to group: $e');
      return null;
    }
  }

  @override
  Future<Group?> removeMemberFromGroup(String groupId, String userId) async {
    final db = await _database.database;

    try {
      // Verificar se é o admin do grupo
      final group = await getGroupById(groupId);
      if (group?.adminId == userId) {
        throw Exception('Cannot remove group admin');
      }

      final count = await db.delete(
        'group_members',
        where: 'groupId = ? AND userId = ?',
        whereArgs: [groupId, userId],
      );

      if (count > 0) {
        // Atualizar timestamp do grupo
        await db.update(
          'groups_table',
          {'updatedAt': DateTime.now().millisecondsSinceEpoch},
          where: 'id = ?',
          whereArgs: [groupId],
        );

        return await getGroupById(groupId);
      }

      return null;
    } catch (e) {
      print('Error removing member from group: $e');
      return null;
    }
  }

  @override
  Future<Group?> updateMemberRole(
      String groupId, String userId, UserRole role) async {
    final db = await _database.database;

    try {
      final count = await db.update(
        'group_members',
        {'role': role.name},
        where: 'groupId = ? AND userId = ?',
        whereArgs: [groupId, userId],
      );

      if (count > 0) {
        // Atualizar timestamp do grupo
        await db.update(
          'groups_table',
          {'updatedAt': DateTime.now().millisecondsSinceEpoch},
          where: 'id = ?',
          whereArgs: [groupId],
        );

        return await getGroupById(groupId);
      }

      return null;
    } catch (e) {
      print('Error updating member role: $e');
      return null;
    }
  }

  @override
  Future<List<Group>> searchGroups(String query) async {
    final db = await _database.database;

    try {
      final results = await db.query(
        'groups_table',
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'updatedAt DESC',
        limit: 20,
      );

      final groups = <Group>[];

      for (final groupData in results) {
        // Buscar membros de cada grupo
        final memberResults = await db.query(
          'group_members',
          where: 'groupId = ?',
          whereArgs: [groupData['id']],
        );

        final members =
            memberResults.map((map) => GroupMemberModel.fromMap(map)).toList();

        final group = GroupModel.fromMap({
          ...groupData,
          'members': members.map((m) => m.toMap()).toList(),
        }).toEntity();

        groups.add(group);
      }

      return groups;
    } catch (e) {
      print('Error searching groups: $e');
      return [];
    }
  }

  @override
  Future<void> syncGroup(Group group) async {
    final db = await _database.database;

    try {
      await db.update(
        'groups_table',
        {'isSynced': 1, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [group.id],
      );
    } catch (e) {
      print('Error syncing group: $e');
    }
  }

  @override
  Stream<Group?> watchGroup(String groupId) async* {
    // Implementação básica - em produção poderia usar um stream controller
    // que reage a mudanças no banco de dados
    yield await getGroupById(groupId);
  }

  @override
  Stream<List<Group>> watchUserGroups(String userId) async* {
    // Implementação básica - em produção poderia usar um stream controller
    // que reage a mudanças no banco de dados
    yield await getGroupsByUserId(userId);
  }
}
