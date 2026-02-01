/// Environment configuration for dev/staging/prod.
/// Set via --dart-define=ENV=dev|staging|prod when building.
enum Environment {
  dev,
  staging,
  prod,
}

/// Centralized environment config. Use [EnvConfig.apiBaseUrl] etc.
class EnvConfig {
  EnvConfig._();

  static late Environment current;

  static String get apiBaseUrl => switch (current) {
        Environment.dev => 'https://dev-api.example.com',
        Environment.staging => 'https://staging-api.example.com',
        Environment.prod => 'https://api.example.com',
      };

  static bool get isDev => current == Environment.dev;
  static bool get isStaging => current == Environment.staging;
  static bool get isProd => current == Environment.prod;

  /// Initialize from String.fromEnvironment. Call in main() before runApp.
  static void init() {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    current = switch (env.toLowerCase()) {
      'staging' => Environment.staging,
      'prod' || 'production' => Environment.prod,
      _ => Environment.dev,
    };
  }
}
