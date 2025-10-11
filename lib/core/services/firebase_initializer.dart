import 'package:firebase_core/firebase_core.dart';

import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/firebase_options.dart';

/// Гарантирует, что Firebase инициализирован перед обращением к сервисам.
Future<void> ensureFirebaseInitialized({LoggerService? logger}) async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
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
