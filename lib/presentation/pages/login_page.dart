import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Constantes de layout (seguindo o padrão do register_page)
  static const double _borderRadiusSmall = 16.0;
  static const double _logoIconSize = 40.0;
  static const double _logoContainerSize = 80.0;
  static const double _minPadding = 24.0;
  static const double _spacingSmall = 8.0;
  static const double _spacingMedium = 16.0;
  static const double _spacingLarge = 32.0;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erro ao fazer login'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_minPadding),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Logo - Gradiente usando tema
              Container(
                width: _logoContainerSize,
                height: _logoContainerSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withAlpha(204),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(_borderRadiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.attach_money,
                  size: _logoIconSize,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: _minPadding),

              Text(
                'Entrar',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: _spacingSmall),

              Text(
                'Entre com sua conta para continuar',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withAlpha(153),
                    ),
              ),
              const SizedBox(height: _spacingLarge),

              // Formulário
              Container(
                padding: const EdgeInsets.all(_minPadding),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(_borderRadiusSmall),
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email é obrigatório';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Digite um email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: _spacingMedium),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: colorScheme.onSurface.withAlpha(128),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Senha é obrigatória';
                          }
                          if (value.length < 6) {
                            return 'Senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: _spacingSmall),

                      // Link esqueci a senha
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Funcionalidade será implementada em breve'),
                              ),
                            );
                          },
                          child: Text(
                            'Esqueci minha senha',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: colorScheme.primary,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: _spacingMedium),

                      CustomButton(
                        text: 'Entrar',
                        onPressed: _signIn,
                      ),
                      const SizedBox(height: _spacingLarge),

                      // Link para criar conta
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Não tem uma conta? ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(128),
                                ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Crie uma agora',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
