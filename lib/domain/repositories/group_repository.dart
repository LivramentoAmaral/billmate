import '../entities/group.dart';
import '../../core/constants/app_constants.dart';

abstract class GroupRepository {
  Future<Group?> getGroupById(String id);
  Future<List<Group>> getGroupsByUserId(String userId);
  Future<Group?> createGroup(Group group);
  Future<Group?> updateGroup(Group group);
  Future<bool> deleteGroup(String id);
  Future<Group?> addMemberToGroup(String groupId, String userId);
  Future<Group?> removeMemberFromGroup(String groupId, String userId);
  Future<Group?> updateMemberRole(String groupId, String userId, UserRole role);
  Future<List<Group>> searchGroups(String query);
  Future<void> syncGroup(Group group);
  Stream<Group?> watchGroup(String groupId);
  Stream<List<Group>> watchUserGroups(String userId);
}
