import '../../../../core/errors/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: fetch user profile from API (example Dio flow).
/// Flow: RemoteDataSource (Dio) → Repository → UseCase → Cubit → UI.
class GetUserProfileUseCase {
  GetUserProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> call() => _repository.getUserProfile();
}
