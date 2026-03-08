import 'package:firebase_core/firebase_core.dart';

import 'package:kopim/firebase_options.dart' as legacy_dev;
import 'package:kopim/firebase_options_dev.dart' as dev;
import 'package:kopim/firebase_options_prod.dart' as prod;

enum FirebaseEnvironment { dev, prod }

/// Глобальный селектор Firebase-конфига для текущего entrypoint-а.
final class FirebaseEnvironmentConfig {
  FirebaseEnvironmentConfig._();

  static FirebaseEnvironment _environment = FirebaseEnvironment.dev;

  static FirebaseEnvironment get environment => _environment;

  static bool get isProduction => _environment == FirebaseEnvironment.prod;

  static void configure(FirebaseEnvironment environment) {
    _environment = environment;
  }

  static FirebaseOptions get currentPlatformOptions {
    return switch (_environment) {
      FirebaseEnvironment.dev => _resolveDevOptions(),
      FirebaseEnvironment.prod => prod.DefaultFirebaseOptions.currentPlatform,
    };
  }

  static FirebaseOptions _resolveDevOptions() {
    try {
      return dev.DefaultFirebaseOptions.currentPlatform;
    } catch (_) {
      return legacy_dev.DefaultFirebaseOptions.currentPlatform;
    }
  }
}
