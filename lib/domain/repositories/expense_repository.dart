import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<Expense?> getExpenseById(String id);
  Future<List<Expense>> getExpensesByGroupId(String groupId);
  Future<List<Expense>> getExpensesByUserId(String userId);
  Future<List<Expense>> getExpensesByCategory(String categoryId);
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<List<Expense>> getExpensesByMonth(int year, int month);
  Future<List<Expense>> getPendingExpenses(String groupId);
  Future<List<Expense>> getRecurringExpenses();
  Future<Expense?> createExpense(Expense expense);
  Future<Expense?> updateExpense(Expense expense);
  Future<bool> deleteExpense(String id);
  Future<void> syncExpense(Expense expense);
  Future<List<Expense>> getUnsyncedExpenses();
  Future<void> markExpenseAsSynced(String expenseId);
  Stream<List<Expense>> watchGroupExpenses(String groupId);
  Stream<List<Expense>> watchUserExpenses(String userId);

  // Relatórios e estatísticas
  Future<double> getTotalExpensesByGroup(String groupId);
  Future<double> getTotalExpensesByUser(String userId);
  Future<Map<String, double>> getExpensesByCategoryGrouped(
      String groupId, DateTime start, DateTime end);
  Future<List<Map<String, dynamic>>> getMonthlyExpensesSummary(
      String groupId, int year);
  Future<Map<String, double>> getUserBalances(String groupId);
}
