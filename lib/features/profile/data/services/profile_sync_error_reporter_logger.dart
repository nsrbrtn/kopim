import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/domain/services/profile_sync_error_reporter.dart';

/// Логер для ошибок синхронизации прогресса профиля.
class LoggerProfileSyncErrorReporter implements ProfileSyncErrorReporter {
  LoggerProfileSyncErrorReporter({required LoggerService logger})
    : _logger = logger;

  final LoggerService _logger;

  @override
  void reportProgressSyncError({
    required String uid,
    required Object error,
    required StackTrace stackTrace,
  }) {
    _logger.logError(
      'Не удалось синхронизировать прогресс для uid=$uid',
      error,
    );
    _logger.logError('Стек синка прогресса: $stackTrace');
  }
}
