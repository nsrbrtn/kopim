import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:kopim/core/services/logger_service.dart';

import 'push_permission_service.dart';

PushPermissionService createPushPermissionService({LoggerService? logger}) {
  return WebPushPermissionService(logger: logger);
}

class WebPushPermissionService implements PushPermissionService {
  WebPushPermissionService({
    FirebaseMessaging? messaging,
    LoggerService? logger,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _logger = logger ?? LoggerService();

  final FirebaseMessaging _messaging;
  final LoggerService _logger;
  bool? _granted;

  @override
  bool get isSupported => true;

  @override
  Future<bool> ensurePermission({bool requestIfNeeded = true}) async {
    if (_granted != null && !requestIfNeeded) {
      return _granted!;
    }
    try {
      final NotificationSettings settings = await _messaging
          .requestPermission();
      _granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (_granted ?? false) {
        await _messaging.setAutoInitEnabled(true);
        try {
          await _messaging.getToken();
        } catch (error) {
          _logger.logError('FCM token request failed: $error');
        }
      }
      return _granted ?? false;
    } catch (error) {
      _logger.logError('Web push permission request failed: $error');
      _granted = false;
      return false;
    }
  }
}
