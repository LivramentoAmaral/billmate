import 'package:get_it/get_it.dart';

import '../data/datasources/local_database.dart';
import '../data/datasources/user_local_datasource.dart';
import '../data/datasources/user_remote_datasource.dart';
import '../data/datasources/mock_user_remote_datasource.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/sqlite_expense_repository.dart';
import '../data/repositories/sqlite_category_repository.dart';
import '../data/repositories/sqlite_group_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/group_repository.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/expense_usecases.dart';
import '../domain/usecases/group_usecases.dart';
import '../presentation/providers/auth_provider.dart' as app_auth;
import '../presentation/providers/expense_provider.dart';
import '../presentation/providers/category_provider.dart';
import '../presentation/providers/group_provider.dart';
import '../presentation/providers/theme_provider.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Database
  final database = LocalDatabase();
  getIt.registerSingleton<LocalDatabase>(database);

  // Data sources
  getIt.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(getIt<LocalDatabase>()),
  );

  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => MockUserRemoteDataSource(),
  );

  // Repositories
  getIt.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(
      localDataSource: getIt<UserLocalDataSource>(),
      remoteDataSource: getIt<UserRemoteDataSource>(),
    ),
  );

  // Register interfaces pointing to the same implementation
  getIt.registerLazySingleton<UserRepository>(
    () => getIt<UserRepositoryImpl>(),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => getIt<UserRepositoryImpl>(),
  );

  // Use cases
  getIt.registerLazySingleton<SignInWithEmailPasswordUseCase>(
    () => SignInWithEmailPasswordUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignUpWithEmailPasswordUseCase>(
    () => SignUpWithEmailPasswordUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SendPasswordResetEmailUseCase>(
    () => SendPasswordResetEmailUseCase(getIt<AuthRepository>()),
  );

  // Expense repository
  getIt.registerLazySingleton<ExpenseRepository>(
    () => SqliteExpenseRepository(getIt<LocalDatabase>()),
  );

  // Category repository
  getIt.registerLazySingleton<CategoryRepository>(
    () => SqliteCategoryRepository(getIt<LocalDatabase>()),
  );

  // Group repository
  getIt.registerLazySingleton<GroupRepository>(
    () => SqliteGroupRepository(getIt<LocalDatabase>()),
  );

  // Expense use cases
  getIt.registerLazySingleton<CreateExpenseUseCase>(
    () => CreateExpenseUseCase(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<GetGroupExpensesUseCase>(
    () => GetGroupExpensesUseCase(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<GetUserExpensesUseCase>(
    () => GetUserExpensesUseCase(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<GetMonthlyExpensesUseCase>(
    () => GetMonthlyExpensesUseCase(getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton<UpdateExpenseStatusUseCase>(
    () => UpdateExpenseStatusUseCase(getIt<ExpenseRepository>()),
  );

  // Group use cases
  getIt.registerLazySingleton<CreateGroupUseCase>(
    () => CreateGroupUseCase(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<GetUserGroupsUseCase>(
    () => GetUserGroupsUseCase(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<AddMemberToGroupUseCase>(
    () => AddMemberToGroupUseCase(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<RemoveMemberFromGroupUseCase>(
    () => RemoveMemberFromGroupUseCase(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<UpdateMemberRoleUseCase>(
    () => UpdateMemberRoleUseCase(getIt<GroupRepository>()),
  );

  // Providers - Usando singletons para manter estado consistente
  getIt.registerLazySingleton<ThemeProvider>(
    () => ThemeProvider(),
  );

  getIt.registerLazySingleton<app_auth.AuthProvider>(
    () => app_auth.AuthProvider(
      signInUseCase: getIt<SignInWithEmailPasswordUseCase>(),
      signUpUseCase: getIt<SignUpWithEmailPasswordUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      userRepository: getIt<UserRepository>(),
    ),
  );

  getIt.registerLazySingleton<ExpenseProvider>(
    () => ExpenseProvider(
      createExpenseUseCase: getIt<CreateExpenseUseCase>(),
      getGroupExpensesUseCase: getIt<GetGroupExpensesUseCase>(),
      updateExpenseStatusUseCase: getIt<UpdateExpenseStatusUseCase>(),
      getUserExpensesUseCase: getIt<GetUserExpensesUseCase>(),
      getMonthlyExpensesUseCase: getIt<GetMonthlyExpensesUseCase>(),
    ),
  );

  getIt.registerLazySingleton<CategoryProvider>(
    () => CategoryProvider(getIt<CategoryRepository>()),
  );

  getIt.registerLazySingleton<GroupProvider>(
    () => GroupProvider(
      createGroupUseCase: getIt<CreateGroupUseCase>(),
      getUserGroupsUseCase: getIt<GetUserGroupsUseCase>(),
      addMemberToGroupUseCase: getIt<AddMemberToGroupUseCase>(),
      removeMemberFromGroupUseCase: getIt<RemoveMemberFromGroupUseCase>(),
      updateMemberRoleUseCase: getIt<UpdateMemberRoleUseCase>(),
    ),
  );
}

void resetDependencies() {
  getIt.reset();
}
