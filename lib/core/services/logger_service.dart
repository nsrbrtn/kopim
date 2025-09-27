// lib/core/services/logger_service.dart
import 'package:logger/logger.dart';

class LoggerService {
  final Logger _logger = Logger(level: Level.debug);

  void logInfo(String message) => _logger.i(message);
  void logError(String message, [dynamic error]) => _logger.e(message, error: error);
// Добавьте другие уровни по необходимости
}