import 'package:logger/logger.dart' as log;


/// App-wide logger. Use instead of print() for structured logging.
/// In production, configure level to Level.warning or higher.
class AppLogger {
  AppLogger._();

  static final log.Logger _logger = log.Logger(
    printer: log.PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: log.DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: log.Level.trace,
  );

  static void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.t(message, error: error, stackTrace: stackTrace);

  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}
