import '../models/user_model.dart';

/// Local data source for auth caching. Used for offline support.
/// Cache user profile after login/API fetch; read on startup.
abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
}
