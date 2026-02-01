import '../../../../core/errors/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: login with email and password.
/// Cubit calls only UseCases; UseCase calls only Repository (domain contract).
class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.loginWithEmail(email: email, password: password);
  }
}
