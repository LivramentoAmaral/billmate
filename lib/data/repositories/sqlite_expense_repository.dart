import 'package:sqflite/sqflite.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/local_database.dart';
import '../models/expense_model.dart';

class SqliteExpenseRepository implements ExpenseRepository {
  final LocalDatabase _localDatabase;

  SqliteExpenseRepository(this._localDatabase);

  @override
  Future<Expense?> createExpense(Expense expense) async {
    try {
      final db = await _localDatabase.database;

      await db.transaction((txn) async {
        // Inserir a despesa
        await txn.insert(
          'expenses',
          ExpenseModel.fromEntity(expense).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Inserir os participantes
        for (final participant in expense.participants) {
          await txn.insert(
            'expense_participants',
            {
              'expenseId': expense.id,
              'userId': participant.userId,
              'amount': participant.amount,
              'percentage': participant.percentage,
              'hasPaid': participant.hasPaid ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      return expense;
    } catch (e) {
      print('Erro ao criar despesa: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteExpense(String id) async {
    try {
      final db = await _localDatabase.database;

      final result = await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );

      return result > 0;
    } catch (e) {
      print('Erro ao deletar despesa: $e');
      return false;
    }
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    try {
      final db = await _localDatabase.database;

      final expenseResults = await db.query(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (expenseResults.isEmpty) return null;

      final participantsResults = await db.query(
        'expense_participants',
        where: 'expenseId = ?',
        whereArgs: [id],
      );

      final participants = participantsResults
          .map((p) => ExpenseParticipant(
                userId: p['userId'] as String,
                amount: p['amount'] as double,
                percentage: p['percentage'] as double,
                hasPaid: (p['hasPaid'] as int) == 1,
              ))
          .toList();

      return ExpenseModel.fromMap(expenseResults.first, participants)
          .toEntity();
    } catch (e) {
      print('Erro ao buscar despesa por ID: $e');
      return null;
    }
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    try {
      final db = await _localDatabase.database;

      final results = await db.query(
        'expenses',
        where: 'categoryId = ?',
        whereArgs: [categoryId],
        orderBy: 'date DESC',
      );

      return await _mapExpensesWithParticipants(results);
    } catch (e) {
      print('Erro ao buscar despesas por categoria: $e');
      return [];
    }
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    try {
      final db = await _localDatabase.database;

      final results = await db.query(
        'expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
        orderBy: 'date DESC',
      );

      return await _mapExpensesWithParticipants(results);
    } catch (e) {
      print('Erro ao buscar despesas por período: $e');
      return [];
    }
  }

  @override
  Future<List<Expense>> getExpensesByGroupId(String groupId) async {
    try {
      final db = await _localDatabase.database;

      final results = await db.query(
        'expenses',
        where: 'groupId = ?',
        whereArgs: [groupId],
        orderBy: 'date DESC',
      );

      return await _mapExpensesWithParticipants(results);
    } catch (e) {
      print('Erro ao buscar despesas do grupo: $e');
      return [];
    }
  }

  @override
  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      return await getExpensesByDateRange(startDate, endDate);
    } catch (e) {
      print('Erro ao buscar despesas do mês: $e');
      return [];
    }
  }

  @override
  Future<List<Expense>> getExpensesByUserId(String userId) async {
    try {
      final db = await _localDatabase.database;

      final results = await db.query(
        'expenses',
        where: 'createdByUserId = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );

      return await _mapExpensesWithParticipants(results);
    } catch (e) {
      print('Erro ao buscar despesas do usuário: $e');
      return [];
    }
  }

  @override
  Future<Map<String, double>> getExpensesByCategoryGrouped(
      String groupId, DateTime start, DateTime end) async {
    try {
      final db = await _localDatabase.database;

      final results = await db.rawQuery('''
        SELECT c.name as categoryName, SUM(e.amount) as total
        FROM expenses e
        INNER JOIN categories c ON e.categoryId = c.id
        WHERE e.groupId = ? AND e.date >= ? AND e.date <= ?
        GROUP BY e.categoryId, c.name
      ''', [groupId, start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);

      final Map<String, double> grouped = {};
      for (final result in results) {
        grouped[result['categoryName'] as String] = result['total'] as double;
      }

      return grouped;
    } catch (e) {
      print('Erro ao agrupar despesas por categoria: $e');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlyExpensesSummary(
      String groupId, int year) async {
    try {
      final db = await _localDatabase.database;

      final results = await db.rawQuery('''
        SELECT 
          strftime('%m', datetime(date/1000, 'unixepoch')) as month,
          SUM(amount) as total,
          COUNT(*) as count
        FROM expenses
        WHERE groupId = ? AND strftime('%Y', datetime(date/1000, 'unixepoch')) = ?
        GROUP BY strftime('%m', datetime(date/1000, 'unixepoch'))
        ORDER BY month
      ''', [groupId, year.toString()]);

      return results
          .map((result) => {
                'month': int.parse(result['month'] as String),
                'total': result['total'] as double,
                'count': result['count'] as int,
              })
          .toList();
    } catch (e) {
      print('Erro ao obter resumo mensal: $e');
      return [];
    }
  }

  @override
  Future<List<Expense>> getPendingExpenses(String groupId) async {
    try {
      final db = await _localDatabase.database;

      final results = await db.query(
        'expenses',
        where: 'groupId = ? AND status = ?',
        whereArgs: [groupId, ExpenseStatus.pending.name],
        orderBy: 'date DESC',
      );

      return await _mapExpensesWithParticipants(results);
    } catch (e) {
      print('Erro ao buscar despesas pendentes: $e');
      return [];
    }
  }

  @override
  Future<List<Expense>> getRecurringExpenses() async {
    try {
      final db = await _localDatabase.database;

      final results = await db.query(
        'expenses',
        where: 'isRecurring = ?',
        whereArgs: [1],
        orderBy: 'date DESC',
      );

      return await _mapExpensesWithParticipants(results);
    } catch (e) {
      print('Erro ao buscar despesas recorrentes: $e');
      return [];
    }
  }

  @override
  Future<double> getTotalExpensesByGroup(String groupId) async {
    try {
      final db = await _localDatabase.database;

      final result = await db.rawQuery('''
        SELECT SUM(amount) as total
        FROM expenses
        WHERE groupId = ?
      ''', [groupId]);

      return (result.first['total'] as double?) ?? 0.0;
    } catch (e) {
      print('Erro ao calcular total do grupo: $e');
      return 0.0;
    }
  }

  @override
  Future<double> getTotalExpensesByUser(String userId) async {
    try {
      final db = await _localDatabase.database;

      final result = await db.rawQuery('''
        SELECT SUM(amount) as total
        FROM expenses
        WHERE createdByUserId = ?
      ''', [userId]);

      return (result.first['total'] as double?) ?? 0.0;
    } catch (e) {
      print('Erro ao calcular total do usuário: $e');
      return 0.0;
    }
  }

  @override
  Future<List<Expense>> getUnsyncedExpenses() async {
    try {
      final db = await _localDatabase.database;

      final results = await db.query(
        'expenses',
        where: 'isSynced = ?',
        whereArgs: [0],
        orderBy: 'updatedAt DESC',
      );

      return await _mapExpensesWithParticipants(results);
    } catch (e) {
      print('Erro ao buscar despesas não sincronizadas: $e');
      return [];
    }
  }

  @override
  Future<Map<String, double>> getUserBalances(String groupId) async {
    try {
      final db = await _localDatabase.database;

      final results = await db.rawQuery('''
        SELECT ep.userId, SUM(ep.amount) as total
        FROM expense_participants ep
        INNER JOIN expenses e ON ep.expenseId = e.id
        WHERE e.groupId = ?
        GROUP BY ep.userId
      ''', [groupId]);

      final Map<String, double> balances = {};
      for (final result in results) {
        balances[result['userId'] as String] = result['total'] as double;
      }

      return balances;
    } catch (e) {
      print('Erro ao calcular saldos dos usuários: $e');
      return {};
    }
  }

  @override
  Future<void> markExpenseAsSynced(String expenseId) async {
    try {
      final db = await _localDatabase.database;

      await db.update(
        'expenses',
        {'isSynced': 1},
        where: 'id = ?',
        whereArgs: [expenseId],
      );
    } catch (e) {
      print('Erro ao marcar despesa como sincronizada: $e');
    }
  }

  @override
  Future<void> syncExpense(Expense expense) async {
    try {
      final db = await _localDatabase.database;

      await db.transaction((txn) async {
        // Atualizar a despesa
        await txn.update(
          'expenses',
          ExpenseModel.fromEntity(expense.copyWith(isSynced: true)).toMap(),
          where: 'id = ?',
          whereArgs: [expense.id],
        );

        // Deletar participantes antigos
        await txn.delete(
          'expense_participants',
          where: 'expenseId = ?',
          whereArgs: [expense.id],
        );

        // Inserir participantes atualizados
        for (final participant in expense.participants) {
          await txn.insert(
            'expense_participants',
            {
              'expenseId': expense.id,
              'userId': participant.userId,
              'amount': participant.amount,
              'percentage': participant.percentage,
              'hasPaid': participant.hasPaid ? 1 : 0,
            },
          );
        }
      });
    } catch (e) {
      print('Erro ao sincronizar despesa: $e');
    }
  }

  @override
  Future<Expense?> updateExpense(Expense expense) async {
    try {
      final db = await _localDatabase.database;

      await db.transaction((txn) async {
        // Atualizar a despesa
        await txn.update(
          'expenses',
          ExpenseModel.fromEntity(expense.copyWith(
            updatedAt: DateTime.now(),
            isSynced: false,
          )).toMap(),
          where: 'id = ?',
          whereArgs: [expense.id],
        );

        // Deletar participantes antigos
        await txn.delete(
          'expense_participants',
          where: 'expenseId = ?',
          whereArgs: [expense.id],
        );

        // Inserir participantes atualizados
        for (final participant in expense.participants) {
          await txn.insert(
            'expense_participants',
            {
              'expenseId': expense.id,
              'userId': participant.userId,
              'amount': participant.amount,
              'percentage': participant.percentage,
              'hasPaid': participant.hasPaid ? 1 : 0,
            },
          );
        }
      });

      return expense.copyWith(updatedAt: DateTime.now(), isSynced: false);
    } catch (e) {
      print('Erro ao atualizar despesa: $e');
      return null;
    }
  }

  @override
  Stream<List<Expense>> watchGroupExpenses(String groupId) {
    // Para implementação de stream, poderia usar um StreamController
    // Por agora, retornamos um stream que faz polling
    return Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => getExpensesByGroupId(groupId));
  }

  @override
  Stream<List<Expense>> watchUserExpenses(String userId) {
    // Para implementação de stream, poderia usar um StreamController
    // Por agora, retornamos um stream que faz polling
    return Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => getExpensesByUserId(userId));
  }

  // Método auxiliar para mapear despesas com participantes
  Future<List<Expense>> _mapExpensesWithParticipants(
      List<Map<String, dynamic>> expenseResults) async {
    if (expenseResults.isEmpty) return [];

    final db = await _localDatabase.database;
    final List<Expense> expenses = [];

    for (final expenseMap in expenseResults) {
      final expenseId = expenseMap['id'] as String;

      final participantsResults = await db.query(
        'expense_participants',
        where: 'expenseId = ?',
        whereArgs: [expenseId],
      );

      final participants = participantsResults
          .map((p) => ExpenseParticipant(
                userId: p['userId'] as String,
                amount: p['amount'] as double,
                percentage: p['percentage'] as double,
                hasPaid: (p['hasPaid'] as int) == 1,
              ))
          .toList();

      expenses.add(ExpenseModel.fromMap(expenseMap, participants).toEntity());
    }

    return expenses;
  }
}
