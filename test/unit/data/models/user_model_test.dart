import 'package:clean_boilerplate/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates UserModel from map', () {
      final json = {
        'id': '123',
        'uid': 'ignored', // uid is fallback when id is present
        'email': 'user@test.com',
        'displayName': 'Test User',
        'photoUrl': 'https://photo.url',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, '123');
      expect(model.email, 'user@test.com');
      expect(model.displayName, 'Test User');
      expect(model.photoUrl, 'https://photo.url');
    });

    test('fromJson uses uid when id is missing', () {
      final json = {
        'uid': 'firebase-uid',
        'email': 'user@test.com',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, 'firebase-uid');
      expect(model.email, 'user@test.com');
      expect(model.displayName, isNull);
      expect(model.photoUrl, isNull);
    });

    test('toEntity returns UserEntity with same data', () {
      const model = UserModel(
        id: '1',
        email: 'a@b.com',
        displayName: 'Name',
        photoUrl: 'url',
      );

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.email, model.email);
      expect(entity.displayName, model.displayName);
      expect(entity.photoUrl, model.photoUrl);
    });

    test('toJson returns map matching fromJson input', () {
      const model = UserModel(
        id: '1',
        email: 'a@b.com',
        displayName: 'Name',
        photoUrl: 'url',
      );

      final json = model.toJson();
      final fromJson = UserModel.fromJson(json);

      expect(fromJson.id, model.id);
      expect(fromJson.email, model.email);
      expect(fromJson.displayName, model.displayName);
      expect(fromJson.photoUrl, model.photoUrl);
    });
  });
}
