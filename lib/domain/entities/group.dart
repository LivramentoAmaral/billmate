import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final List<GroupMember> members;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? adminId,
    List<GroupMember>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'adminId': adminId,
      'members': members.map((member) => member.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      adminId: map['adminId'] ?? '',
      members: List<GroupMember>.from(
        map['members']?.map((x) => GroupMember.fromMap(x)) ?? [],
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  factory Group.create({
    required String name,
    required String description,
    required String adminId,
  }) {
    final now = DateTime.now();
    return Group(
      id: const Uuid().v4(),
      name: name,
      description: description,
      adminId: adminId,
      members: [
        GroupMember(
          userId: adminId,
          role: UserRole.admin,
          joinedAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  bool isAdmin(String userId) {
    return adminId == userId;
  }

  bool isMember(String userId) {
    return members.any((member) => member.userId == userId);
  }

  GroupMember? getMember(String userId) {
    try {
      return members.firstWhere((member) => member.userId == userId);
    } catch (e) {
      return null;
    }
  }

  Group addMember(String userId, UserRole role) {
    if (isMember(userId)) return this;

    final newMember = GroupMember(
      userId: userId,
      role: role,
      joinedAt: DateTime.now(),
    );

    return copyWith(
      members: [...members, newMember],
      updatedAt: DateTime.now(),
    );
  }

  Group removeMember(String userId) {
    if (!isMember(userId) || isAdmin(userId)) return this;

    return copyWith(
      members: members.where((member) => member.userId != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Group && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Group(id: $id, name: $name, members: ${members.length})';
  }
}

class GroupMember {
  final String userId;
  final UserRole role;
  final DateTime joinedAt;

  const GroupMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  GroupMember copyWith({
    String? userId,
    UserRole? role,
    DateTime? joinedAt,
  }) {
    return GroupMember(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role.name,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
    };
  }

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      userId: map['userId'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.member,
      ),
      joinedAt: DateTime.fromMillisecondsSinceEpoch(map['joinedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupMember && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'GroupMember(userId: $userId, role: $role)';
  }
}
