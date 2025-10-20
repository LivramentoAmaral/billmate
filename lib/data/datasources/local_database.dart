import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class LocalDatabase {
  static Database? _database;
  static LocalDatabase? _instance;

  LocalDatabase._internal();

  factory LocalDatabase() {
    _instance ??= LocalDatabase._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.localDatabaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        profilePicture TEXT,
        createdAt INTEGER NOT NULL,
        lastSyncAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE groups_table (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        adminId TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE group_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId TEXT NOT NULL,
        userId TEXT NOT NULL,
        role TEXT NOT NULL,
        joinedAt INTEGER NOT NULL,
        FOREIGN KEY (groupId) REFERENCES groups_table (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(groupId, userId)
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        color TEXT NOT NULL,
        iconCode TEXT NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        createdByUserId TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        categoryId TEXT NOT NULL,
        groupId TEXT NOT NULL,
        createdByUserId TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        date INTEGER NOT NULL,
        dueDate INTEGER,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurrencePattern TEXT,
        attachments TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (categoryId) REFERENCES categories (id),
        FOREIGN KEY (groupId) REFERENCES groups_table (id) ON DELETE CASCADE,
        FOREIGN KEY (createdByUserId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE expense_participants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expenseId TEXT NOT NULL,
        userId TEXT NOT NULL,
        amount REAL NOT NULL,
        percentage REAL NOT NULL,
        hasPaid INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (expenseId) REFERENCES expenses (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (id),
        UNIQUE(expenseId, userId)
      )
    ''');

    // Índices para melhor performance
    await db.execute('CREATE INDEX idx_expenses_groupId ON expenses (groupId)');
    await db.execute(
        'CREATE INDEX idx_expenses_categoryId ON expenses (categoryId)');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses (date)');
    await db.execute(
        'CREATE INDEX idx_expenses_createdByUserId ON expenses (createdByUserId)');
    await db.execute(
        'CREATE INDEX idx_group_members_groupId ON group_members (groupId)');
    await db.execute(
        'CREATE INDEX idx_group_members_userId ON group_members (userId)');
    await db.execute(
        'CREATE INDEX idx_expense_participants_expenseId ON expense_participants (expenseId)');
    await db.execute(
        'CREATE INDEX idx_expense_participants_userId ON expense_participants (userId)');
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    // Implementar migrações futuras aqui
    if (oldVersion < 2) {
      // Exemplo de migração
      // await db.execute('ALTER TABLE expenses ADD COLUMN newColumn TEXT');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.localDatabaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Transações
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Backup e restore
  Future<void> backup() async {
    // Implementar backup do banco local
  }

  Future<void> restore() async {
    // Implementar restore do banco local
  }
}
