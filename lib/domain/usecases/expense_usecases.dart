import '../repositories/expense_repository.dart';
import '../entities/expense.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';

class CreateExpenseUseCase {
  final ExpenseRepository expenseRepository;

  CreateExpenseUseCase(this.expenseRepository);

  Future<Expense?> call({
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
    try {
      final expense = Expense.create(
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
      return await expenseRepository.createExpense(expense);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

class GetGroupExpensesUseCase {
  final ExpenseRepository expenseRepository;

  GetGroupExpensesUseCase(this.expenseRepository);

  Future<List<Expense>> call(String groupId) async {
    try {
      return await expenseRepository.getExpensesByGroupId(groupId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

class GetUserExpensesUseCase {
  final ExpenseRepository expenseRepository;

  GetUserExpensesUseCase(this.expenseRepository);

  Future<List<Expense>> call(String userId) async {
    try {
      return await expenseRepository.getExpensesByUserId(userId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

class GetMonthlyExpensesUseCase {
  final ExpenseRepository expenseRepository;

  GetMonthlyExpensesUseCase(this.expenseRepository);

  Future<List<Expense>> call(int year, int month) async {
    try {
      return await expenseRepository.getExpensesByMonth(year, month);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

class UpdateExpenseStatusUseCase {
  final ExpenseRepository expenseRepository;

  UpdateExpenseStatusUseCase(this.expenseRepository);

  Future<Expense?> call(String expenseId, ExpenseStatus status) async {
    try {
      final expense = await expenseRepository.getExpenseById(expenseId);
      if (expense == null) {
        throw ServerFailure('Despesa não encontrada');
      }

      final updatedExpense = status == ExpenseStatus.paid
          ? expense.markAsPaid()
          : expense.markAsPending();

      return await expenseRepository.updateExpense(updatedExpense);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

class GetExpensesByCategoryUseCase {
  final ExpenseRepository expenseRepository;

  GetExpensesByCategoryUseCase(this.expenseRepository);

  Future<Map<String, double>> call(
      String groupId, DateTime start, DateTime end) async {
    try {
      return await expenseRepository.getExpensesByCategoryGrouped(
          groupId, start, end);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

class GetUserBalancesUseCase {
  final ExpenseRepository expenseRepository;

  GetUserBalancesUseCase(this.expenseRepository);

  Future<Map<String, double>> call(String groupId) async {
    try {
      return await expenseRepository.getUserBalances(groupId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
