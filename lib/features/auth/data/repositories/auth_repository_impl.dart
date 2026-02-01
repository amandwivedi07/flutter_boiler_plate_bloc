import '../../../../core/errors/result.dart';
import '../../../../firebase/firebase_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Repository implementation: orchestrates Firebase (auth), API (profile), and cache.
/// Maps models to entities; returns Result for UseCases.
/// Uses local cache for offline support.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._firebaseService,
    this._remoteDataSource,
    this._localDataSource,
  );

  final FirebaseService _firebaseService;
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<Result<UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _firebaseService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    switch (result) {
      case Success(:final data):
        await _localDataSource.cacheUser(UserModel(
          id: data.id,
          email: data.email,
          displayName: data.displayName,
          photoUrl: data.photoUrl,
        ));
        return Success(data);
      case FailureResult():
        return result;
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    final result = await _firebaseService.getCurrentUser();
    switch (result) {
      case Success(:final data):
        if (data != null) {
          await _localDataSource.cacheUser(UserModel(
            id: data.id,
            email: data.email,
            displayName: data.displayName,
            photoUrl: data.photoUrl,
          ));
        }
        return Success(data);
      case FailureResult():
        return result;
    }
  }

  @override
  Future<Result<void>> signOut() async {
    await _localDataSource.clearCache();
    return _firebaseService.signOut();
  }

  @override
  Future<Result<UserEntity>> getUserProfile() async {
    final result = await _remoteDataSource.getUserProfile();
    switch (result) {
      case Success(:final data):
        await _localDataSource.cacheUser(data);
        return Success(data.toEntity());
      case FailureResult(:final failure):
        return FailureResult(failure);
    }
  }
}
