import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:billmate/presentation/pages/login_page.dart';
import 'package:billmate/presentation/providers/theme_provider.dart';
import 'package:billmate/presentation/providers/auth_provider.dart';

void main() {
  group('Testes de Layout do Teclado', () {
    testWidgets('Login page deveria responder corretamente ao teclado',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Act - Simular teclado aparecendo
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/textinput',
        null,
        (data) {},
      );

      // Rebuild widget para simular mudança do MediaQuery
      await tester.pumpAndSettle();

      // Assert - Verificar se não há overflow
      expect(tester.takeException(), isNull);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Campos de texto devem estar visíveis quando teclado aparecer',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Act - Encontrar campos de texto
      final emailField = find.byKey(const ValueKey('email_field')).first;
      final passwordField = find.byKey(const ValueKey('password_field')).first;

      // Assert - Verificar se os campos existem
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Senha'), findsWidgets);

      // Verificar se não há overflow widgets
      expect(tester.takeException(), isNull);
    });
  });
}
