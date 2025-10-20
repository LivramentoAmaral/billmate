import '../../domain/entities/expense.dart';
import '../../domain/usecases/expense_usecases.dart';
import '../../core/constants/app_constants.dart';
import 'base_provider.dart';

class ExpenseProvider extends BaseProvider with CacheMixin<List<Expense>> {
  final CreateExpenseUseCase _createExpenseUseCase;
  final GetGroupExpensesUseCase _getGroupExpensesUseCase;
  final UpdateExpenseStatusUseCase _updateExpenseStatusUseCase;
  final GetUserExpensesUseCase _getUserExpensesUseCase;
  final GetMonthlyExpensesUseCase _getMonthlyExpensesUseCase;

  ExpenseProvider({
    required CreateExpenseUseCase createExpenseUseCase,
    required GetGroupExpensesUseCase getGroupExpensesUseCase,
    required UpdateExpenseStatusUseCase updateExpenseStatusUseCase,
    required GetUserExpensesUseCase getUserExpensesUseCase,
    required GetMonthlyExpensesUseCase getMonthlyExpensesUseCase,
  })  : _createExpenseUseCase = createExpenseUseCase,
        _getGroupExpensesUseCase = getGroupExpensesUseCase,
        _updateExpenseStatusUseCase = updateExpenseStatusUseCase,
        _getUserExpensesUseCase = getUserExpensesUseCase,
        _getMonthlyExpensesUseCase = getMonthlyExpensesUseCase;

  List<Expense> _expenses = [];
  List<Expense> _userExpenses = [];
  String? _currentUserId;
  String? _currentGroupId;
  bool _isLoadingUser = false;
  bool _isLoadingGroup = false;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Expense> get userExpenses => List.unmodifiable(_userExpenses);

  // Getter para despesas do mês atual
  List<Expense> get currentMonthExpenses {
    final now = DateTime.now();
    return _userExpenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).toList();
  }

  // Getter para total gasto no mês
  double get currentMonthTotal {
    return currentMonthExpenses.fold(
        0.0, (total, expense) => total + expense.amount);
  }

  // Getter para total de despesas pendentes
  int get pendingExpensesCount {
    return _expenses
        .where((expense) => expense.status == ExpenseStatus.pending)
        .length;
  }

  Future<void> loadUserExpenses(String userId,
      {bool forceRefresh = false}) async {
    // Evitar carregamento duplicado
    if (_isLoadingUser || (userId == _currentUserId && !forceRefresh)) {
      return;
    }

    // Tentar usar cache se disponível
    if (!forceRefresh) {
      final cached = getCached('user_$userId');
      if (cached != null) {
        _userExpenses = cached;
        _currentUserId = userId;
        notifyListeners();
        return;
      }
    }

    _isLoadingUser = true;
    final expenses = await runAsync<List<Expense>>(
      operation: () => _getUserExpensesUseCase(userId),
      errorMessage: 'Erro ao carregar despesas do usuário',
      showLoading: true,
    );

    if (!isDisposed && expenses != null) {
      _userExpenses = expenses;
      _currentUserId = userId;
      setCached('user_$userId', expenses);
      notifyListeners();
    }
    _isLoadingUser = false;
  }

  Future<void> loadGroupExpenses(String groupId,
      {bool forceRefresh = false}) async {
    // Evitar carregamento duplicado
    if (_isLoadingGroup || (groupId == _currentGroupId && !forceRefresh)) {
      return;
    }

    // Tentar usar cache se disponível
    if (!forceRefresh) {
      final cached = getCached('group_$groupId');
      if (cached != null) {
        _expenses = cached;
        _currentGroupId = groupId;
        notifyListeners();
        return;
      }
    }

    _isLoadingGroup = true;
    final expenses = await runAsync<List<Expense>>(
      operation: () => _getGroupExpensesUseCase(groupId),
      errorMessage: 'Erro ao carregar despesas do grupo',
      showLoading: true,
    );

    if (!isDisposed && expenses != null) {
      _expenses = expenses;
      _currentGroupId = groupId;
      setCached('group_$groupId', expenses);
      notifyListeners();
    }
    _isLoadingGroup = false;
  }

  Future<void> loadMonthlyExpenses(int year, int month) async {
    final cacheKey = 'monthly_${year}_$month';

    // Tentar usar cache
    final cached = getCached(cacheKey);
    if (cached != null) {
      _userExpenses = cached;
      notifyListeners();
      return;
    }

    final expenses = await runAsync<List<Expense>>(
      operation: () => _getMonthlyExpensesUseCase(year, month),
      errorMessage: 'Erro ao carregar despesas mensais',
      showLoading: true,
    );

    if (!isDisposed && expenses != null) {
      _userExpenses = expenses;
      setCached(cacheKey, expenses);
      notifyListeners();
    }
  }

  Future<bool> createExpense({
    required String name,
    String? description,
    required double amount,
    required String categoryId,
    required String groupId,
    required String createdByUserId,
    required List<ExpenseParticipant> participants,
    required ExpenseType type,
    DateTime? date,
    DateTime? dueDate,
    bool isRecurring = false,
    RecurrencePattern? recurrencePattern,
  }) async {
    return await runAsyncBool(
      operation: () async {
        final expense = await _createExpenseUseCase(
          name: name,
          description: description,
          amount: amount,
          categoryId: categoryId,
          groupId: groupId,
          createdByUserId: createdByUserId,
          participants: participants,
          type: type,
          date: date,
          dueDate: dueDate,
          isRecurring: isRecurring,
          recurrencePattern: recurrencePattern,
        );

        if (!isDisposed && expense != null) {
          _expenses.add(expense);
          _userExpenses.add(expense);

          // Invalidar caches relevantes
          clearCacheKey('user_$createdByUserId');
          clearCacheKey('group_$groupId');

          notifyListeners();
          return true;
        }
        return false;
      },
      errorMessage: 'Erro ao criar despesa',
    );
  }

  Future<bool> updateExpenseStatus(
      String expenseId, ExpenseStatus status) async {
    return await runAsyncBool(
      operation: () async {
        final updatedExpense =
            await _updateExpenseStatusUseCase(expenseId, status);

        if (!isDisposed && updatedExpense != null) {
          // Atualizar nas listas
          final index = _expenses.indexWhere((e) => e.id == expenseId);
          if (index != -1) {
            _expenses[index] = updatedExpense;
          }

          final userIndex = _userExpenses.indexWhere((e) => e.id == expenseId);
          if (userIndex != -1) {
            _userExpenses[userIndex] = updatedExpense;
          }

          // Invalidar cache
          clearCache();

          notifyListeners();
          return true;
        }
        return false;
      },
      errorMessage: 'Erro ao atualizar status da despesa',
    );
  }

  void clearExpenses() {
    if (!isDisposed) {
      _expenses.clear();
      _userExpenses.clear();
      _currentUserId = null;
      _currentGroupId = null;
      clearCache();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}
