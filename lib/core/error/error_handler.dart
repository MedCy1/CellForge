import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_error.dart';
import 'result.dart';
import '../constants/app_constants.dart';

/// Gestionnaire centralisé des erreurs
class ErrorHandler {
  /// Convertir une exception en AppError
  static AppError fromException(dynamic exception) {
    if (exception is AppError) {
      return exception;
    }
    
    if (exception is AuthException) {
      return AuthenticationError(
        message: exception.message,
        code: exception.statusCode,
        originalError: exception,
      );
    }
    
    if (exception is PostgrestException) {
      return StorageError(
        message: exception.message,
        code: exception.code,
        originalError: exception,
      );
    }
    
    // Erreurs réseau génériques
    if (exception.toString().contains('SocketException') ||
        exception.toString().contains('TimeoutException') ||
        exception.toString().contains('HandshakeException')) {
      return const NetworkError(
        message: 'Problème de connexion réseau',
        code: 'NETWORK_ERROR',
      );
    }
    
    return UnknownError(
      message: exception.toString(),
      originalError: exception,
    );
  }
  
  /// Wrapper pour exécuter du code et capturer les erreurs
  static Future<Result<T>> safeCall<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (e) {
      return Result.failure(fromException(e));
    }
  }
  
  /// Wrapper synchrone pour exécuter du code et capturer les erreurs
  static Result<T> safeCallSync<T>(T Function() operation) {
    try {
      final result = operation();
      return Result.success(result);
    } catch (e) {
      return Result.failure(fromException(e));
    }
  }
  
  /// Afficher un snackbar d'erreur
  static void showErrorSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getUserFriendlyMessage(error),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error.type),
        duration: AppConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Obtenir une icône pour le type d'erreur
  static IconData _getErrorIcon(AppErrorType type) {
    return switch (type) {
      AppErrorType.network => Icons.wifi_off,
      AppErrorType.authentication => Icons.lock,
      AppErrorType.validation => Icons.error_outline,
      AppErrorType.storage => Icons.storage,
      AppErrorType.engine => Icons.settings,
      AppErrorType.unknown => Icons.help_outline,
    };
  }
  
  /// Obtenir une couleur pour le type d'erreur
  static Color _getErrorColor(AppErrorType type) {
    return switch (type) {
      AppErrorType.network => Colors.orange,
      AppErrorType.authentication => Colors.red,
      AppErrorType.validation => Colors.amber,
      AppErrorType.storage => Colors.purple,
      AppErrorType.engine => Colors.blue,
      AppErrorType.unknown => Colors.grey,
    };
  }
  
  /// Convertir un message technique en message utilisateur
  static String _getUserFriendlyMessage(AppError error) {
    return switch (error.type) {
      AppErrorType.network => 'Problème de connexion. Vérifiez votre réseau.',
      AppErrorType.authentication => 'Erreur d\'authentification. Reconnectez-vous.',
      AppErrorType.validation => 'Données invalides: ${error.message}',
      AppErrorType.storage => 'Erreur de sauvegarde. Réessayez plus tard.',
      AppErrorType.engine => 'Erreur du moteur de jeu: ${error.message}',
      AppErrorType.unknown => 'Erreur inattendue: ${error.message}',
    };
  }
  
  /// Log de debug pour les erreurs (en mode debug seulement)
  static void logError(AppError error, [StackTrace? stackTrace]) {
    assert(() {
      debugPrint('🚨 AppError: ${error.type} - ${error.message}');
      if (error.code != null) {
        debugPrint('   Code: ${error.code}');
      }
      if (error.originalError != null) {
        debugPrint('   Original: ${error.originalError}');
      }
      if (stackTrace != null) {
        debugPrint('   Stack: $stackTrace');
      }
      return true;
    }());
  }
}