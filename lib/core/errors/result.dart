import 'failures.dart';

/// Result type for centralized error handling.
/// Represents either success (Right) or failure (Left) — similar to Either.
/// UseCases return Result; Cubits map Result to UI states (Success/Error).
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
}
