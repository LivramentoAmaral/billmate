import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/dependency_injection.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/group_provider.dart';
import 'presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar injeção de dependência
  await setupDependencies();

  runApp(BillmateApp());
}

class BillmateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => getIt<ThemeProvider>(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<ExpenseProvider>(
          create: (_) => getIt<ExpenseProvider>(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => getIt<CategoryProvider>(),
        ),
        ChangeNotifierProvider<GroupProvider>(
          create: (_) => getIt<GroupProvider>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Billmate',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: SplashPage(),
          );
        },
      ),
    );
  }
}
