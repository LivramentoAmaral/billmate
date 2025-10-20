import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository, AuthRepository {
  final UserLocalDataSource localDataSource;
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<User?> getCurrentUser() async {
    try {
      // Primeiro tenta obter do cache local
      final localUser = await localDataSource.getCurrentUser();
      if (localUser != null) {
        return localUser;
      }

      // Se não encontrar local, busca remoto
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        // Salva no cache local
        await localDataSource.insertUser(remoteUser);
        await localDataSource.setCurrentUser(remoteUser.id);
        return remoteUser;
      }

      return null;
    } catch (e) {
      // Em caso de erro, tenta buscar apenas local
      return await localDataSource.getCurrentUser();
    }
  }

  @override
  Future<User?> getUserById(String id) async {
    try {
      // Busca primeiro no cache local
      final localUser = await localDataSource.getUserById(id);
      if (localUser != null) {
        return localUser;
      }

      // Se não encontrar local, poderia buscar remoto
      // Aqui seria implementada busca em MongoDB/Firestore
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    try {
      return await localDataSource.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<User>> getUsers() async {
    try {
      final users = await localDataSource.getUsers();
      return users.cast<User>();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<User?> createUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await localDataSource.insertUser(userModel);
      return userModel;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User?> updateUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await localDataSource.updateUser(userModel);
      return userModel;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteUser(String id) async {
    try {
      final result = await localDataSource.deleteUser(id);
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> syncUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      // Implementar sincronização com MongoDB
      await localDataSource.updateUser(userModel);
    } catch (e) {
      // Log error
    }
  }

  @override
  Stream<User?> watchCurrentUser() {
    return remoteDataSource.authStateChanges;
  }

  // AuthRepository implementation
  @override
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final user =
          await remoteDataSource.signInWithEmailAndPassword(email, password);
      if (user != null) {
        await localDataSource.insertUser(user);
        await localDataSource.setCurrentUser(user.id);
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
          email, password, name);
      if (user != null) {
        await localDataSource.insertUser(user);
        await localDataSource.setCurrentUser(user.id);
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      await remoteDataSource.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Atualizar também no cache local
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          name: displayName ?? currentUser.name,
          profilePicture: photoURL ?? currentUser.profilePicture,
        );
        await updateUser(updatedUser);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        await deleteUser(currentUser.id);
      }
      await remoteDataSource.deleteAccount();
    } catch (e) {
      rethrow;
    }
  }
}
