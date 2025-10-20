import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User?> getUserById(String id);
  Future<User?> getUserByEmail(String email);
  Future<List<User>> getUsers();
  Future<User?> createUser(User user);
  Future<User?> updateUser(User user);
  Future<bool> deleteUser(String id);
  Future<void> syncUser(User user);
  Stream<User?> watchCurrentUser();
}

abstract class AuthRepository {
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<User?> getCurrentUser();
  Stream<User?> get authStateChanges;
  Future<void> updateProfile({String? displayName, String? photoURL});
  Future<void> deleteAccount();
}
