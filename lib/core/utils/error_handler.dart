import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sistema centralizado de tratamento de erros do Billmate
/// Oferece widgets e métodos para exibir erros de forma consistente
class ErrorHandler {
  // Previne instanciação
  ErrorHandler._();

  /// Exibe um SnackBar de erro
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  /// Exibe um SnackBar de sucesso
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  /// Exibe um SnackBar de aviso
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.warningColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  /// Exibe um SnackBar de informação
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.infoColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  /// Exibe um diálogo de erro
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.error_outline,
          color: AppTheme.errorColor,
          size: 48,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionLabel),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  /// Exibe um diálogo de confirmação
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDestructive = false,
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );

    return result ?? false;
  }

  /// Formata mensagens de erro de forma amigável
  static String formatErrorMessage(dynamic error) {
    if (error == null) return 'Erro desconhecido';

    final errorString = error.toString();

    // Remove prefixos técnicos comuns
    final cleanError = errorString
        .replaceAll('Exception: ', '')
        .replaceAll('Error: ', '')
        .replaceAll('FirebaseException: ', '')
        .replaceAll('PlatformException: ', '');

    // Mensagens amigáveis para erros comuns
    if (cleanError.contains('network')) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    if (cleanError.contains('timeout')) {
      return 'A operação demorou muito. Tente novamente.';
    }
    if (cleanError.contains('permission')) {
      return 'Permissão negada. Verifique as configurações.';
    }
    if (cleanError.contains('not found')) {
      return 'Recurso não encontrado.';
    }
    if (cleanError.contains('already exists')) {
      return 'Este item já existe.';
    }

    return cleanError;
  }
}

/// Widget para exibir estado de erro
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Ops! Algo deu errado',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.paddingLarge),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir estado vazio
class EmptyView extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyView({
    Key? key,
    required this.message,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppTheme.paddingLarge),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir estado de carregamento
class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
