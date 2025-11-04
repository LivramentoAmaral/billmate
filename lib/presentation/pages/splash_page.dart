import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    // Aguarda um pouco para mostrar a splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authProvider = context.read<AuthProvider>();

      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do app - gradiente com cores da paleta
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withAlpha(204), // 80% opacity
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withAlpha(51), // 20% opacity
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.account_balance_wallet,
                    size: 60,
                    color: Colors.white,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Nome do app
            Text(
              'Billmate',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Gerencie suas finanças em grupo',
              style: TextStyle(
                color: colorScheme.onSurface.withAlpha(153), // 60% opacity
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator com cor primária
            SpinKitWave(
              color: colorScheme.primary,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
