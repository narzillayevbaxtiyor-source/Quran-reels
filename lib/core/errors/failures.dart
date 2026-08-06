/// Custom exception and failure classes for the QuranReels application.
///
/// Implements clean architecture error handling with typed failures
/// that can be easily handled in the presentation layer.
library;

import 'package:equatable/equatable.dart';

/// Base failure class that all specific failures extend.
///
/// Each failure contains a user-friendly message and an optional
/// technical error message for debugging.
abstract class Failure extends Equatable {
  /// Human-readable error message suitable for display.
  final String message;

  /// Optional technical details for logging/debugging purposes.
  final String? technicalMessage;

  const Failure({
    required this.message,
    this.technicalMessage,
  });

  @override
  List<Object?> get props => [message, technicalMessage];
}

/// Failure representing server-side errors (5xx).
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.technicalMessage,
  });
}

/// Failure representing client-side / network errors.
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.technicalMessage,
  });
}

/// Failure representing authentication errors.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.technicalMessage,
  });
}

/// Failure representing cache / local storage errors.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.technicalMessage,
  });
}

/// Failure representing audio playback errors.
class AudioFailure extends Failure {
  const AudioFailure({
    required super.message,
    super.technicalMessage,
  });
}

/// Failure representing not found / empty result errors.
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.technicalMessage,
  });
}

/// Failure representing validation errors.
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.technicalMessage,
  });
}

/// Sealed class for API result handling using clean architecture patterns.
///
/// Use [ApiResult.success] for successful operations and
/// [ApiResult.failure] for operations that return a known [Failure].
sealed class ApiResult<T> {
  const ApiResult();

  /// Creates a successful result with [data].
  const factory ApiResult.success(T data) = ApiSuccess<T>;

  /// Creates a failure result with a [Failure].
  const factory ApiResult.failure(Failure failure) = ApiError<T>;

  /// Returns `true` if this result is a success.
  bool get isSuccess => this is ApiSuccess<T>;

  /// Returns `true` if this result is a failure.
  bool get isFailure => this is ApiError<T>;

  /// Gets the data if this is a success, otherwise throws.
  T get data => (this as ApiSuccess<T>).data;

  /// Gets the failure if this is a failure, otherwise throws.
  Failure get failure => (this as ApiError<T>).failure;

  /// Pattern matches the result and returns a value.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      ApiSuccess<T>(:final data) => onSuccess(data),
      ApiError<T>(:final failure) => onFailure(failure),
    };
  }
}

/// Successful API result.
class ApiSuccess<T> extends ApiResult<T> {
  @override
  final T data;
  const ApiSuccess(this.data);
}

/// Failed API result.
class ApiError<T> extends ApiResult<T> {
  @override
  final Failure failure;
  const ApiError(this.failure);
}
