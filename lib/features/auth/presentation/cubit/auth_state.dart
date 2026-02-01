import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Auth UI states: Cubit emits only these; UI reacts to them.
/// No data or service access from UI — only state.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthSuccess extends AuthState {
  const AuthSuccess(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
