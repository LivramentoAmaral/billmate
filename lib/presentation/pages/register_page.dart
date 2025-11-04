import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  // Constantes de layout
  static const double _borderRadiusSmall = 16.0;
  static const double _iconSize = 28.0;
  static const double _logoIconSize = 40.0;
  static const double _logoContainerSize = 80.0;
  static const double _minPadding = 24.0;
  static const double _spacingSmall = 8.0;
  static const double _spacingMedium = 16.0;
  static const double _spacingLarge = 32.0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erro ao criar conta'),
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
          padding: const EdgeInsets.all(24),
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
                  Icons.account_balance_wallet,
                  size: _logoIconSize,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: _minPadding),

              Text(
                'Criar Conta',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: _spacingSmall),

              Text(
                'Preencha os dados abaixo',
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
                        controller: _nameController,
                        label: 'Nome completo',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          if (value.trim().length < 2) {
                            return 'Nome deve ter pelo menos 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: _spacingMedium),
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
                            return 'Email inválido';
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
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: _iconSize,
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
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar senha',
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: _iconSize,
                            color: colorScheme.onSurface.withAlpha(128),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirmação de senha é obrigatória';
                          }
                          if (value != _passwordController.text) {
                            return 'Senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: _minPadding),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return CustomButton(
                            text: 'Criar Conta',
                            onPressed: authProvider.isLoading ? null : _signUp,
                            isLoading: authProvider.isLoading,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: _minPadding),

              // Link para login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já tem uma conta? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withAlpha(128),
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Faça login',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
