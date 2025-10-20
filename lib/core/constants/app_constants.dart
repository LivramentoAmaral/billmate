class AppConstants {
  // Database
  static const String localDatabaseName = 'billmate_local.db';
  static const int databaseVersion = 1;

  // Collections MongoDB
  static const String usersCollection = 'users';
  static const String groupsCollection = 'groups';
  static const String expensesCollection = 'expenses';
  static const String categoriesCollection = 'categories';

  // Categories predefinidas
  static const List<String> defaultCategories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Educação',
    'Lazer',
    'Compras',
    'Serviços',
    'Outros',
  ];

  // Notification channels
  static const String reminderChannelId = 'expense_reminders';
  static const String reminderChannelName = 'Lembretes de Despesas';

  // Shared Preferences Keys
  static const String keyUserId = 'user_id';
  static const String keyActiveGroupId = 'active_group_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLastSyncTime = 'last_sync_time';
}

enum ExpenseType { fixed, variable }

enum ExpenseStatus { pending, paid }

enum UserRole { admin, member }

enum ThemeMode { light, dark, system }
