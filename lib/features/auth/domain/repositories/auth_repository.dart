import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../entities/user_entity.dart';

/// Abstract auth repository — domain layer defines the contract.
/// Implementations live in data layer; UseCases depend only on this.
abstract class AuthRepository {
  /// Signs in with email and password (e.g. via Firebase).
  /// Returns [UserEntity] on success or [Failure] via [Result].
  Future<Result<UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Returns current user if signed in; null otherwise.
  Future<Result<UserEntity?>> getCurrentUser();

  /// Signs out (e.g. Firebase signOut).
  Future<Result<void>> signOut();

  /// Fetches user profile from API (example of Dio flow).
  /// DataSource → Repository → UseCase → Cubit.
  Future<Result<UserEntity>> getUserProfile();
}
