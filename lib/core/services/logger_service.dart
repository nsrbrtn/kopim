// lib/core/services/logger_service.dart
import 'package:logger/logger.dart';

class LoggerService {
  final Logger _logger = Logger(level: Level.debug);

  void logInfo(String message) => _logger.i(message);
  void logWarning(String message) => _logger.w(message);
  void logError(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  // Добавьте другие уровни по необходимости
}
