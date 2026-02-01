import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../models/user_model.dart';
import 'auth_local_datasource.dart';

/// SharedPreferences-based implementation of [AuthLocalDataSource].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  final LocalStorage _storage;

  static const _userKey = 'cached_user';

  @override
  Future<UserModel?> getCachedUser() async {
    final json = await _storage.read(_userKey);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      await _storage.delete(_userKey);
      return null;
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await _storage.write(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearCache() async {
    await _storage.delete(_userKey);
  }
}
