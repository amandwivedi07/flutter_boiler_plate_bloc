import '../../../../core/errors/result.dart';
import '../repositories/auth_repository.dart';

/// Use case: sign out current user.
class SignOutUseCase {
  SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.signOut();
}
