import '../models/user_model.dart';
import 'user_remote_datasource.dart';

class MockUserRemoteDataSource implements UserRemoteDataSource {
  // Simulação de dados em memória para desenvolvimento
  final Map<String, UserModel> _users = {};
  UserModel? _currentUser;

  MockUserRemoteDataSource() {
    _initializeTestUsers();
  }

  void _initializeTestUsers() {
    // Adiciona usuários de teste
    final testUser1 = UserModel(
      id: '1',
      name: 'João Silva',
      email: 'joao@teste.com',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    final testUser2 = UserModel(
      id: '2',
      name: 'Maria Santos',
      email: 'maria@teste.com',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    );

    _users[testUser1.id] = testUser1;
    _users[testUser2.id] = testUser2;
  }

  @override
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    // Simulação de delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    // Busca usuário por email
    UserModel? user;
    try {
      user = _users.values.firstWhere(
        (user) => user.email == email,
      );
    } catch (e) {
      throw Exception('Email não encontrado');
    }

    // Simulação simples de validação de senha
    // Para testes, aceita qualquer senha com 6+ caracteres
    if (password.length >= 6) {
      _currentUser = user;
      return user;
    } else {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }
  }

  @override
  Future<UserModel?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    // Simulação de delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    // Verifica se usuário já existe
    if (_users.values.any((user) => user.email == email)) {
      throw Exception('Email já está em uso');
    }

    // Cria novo usuário
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    _users[newUser.id] = newUser;
    _currentUser = newUser;
    return newUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulação - em um app real, enviaria email
    // Em desenvolvimento, apenas simula o envio
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentUser;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    // Retorna stream simples com estado atual
    return Stream.periodic(
      const Duration(seconds: 1),
      (_) => _currentUser,
    ).distinct();
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: displayName ?? _currentUser!.name,
        profilePicture: photoURL ?? _currentUser!.profilePicture,
      );
      _users[_currentUser!.id] = _currentUser!;
    }
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentUser != null) {
      _users.remove(_currentUser!.id);
      _currentUser = null;
    }
  }

  // Métodos auxiliares para testes
  void addTestUser(UserModel user) {
    _users[user.id] = user;
  }

  void clearAllUsers() {
    _users.clear();
    _currentUser = null;
  }

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      _users[user.id] = user;
    }
  }
}
