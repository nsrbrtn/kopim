import 'package:flutter/foundation.dart';

/// Возвращает `true`, если бэкенд задач повторяющихся платежей поддерживается
/// на текущей платформе (мобильные устройства).
bool supportsUpcomingPaymentsBackgroundWork() {
  if (kIsWeb) {
    return false;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return true;
    default:
      return false;
  }
}
