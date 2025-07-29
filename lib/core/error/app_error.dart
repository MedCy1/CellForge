/// Types d'erreurs de l'application
enum AppErrorType {
  network,
  authentication,
  validation,
  storage,
  engine,
  unknown,
}

/// Classe de base pour toutes les erreurs de l'application
abstract class AppError {
  final String message;
  final AppErrorType type;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    required this.type,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppError($type): $message${code != null ? ' (Code: $code)' : ''}';
}

/// Erreurs réseau (Supabase, API)
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
  }) : super(type: AppErrorType.network);
}

/// Erreurs d'authentification
class AuthenticationError extends AppError {
  const AuthenticationError({
    required super.message,
    super.code,
    super.originalError,
  }) : super(type: AppErrorType.authentication);
}

/// Erreurs de validation (input utilisateur)
class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    super.code,
    super.originalError,
  }) : super(type: AppErrorType.validation);
}

/// Erreurs de stockage/base de données
class StorageError extends AppError {
  const StorageError({
    required super.message,
    super.code,
    super.originalError,
  }) : super(type: AppErrorType.storage);
}

/// Erreurs des moteurs de jeu
class EngineError extends AppError {
  const EngineError({
    required super.message,
    super.code,
    super.originalError,
  }) : super(type: AppErrorType.engine);
}

/// Erreurs inconnues
class UnknownError extends AppError {
  const UnknownError({
    required super.message,
    super.code,
    super.originalError,
  }) : super(type: AppErrorType.unknown);
}