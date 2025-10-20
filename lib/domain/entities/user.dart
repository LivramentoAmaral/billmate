import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime? lastSyncAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.createdAt,
    this.lastSyncAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? lastSyncAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSyncAt': lastSyncAt?.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePicture: map['profilePicture'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastSyncAt: map['lastSyncAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSyncAt'])
          : null,
    );
  }

  factory User.create({
    required String name,
    required String email,
    String? profilePicture,
  }) {
    return User(
      id: const Uuid().v4(),
      name: name,
      email: email,
      profilePicture: profilePicture,
      createdAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}
