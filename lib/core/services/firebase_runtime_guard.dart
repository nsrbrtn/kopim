import 'package:firebase_core/firebase_core.dart';

import 'package:kopim/core/utils/web_platform_utils.dart';

/// Безопасно проверяет доступность уже инициализированных Firebase app-ов.
///
/// На iOS web прямой доступ к `Firebase.apps` может падать из-за JS interop,
/// поэтому там всегда возвращаем `false` и даем коду использовать ручной
/// `initializeApp` с обработкой `duplicate-app`.
bool hasFirebaseAppsSafely({void Function(Object error)? onError}) {
  if (isWebSafari()) {
    return false;
  }

  try {
    return Firebase.apps.isNotEmpty;
  } catch (error) {
    onError?.call(error);
    return false;
  }
}
