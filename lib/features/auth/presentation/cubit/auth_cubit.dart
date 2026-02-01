import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/result.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_state.dart';

/// One Cubit per feature. Cubit only calls UseCases; never data or services.
/// Emits Initial, Loading, Success, Error — UI only reacts to these.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._loginUseCase,
    this._getCurrentUserUseCase,
    this._getUserProfileUseCase,
    this._signOutUseCase,
  ) : super(const AuthInitial());

  final LoginUseCase _loginUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final SignOutUseCase _signOutUseCase;

  /// Login flow (Firebase Auth): UseCase → Repository → FirebaseService.
  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await _loginUseCase.call(email: email, password: password);
    switch (result) {
      case Success(:final data):
        emit(AuthSuccess(data));
      case FailureResult(:final failure):
        emit(AuthError(failure.message));
    }
  }

  /// Check current user on app start (e.g. splash).
  Future<void> checkCurrentUser() async {
    emit(const AuthLoading());
    final result = await _getCurrentUserUseCase.call();
    switch (result) {
      case Success(:final data):
        if (data != null) {
          emit(AuthSuccess(data));
        } else {
          emit(const AuthInitial());
        }
      case FailureResult(:final failure):
        emit(AuthError(failure.message));
    }
  }

  /// Example API flow: Dio → DataSource → Repository → UseCase → Cubit → UI.
  Future<void> loadUserProfile() async {
    emit(const AuthLoading());
    final result = await _getUserProfileUseCase.call();
    switch (result) {
      case Success(:final data):
        emit(AuthSuccess(data));
      case FailureResult(:final failure):
        emit(AuthError(failure.message));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    final result = await _signOutUseCase.call();
    switch (result) {
      case Success():
        emit(const AuthInitial());
      case FailureResult(:final failure):
        emit(AuthError(failure.message));
    }
  }
}
