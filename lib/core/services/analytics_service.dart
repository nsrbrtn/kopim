import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AnalyticsService {
  const AnalyticsService();

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  Future<void> logEvent(String name, [Map<String, dynamic>? params]) async {
    if (_isFirebaseReady) {
      final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
      await analytics.logEvent(
        name: name,
        parameters: params?.cast<String, Object>(),
      );
    }
    await Sentry.captureMessage('Event: $name');
  }

  void reportError(dynamic error, StackTrace stack) {
    if (_isFirebaseReady) {
      final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
      crashlytics.recordError(error, stack);
    }
    Sentry.captureException(error, stackTrace: stack);
  }
}
