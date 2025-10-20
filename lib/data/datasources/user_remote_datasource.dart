import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> signUpWithEmailAndPassword(
      String email, String password, String name);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
  Future<void> updateProfile({String? displayName, String? photoURL});
  Future<void> deleteAccount();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;

  UserRemoteDataSourceImpl(this.firebaseAuth);

  @override
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        return _firebaseUserToUserModel(user);
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<UserModel?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        return _firebaseUserToUserModel(user);
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return _firebaseUserToUserModel(user);
    }
    return null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user != null) {
        return _firebaseUserToUserModel(user);
      }
      return null;
    });
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        await user.reload();
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  UserModel _firebaseUserToUserModel(firebase_auth.User user) {
    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      profilePicture: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastSyncAt: DateTime.now(),
    );
  }

  Exception _handleFirebaseAuthException(
      firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Usuário não encontrado');
      case 'wrong-password':
        return Exception('Senha incorreta');
      case 'email-already-in-use':
        return Exception('Este email já está em uso');
      case 'weak-password':
        return Exception('A senha é muito fraca');
      case 'invalid-email':
        return Exception('Email inválido');
      case 'user-disabled':
        return Exception('Usuário desabilitado');
      case 'too-many-requests':
        return Exception('Muitas tentativas. Tente novamente mais tarde');
      case 'operation-not-allowed':
        return Exception('Operação não permitida');
      default:
        return Exception('Erro de autenticação: ${e.message}');
    }
  }
}
