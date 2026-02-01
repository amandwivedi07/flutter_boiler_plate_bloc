import 'package:equatable/equatable.dart';

/// Domain entity: framework-independent representation of a user.
/// UI and data layer map to/from this; domain layer only knows entities.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}
