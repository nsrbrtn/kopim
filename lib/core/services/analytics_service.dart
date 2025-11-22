import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AnalyticsService {
  const AnalyticsService();

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  Future<void> logEvent(String name, [Map<String, dynamic>? params]) async {
    try {
      if (_isFirebaseReady) {
        final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
        await analytics.logEvent(
          name: name,
          parameters: _sanitizeParameters(params),
        );
      }
    } catch (error) {
      // Analytics errors should not crash the app
      // This is especially important on web where throttling can throw exceptions
    }
    await Sentry.captureMessage('Event: $name');
  }

  Map<String, Object>? _sanitizeParameters(Map<String, dynamic>? params) {
    if (params == null) {
      return null;
    }
    final Map<String, Object> sanitized = <String, Object>{};
    params.forEach((String key, dynamic value) {
      if (value is String || value is num) {
        sanitized[key] = value;
        return;
      }
      if (value is bool) {
        sanitized[key] = value ? 1 : 0;
        return;
      }
      if (value != null) {
        sanitized[key] = value.toString();
      }
    });
    return sanitized.isEmpty ? null : sanitized;
  }

  void reportError(dynamic error, StackTrace stack) {
    try {
      if (!kIsWeb && _isFirebaseReady) {
        final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
        crashlytics.recordError(error, stack);
      }
    } catch (e) {
      // Ignore analytics errors to prevent app crashes
    }
    Sentry.captureException(error, stackTrace: stack);
  }
}
