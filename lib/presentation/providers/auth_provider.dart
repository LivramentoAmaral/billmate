import 'dart:async';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/repositories/user_repository.dart';
import 'base_provider.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends BaseProvider {
  final SignInWithEmailPasswordUseCase? signInUseCase;
  final SignUpWithEmailPasswordUseCase? signUpUseCase;
  final SignOutUseCase? signOutUseCase;
  final GetCurrentUserUseCase? getCurrentUserUseCase;
  final UserRepository? userRepository;

  StreamSubscription<User?>? _authSubscription;
  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  bool _isInitialized = false;

  AuthProvider({
    this.signInUseCase,
    this.signUpUseCase,
    this.signOutUseCase,
    this.getCurrentUserUseCase,
    this.userRepository,
  }) {
    if (signInUseCase != null) {
      _init();
    } else {
      // Para desenvolvimento inicial, começamos como não autenticado
      _status = AuthStatus.unauthenticated;
      _isInitialized = true;
    }
  }

  // Construtor simplificado para desenvolvimento
  AuthProvider.development()
      : signInUseCase = null,
        signUpUseCase = null,
        signOutUseCase = null,
        getCurrentUserUseCase = null,
        userRepository = null {
    _status = AuthStatus.unauthenticated;
    _isInitialized = true;
  }

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => error; // Expor o error do BaseProvider
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;
  bool get isInitialized => _isInitialized;

  void _init() {
    _checkAuthStatus();
    _listenToAuthChanges();
  }

  Future<void> _checkAuthStatus() async {
    if (getCurrentUserUseCase == null || isDisposed) return;

    await runAsync(
      operation: () async {
        final user = await getCurrentUserUseCase!();
        if (!isDisposed) {
          if (user != null) {
            _currentUser = user;
            _setStatus(AuthStatus.authenticated);
          } else {
            _setStatus(AuthStatus.unauthenticated);
          }
          _isInitialized = true;
        }
      },
      showLoading: false,
      errorMessage: 'Erro ao verificar status de autenticação',
    );
  }

  void _listenToAuthChanges() {
    if (userRepository == null || isDisposed) return;

    _authSubscription?.cancel();
    _authSubscription = userRepository!.watchCurrentUser().listen(
      (user) {
        if (!isDisposed) {
          if (user != null && _currentUser?.id != user.id) {
            _currentUser = user;
            _setStatus(AuthStatus.authenticated);
          } else if (user == null && _currentUser != null) {
            _currentUser = null;
            _setStatus(AuthStatus.unauthenticated);
          }
        }
      },
      onError: (error) {
        if (!isDisposed) {
          setError('Erro no stream de autenticação: $error');
        }
      },
    );
  }

  Future<bool> signIn(String email, String password) async {
    if (signInUseCase == null) {
      setError('SignIn não configurado');
      return false;
    }

    return await runAsyncBool(
      operation: () async {
        final user = await signInUseCase!(email, password);
        if (!isDisposed && user != null) {
          _currentUser = user;
          _setStatus(AuthStatus.authenticated);
          return true;
        }
        setError('Credenciais inválidas');
        return false;
      },
      errorMessage: 'Erro ao fazer login',
    );
  }

  Future<bool> signUp(String email, String password, String name) async {
    if (signUpUseCase == null) {
      setError('SignUp não configurado');
      return false;
    }

    return await runAsyncBool(
      operation: () async {
        final user = await signUpUseCase!(email, password, name);
        if (!isDisposed && user != null) {
          _currentUser = user;
          _setStatus(AuthStatus.authenticated);
          return true;
        }
        setError('Erro ao criar conta');
        return false;
      },
      errorMessage: 'Erro ao criar conta',
    );
  }

  Future<void> signOut() async {
    if (signOutUseCase == null) {
      setError('SignOut não configurado');
      return;
    }

    await runAsync(
      operation: () async {
        await signOutUseCase!();
        if (!isDisposed) {
          _currentUser = null;
          _setStatus(AuthStatus.unauthenticated);
        }
      },
      errorMessage: 'Erro ao fazer logout',
    );
  }

  void _setStatus(AuthStatus status) {
    if (_status != status && !isDisposed) {
      _status = status;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
