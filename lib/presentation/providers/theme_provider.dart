import 'package:flutter/material.dart';
// Nota: tema escuro removido — o app usará somente o tema claro.
import 'package:flutter/foundation.dart';
import '../../core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  // Mantemos a interface, mas forçamos sempre o tema claro.
  final ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => false;
  bool get isLightMode => true;
  bool get isSystemMode => false;

  ThemeProvider();

  /// toggleTheme é mantido para compatibilidade, mas não altera o tema
  /// já que a aplicação usa somente o tema claro.
  Future<void> toggleTheme() async {
    if (kDebugMode) {
      // apenas um hint em debug
      // ignore: avoid_print
      print('toggleTheme called but dark theme is disabled.');
    }
    return;
  }

  // Tema claro - usando AppTheme centralizado
  ThemeData get lightTheme => AppTheme.lightTheme;
}
