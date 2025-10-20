import '../../domain/entities/group.dart';
import '../../core/constants/app_constants.dart';

class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    required super.description,
    required super.adminId,
    required super.members,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GroupModel.fromEntity(Group group) {
    return GroupModel(
      id: group.id,
      name: group.name,
      description: group.description,
      adminId: group.adminId,
      members: group.members,
      createdAt: group.createdAt,
      updatedAt: group.updatedAt,
    );
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      adminId: map['adminId'] ?? '',
      members: List<GroupMember>.from(
        map['members']?.map((x) => GroupMemberModel.fromMap(x)) ?? [],
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      adminId: json['adminId'] ?? '',
      members: List<GroupMember>.from(
        json['members']?.map((x) => GroupMemberModel.fromJson(x)) ?? [],
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'adminId': adminId,
      'members': members
          .map((member) => GroupMemberModel.fromEntity(member).toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'adminId': adminId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Group toEntity() {
    return Group(
      id: id,
      name: name,
      description: description,
      adminId: adminId,
      members: members,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? adminId,
    List<GroupMember>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GroupMemberModel extends GroupMember {
  const GroupMemberModel({
    required super.userId,
    required super.role,
    required super.joinedAt,
  });

  factory GroupMemberModel.fromEntity(GroupMember member) {
    return GroupMemberModel(
      userId: member.userId,
      role: member.role,
      joinedAt: member.joinedAt,
    );
  }

  factory GroupMemberModel.fromMap(Map<String, dynamic> map) {
    return GroupMemberModel(
      userId: map['userId'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.member,
      ),
      joinedAt: DateTime.fromMillisecondsSinceEpoch(map['joinedAt']),
    );
  }

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['userId'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.member,
      ),
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role.name,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
    };
  }

  GroupMemberModel copyWith({
    String? userId,
    UserRole? role,
    DateTime? joinedAt,
  }) {
    return GroupMemberModel(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
