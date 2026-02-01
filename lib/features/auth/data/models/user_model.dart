import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/user_entity.dart';

/// Data model: DTO from API/Firebase, maps to [UserEntity].
/// Data layer owns models; domain only knows entities.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
  });

  factory UserModel.fromJson(JsonMap json) {
    return UserModel(
      id: json['id'] as String? ?? json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName:
          json['displayName'] as String? ?? json['display_name'] as String?,
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String?,
    );
  }

  JsonMap toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
  };

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
  );
}
