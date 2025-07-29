import 'app_error.dart';

/// Pattern Result pour une gestion d'erreur type-safe
sealed class Result<T> {
  const Result();
  
  /// Créer un résultat de succès
  factory Result.success(T data) = Success<T>;
  
  /// Créer un résultat d'erreur
  factory Result.failure(AppError error) = Failure<T>;
  
  /// Vérifier si c'est un succès
  bool get isSuccess => this is Success<T>;
  
  /// Vérifier si c'est un échec
  bool get isFailure => this is Failure<T>;
  
  /// Propriétés abstraites à implémenter
  T? get data;
  AppError? get error;
  
  /// Transformer le résultat avec une fonction
  Result<R> map<R>(R Function(T) transform) {
    return switch (this) {
      Success<T>(data: final data) => Result.success(transform(data)),
      Failure<T>(error: final error) => Result.failure(error),
    };
  }
  
  /// Enchaîner des opérations qui peuvent échouer
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    return switch (this) {
      Success<T>(data: final data) => transform(data),
      Failure<T>(error: final error) => Result.failure(error),
    };
  }
  
  /// Exécuter une action sur le succès
  Result<T> onSuccess(void Function(T) action) {
    if (this case Success<T>(data: final data)) {
      action(data);
    }
    return this;
  }
  
  /// Exécuter une action sur l'échec
  Result<T> onFailure(void Function(AppError) action) {
    if (this case Failure<T>(error: final error)) {
      action(error);
    }
    return this;
  }
  
  /// Obtenir la valeur ou une valeur par défaut
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(data: final data) => data,
      Failure<T>() => defaultValue,
    };
  }
  
  /// Obtenir la valeur ou lever une exception
  T getOrThrow() {
    return switch (this) {
      Success<T>(data: final data) => data,
      Failure<T>(error: final error) => throw error,
    };
  }
}

/// Résultat de succès
final class Success<T> extends Result<T> {
  final T _data;
  
  const Success(this._data);
  
  @override
  T get data => _data;
  
  @override
  AppError? get error => null;
  
  @override
  String toString() => 'Success($_data)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && runtimeType == other.runtimeType && _data == other._data;
  
  @override
  int get hashCode => _data.hashCode;
}

/// Résultat d'échec
final class Failure<T> extends Result<T> {
  final AppError _error;
  
  const Failure(this._error);
  
  @override
  T? get data => null;
  
  @override
  AppError get error => _error;
  
  @override
  String toString() => 'Failure($_error)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> && runtimeType == other.runtimeType && _error == other._error;
  
  @override
  int get hashCode => _error.hashCode;
}