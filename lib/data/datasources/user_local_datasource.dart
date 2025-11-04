import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'local_database.dart';

abstract class UserLocalDataSource {
  Future<UserModel?> getUserById(String id);
  Future<UserModel?> getUserByEmail(String email);
  Future<List<UserModel>> getUsers();
  Future<String> insertUser(UserModel user);
  Future<int> updateUser(UserModel user);
  Future<int> deleteUser(String id);
  Future<UserModel?> getCurrentUser();
  Future<void> setCurrentUser(String userId);
  Future<void> clearCurrentUser();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final LocalDatabase localDatabase;

  UserLocalDataSourceImpl(this.localDatabase);

  @override
  Future<UserModel?> getUserById(String id) async {
    final db = await localDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await localDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<UserModel>> getUsers() async {
    final db = await localDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }

  @override
  Future<String> insertUser(UserModel user) async {
    final db = await localDatabase.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return user.id;
  }

  @override
  Future<int> updateUser(UserModel user) async {
    final db = await localDatabase.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<int> deleteUser(String id) async {
    final db = await localDatabase.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');

      if (userId == null) {
        return null;
      }

      return await getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setCurrentUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', userId);
    } catch (e) {
      // Log error
    }
  }

  @override
  Future<void> clearCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
    } catch (e) {
      // Log error
    }
  }
}
