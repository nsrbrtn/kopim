import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> logEvent(String name, [Map<String, dynamic>? params]) async {
    await _analytics.logEvent(name: name, parameters: params?.cast<String, Object>());  // Cast для совместимости
    await Sentry.captureMessage('Event: $name');
  }

  void reportError(dynamic error, StackTrace stack) {
    _crashlytics.recordError(error, stack);
    Sentry.captureException(error, stackTrace: stack);
  }
}