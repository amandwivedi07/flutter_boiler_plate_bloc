import 'package:firebase_auth/firebase_auth.dart';

import '../core/errors/failures.dart';
import '../core/errors/result.dart';
import '../features/auth/domain/entities/user_entity.dart';
import '../features/auth/data/models/user_model.dart';

/// Firebase wrapper: auth (and optional Firestore) only.
/// UI and Cubits never use Firebase directly; they use UseCases → Repository → this.
/// Structure ready for Google Sign-In: add [signInWithGoogle] that uses GoogleAuthProvider.
class FirebaseService {
  FirebaseService(this._auth);

  final FirebaseAuth _auth;

  /// Email & password sign-in. Returns [UserEntity] on success.
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return const FailureResult(UnknownFailure('No user returned'));
      return Success(_userToEntity(user));
    } on FirebaseAuthException catch (e) {
      return FailureResult(AuthFailure(e.message ?? e.code, code: e.code));
    }
  }

  /// Create account with email & password.
  Future<Result<UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return const FailureResult(UnknownFailure('No user returned'));
      return Success(_userToEntity(user));
    } on FirebaseAuthException catch (e) {
      return FailureResult(AuthFailure(e.message ?? e.code, code: e.code));
    }
  }

  /// Current user if signed in; null otherwise.
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      return Success(user != null ? _userToEntity(user) : null);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  /// Sign out. No Firebase logic in UI or Cubits — call via UseCase.
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  /// Id token for API interceptors (Dio auth header).
  Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken();
  }

  UserEntity _userToEntity(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    ).toEntity();
  }
}
