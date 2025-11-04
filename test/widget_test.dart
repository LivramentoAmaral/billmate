// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:billmate/presentation/providers/theme_provider.dart';

void main() {
  testWidgets('Theme provider smoke test', (WidgetTester tester) async {
    // Build a simple widget tree with ThemeProvider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              theme: themeProvider.lightTheme,
              // Tema escuro removido — uso apenas do tema claro
              home: const Scaffold(
                body: Center(
                  child: Text('Billmate Test'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Verify that our test widget is present
    expect(find.text('Billmate Test'), findsOneWidget);
  });
}
