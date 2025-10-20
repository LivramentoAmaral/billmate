import '../repositories/group_repository.dart';
import '../entities/group.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';

class CreateGroupUseCase {
  final GroupRepository groupRepository;

  CreateGroupUseCase(this.groupRepository);

  Future<Group?> call(String name, String description, String adminId) async {
    try {
      final group = Group.create(
        name: name,
        description: description,
        adminId: adminId,
      );
      return await groupRepository.createGroup(group);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

class GetUserGroupsUseCase {
  final GroupRepository groupRepository;

  GetUserGroupsUseCase(this.groupRepository);

  Future<List<Group>> call(String userId) async {
    try {
      return await groupRepository.getGroupsByUserId(userId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

class AddMemberToGroupUseCase {
  final GroupRepository groupRepository;

  AddMemberToGroupUseCase(this.groupRepository);

  Future<Group?> call(String groupId, String userId) async {
    try {
      return await groupRepository.addMemberToGroup(groupId, userId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

class RemoveMemberFromGroupUseCase {
  final GroupRepository groupRepository;

  RemoveMemberFromGroupUseCase(this.groupRepository);

  Future<Group?> call(String groupId, String userId) async {
    try {
      return await groupRepository.removeMemberFromGroup(groupId, userId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

class UpdateMemberRoleUseCase {
  final GroupRepository groupRepository;

  UpdateMemberRoleUseCase(this.groupRepository);

  Future<Group?> call(String groupId, String userId, UserRole role) async {
    try {
      return await groupRepository.updateMemberRole(groupId, userId, role);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
