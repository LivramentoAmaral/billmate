import '../repositories/user_repository.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

class SignInWithEmailPasswordUseCase {
  final AuthRepository authRepository;

  SignInWithEmailPasswordUseCase(this.authRepository);

  Future<User?> call(String email, String password) async {
    try {
      return await authRepository.signInWithEmailAndPassword(email, password);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }
}

class SignUpWithEmailPasswordUseCase {
  final AuthRepository authRepository;

  SignUpWithEmailPasswordUseCase(this.authRepository);

  Future<User?> call(String email, String password, String name) async {
    try {
      return await authRepository.signUpWithEmailAndPassword(
          email, password, name);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }
}

class SignOutUseCase {
  final AuthRepository authRepository;

  SignOutUseCase(this.authRepository);

  Future<void> call() async {
    try {
      return await authRepository.signOut();
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }
}

class GetCurrentUserUseCase {
  final AuthRepository authRepository;

  GetCurrentUserUseCase(this.authRepository);

  Future<User?> call() async {
    try {
      return await authRepository.getCurrentUser();
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }
}

class SendPasswordResetEmailUseCase {
  final AuthRepository authRepository;

  SendPasswordResetEmailUseCase(this.authRepository);

  Future<void> call(String email) async {
    try {
      return await authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }
}
