import 'package:equatable/equatable.dart';

/// Base class for all failures in the app.
/// Domain layer defines failures; data layer maps exceptions to these.
/// Keeps error handling framework-independent and testable.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server/API errors (4xx, 5xx, timeouts, etc.)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Authentication/authorization errors
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Validation errors (e.g. invalid input)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Unknown/unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred']);
}
