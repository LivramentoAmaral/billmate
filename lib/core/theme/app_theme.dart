import 'package:flutter/material.dart';

/// Sistema centralizado de tema do Billmate
/// Define cores, estilos de texto e componentes padronizados
class AppTheme {
  // Previne instanciação
  AppTheme._();

  // ==================== CORES ====================

  /// Cores primárias
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  /// Cores de superfície - Light Mode
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Cores de superfície - Dark Mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);

  /// Cores de texto - Light Mode
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  /// Cores de texto - Dark Mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF757575);

  /// Cores de status
  static const Color successColor = Color(0xFF16A34A); // Verde - padronizado
  static const Color warningColor = Color(0xFFF59E0B); // Âmbar - padronizado
  static const Color errorColor = Color(0xFFDC2626); // Vermelho - padronizado
  static const Color infoColor = Color(0xFF0891B2); // Ciano - padronizado

  /// Cores neutras complementares
  static const Color neutral100 = Color(0xFFF9FAFB);
  static const Color neutral200 = Color(0xFFF3F4F6);
  static const Color neutral300 = Color(0xFFE5E7EB);
  static const Color neutral400 = Color(0xFFD1D5DB);
  static const Color neutral500 = Color(0xFF9CA3AF);
  static const Color neutral600 = Color(0xFF6B7280);
  static const Color neutral700 = Color(0xFF4B5563);
  static const Color neutral800 = Color(0xFF374151);

  /// Cores de categorias (para despesas) - Paleta derivada do tema primário
  /// Usa variações harmônicas para manter consistência visual
  static const Map<String, Color> categoryColors = {
    'alimentacao': Color(0xFFD946EF), // Rosa/Magenta - similar a primary
    'transporte': Color(0xFF0891B2), // Ciano azulado - complementar
    'moradia': Color(0xFF7C3AED), // Roxo médio - variação de primary
    'saude': Color(0xFF16A34A), // Verde - cor segura/sucesso
    'educacao': primaryColor, // Roxo primário
    'lazer': Color(0xFFDC2626), // Vermelho - energia/diversão
    'compras': Color(0xFFF59E0B), // Âmbar/Ouro - valor/premium
    'investimentos': Color(0xFF06B6D4), // Ciano - crescimento/futuro
    'outras': Color(0xFF6B7280), // Cinza - neutro
  };

  // ==================== TEMAS ====================

  /// Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme - Padronizado com paleta nova
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceLight,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimaryLight,
        onError: Colors.white,
        outline: neutral300,
        outlineVariant: neutral200,
      ),

      // Scaffold
      scaffoldBackgroundColor: backgroundLight,

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 2,
        color: cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input Decoration - Padronizado com neutros
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryLight,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimaryLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimaryLight,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondaryLight,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondaryLight,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textSecondaryLight,
        ),
      ),
    );
  }

  // NOTE: darkTheme removido intencionalmente — a aplicação usa apenas o tema claro.

  // ==================== UTILITÁRIOS ====================

  /// Retorna a cor de uma categoria
  static Color getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? categoryColors['outras']!;
  }

  /// Retorna a cor de status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pago':
        return successColor;
      case 'pendente':
        return warningColor;
      case 'vencido':
        return errorColor;
      default:
        return infoColor;
    }
  }

  /// Espaçamentos padrão
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  /// Border radius padrão
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusCircular = 100.0;

  /// Elevação padrão
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}
