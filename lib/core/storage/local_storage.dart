/// Abstract local storage contract. Implementations: SharedPreferences, Hive, etc.
/// Used by DataSources for caching; never by UI or Cubits.
abstract class LocalStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}
