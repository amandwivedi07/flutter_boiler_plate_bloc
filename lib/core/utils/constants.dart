import '../config/env_config.dart';

/// App-wide constants. Environment-specific values come from [EnvConfig].
class AppConstants {
  AppConstants._();

  /// Use EnvConfig.apiBaseUrl. Falls back to dart-define if set.
  static String get apiBaseUrl =>
      const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: '',
      ).isEmpty
          ? EnvConfig.apiBaseUrl
          : const String.fromEnvironment('API_BASE_URL');
}
