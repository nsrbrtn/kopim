import 'package:firebase_core/firebase_core.dart';

import 'package:kopim/core/config/firebase_environment.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/firebase_runtime_guard.dart';

/// Гарантирует, что Firebase инициализирован перед обращением к сервисам.
Future<void> ensureFirebaseInitialized({LoggerService? logger}) async {
  if (hasFirebaseAppsSafely(
    onError: (Object error) {
      logger?.logError('Firebase.apps недоступен', error);
    },
  )) {
    return;
  }

  try {
    await Firebase.initializeApp(
      options: FirebaseEnvironmentConfig.currentPlatformOptions,
    );
  } on FirebaseException catch (error) {
    if (error.code == 'duplicate-app') {
      return;
    }
    logger?.logError('Не удалось инициализировать Firebase', error);
    rethrow;
  } catch (error) {
    logger?.logError('Неожиданная ошибка инициализации Firebase', error);
    rethrow;
  }
}
