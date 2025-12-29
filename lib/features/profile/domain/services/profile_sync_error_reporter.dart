import 'package:meta/meta.dart';

/// Репортинг ошибок синхронизации прогресса профиля.
@immutable
abstract class ProfileSyncErrorReporter {
  /// Сообщает об ошибке синхронизации прогресса.
  void reportProgressSyncError({
    required String uid,
    required Object error,
    required StackTrace stackTrace,
  });
}
