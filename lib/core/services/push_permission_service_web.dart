// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

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
  }) : _messaging = messaging,
       _logger = logger ?? LoggerService();

  final FirebaseMessaging? _messaging;
  final LoggerService _logger;
  bool? _granted;

  FirebaseMessaging get messaging {
    _logger.logInfo('[kopim-sw] Accessing FirebaseMessaging instance...');
    return _messaging ?? FirebaseMessaging.instance;
  }

  @override
  bool get isSupported => true;

  @override
  String get permissionStatus {
    if (html.Notification.supported) {
      return html.Notification.permission ?? 'default';
    }
    return 'not_supported';
  }

  Future<void> _ensureServiceWorkerRegistered() async {
    try {
      final html.ServiceWorkerContainer? serviceWorker =
          html.window.navigator.serviceWorker;
      if (serviceWorker == null) {
        _logger.logWarning(
          '[kopim-sw] Service worker container не поддерживается в этом браузере.',
        );
        return;
      }
      final List<dynamic> registrations = await serviceWorker
          .getRegistrations();
      bool found = false;
      for (final dynamic reg in registrations) {
        if (reg is html.ServiceWorkerRegistration) {
          final html.ServiceWorker? active = reg.active;
          if (active != null) {
            final String? url = active.scriptUrl;
            if (url != null && url.contains('firebase-messaging-sw.js')) {
              found = true;
              break;
            }
          }
        }
      }

      if (!found) {
        _logger.logInfo(
          '[kopim-sw] Регистрация Firebase Messaging Service Worker из ленивого пути...',
        );
        await serviceWorker.register(
          'firebase-messaging-sw.js',
          <String, dynamic>{'scope': '/firebase-cloud-messaging-push-scope'},
        );
        _logger.logInfo(
          '[kopim-sw] Firebase Messaging Service Worker успешно зарегистрирован.',
        );
      }
    } catch (e) {
      _logger.logError(
        '[kopim-sw] Не удалось зарегистрировать Firebase Messaging Service Worker вручную: $e',
      );
    }
  }

  @override
  Future<bool> ensurePermission({bool requestIfNeeded = true}) async {
    final String? currentPermission = html.Notification.supported
        ? html.Notification.permission
        : 'not_supported';
    _logger.logInfo(
      '[kopim-sw] ensurePermission called: requestIfNeeded=$requestIfNeeded, currentPermission=$currentPermission',
    );

    if (html.Notification.supported) {
      final String? permission = html.Notification.permission;
      if (permission == 'granted') {
        _granted = true;
        _logger.logInfo(
          '[kopim-sw] Permission is already granted. Returning true.',
        );
        return true;
      }
      if (permission == 'denied') {
        _granted = false;
        _logger.logInfo('[kopim-sw] Permission is denied. Returning false.');
        return false;
      }
      if (!requestIfNeeded) {
        _logger.logInfo(
          '[kopim-sw] Permission is default, requestIfNeeded=false. Returning false without requesting.',
        );
        return false;
      }
    } else {
      if (!requestIfNeeded) {
        _logger.logInfo(
          '[kopim-sw] Notifications not supported, requestIfNeeded=false. Returning ${_granted ?? false}.',
        );
        return _granted ?? false;
      }
    }

    try {
      await _ensureServiceWorkerRegistered();

      final NotificationSettings settings = await messaging.requestPermission();
      _granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (_granted ?? false) {
        await messaging.setAutoInitEnabled(true);
        try {
          await messaging.getToken();
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
