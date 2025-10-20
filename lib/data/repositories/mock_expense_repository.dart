import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../core/constants/app_constants.dart';

class MockExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];

  @override
  Future<Expense?> createExpense(Expense expense) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 300));

    _expenses.add(expense);
    return expense;
  }

  @override
  Future<bool> deleteExpense(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      _expenses.removeAt(index);
      return true;
    }
    return false;
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _expenses.where((e) => e.categoryId == categoryId).toList();
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _expenses.where((e) {
      return e.date.isAfter(start.subtract(const Duration(days: 1))) &&
          e.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<Expense>> getExpensesByGroupId(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _expenses.where((e) => e.groupId == groupId).toList();
  }

  @override
  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _expenses.where((e) {
      return e.date.year == year && e.date.month == month;
    }).toList();
  }

  @override
  Future<List<Expense>> getExpensesByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _expenses.where((e) => e.createdByUserId == userId).toList();
  }

  @override
  Future<Map<String, double>> getExpensesByCategoryGrouped(
      String groupId, DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final groupExpenses = await getExpensesByGroupId(groupId);
    final filteredExpenses = groupExpenses.where((e) {
      return e.date.isAfter(start.subtract(const Duration(days: 1))) &&
          e.date.isBefore(end.add(const Duration(days: 1)));
    });

    final Map<String, double> result = {};
    for (final expense in filteredExpenses) {
      result[expense.categoryId] =
          (result[expense.categoryId] ?? 0) + expense.amount;
    }

    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlyExpensesSummary(
      String groupId, int year) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final groupExpenses = await getExpensesByGroupId(groupId);
    final yearExpenses = groupExpenses.where((e) => e.date.year == year);

    final List<Map<String, dynamic>> monthlySummary = [];
    for (int month = 1; month <= 12; month++) {
      final monthExpenses = yearExpenses.where((e) => e.date.month == month);
      final total = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);

      monthlySummary.add({
        'month': month,
        'total': total,
        'count': monthExpenses.length,
      });
    }

    return monthlySummary;
  }

  @override
  Future<List<Expense>> getPendingExpenses(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final groupExpenses = await getExpensesByGroupId(groupId);
    return groupExpenses
        .where((e) => e.status == ExpenseStatus.pending)
        .toList();
  }

  @override
  Future<List<Expense>> getRecurringExpenses() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _expenses.where((e) => e.isRecurring).toList();
  }

  @override
  Future<double> getTotalExpensesByGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final groupExpenses = await getExpensesByGroupId(groupId);
    return groupExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Future<double> getTotalExpensesByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final userExpenses = await getExpensesByUserId(userId);
    return userExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Future<List<Expense>> getUnsyncedExpenses() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _expenses.where((e) => !e.isSynced).toList();
  }

  @override
  Future<Map<String, double>> getUserBalances(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final groupExpenses = await getExpensesByGroupId(groupId);
    final Map<String, double> balances = {};

    for (final expense in groupExpenses) {
      for (final participant in expense.participants) {
        balances[participant.userId] =
            (balances[participant.userId] ?? 0) + participant.amount;
      }
    }

    return balances;
  }

  @override
  Future<void> markExpenseAsSynced(String expenseId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final index = _expenses.indexWhere((e) => e.id == expenseId);
    if (index != -1) {
      _expenses[index] = _expenses[index].copyWith(isSynced: true);
    }
  }

  @override
  Future<void> syncExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense.copyWith(isSynced: true);
    } else {
      _expenses.add(expense.copyWith(isSynced: true));
    }
  }

  @override
  Future<Expense?> updateExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense.copyWith(updatedAt: DateTime.now());
      return _expenses[index];
    }
    return null;
  }

  @override
  Stream<List<Expense>> watchGroupExpenses(String groupId) {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      return _expenses.where((e) => e.groupId == groupId).toList();
    });
  }

  @override
  Stream<List<Expense>> watchUserExpenses(String userId) {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      return _expenses.where((e) => e.createdByUserId == userId).toList();
    });
  }
}
