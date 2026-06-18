import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/firebase_environment.dart';
import 'package:riverpod/riverpod.dart';

class AppCapabilities {
  const AppCapabilities({
    required this.canInitializeFirebase,
    required this.canUseFirebaseAuth,
    required this.canUseFirestore,
    required this.canUseRemoteConfig,
    required this.canRunCloudSync,
    required this.canUseAiTransport,
    required this.firebaseEnvironment,
  });

  factory AppCapabilities.fromRuntime() {
    final bool cloudCapable = AppRuntimeConfig.isCloudCapableDistribution;

    return AppCapabilities(
      canInitializeFirebase: cloudCapable,
      canUseFirebaseAuth: cloudCapable,
      canUseFirestore: cloudCapable,
      canUseRemoteConfig: cloudCapable,
      canRunCloudSync: cloudCapable,
      canUseAiTransport: cloudCapable,
      firebaseEnvironment: cloudCapable
          ? FirebaseEnvironmentConfig.environment
          : null,
    );
  }

  final bool canInitializeFirebase;
  final bool canUseFirebaseAuth;
  final bool canUseFirestore;
  final bool canUseRemoteConfig;
  final bool canRunCloudSync;
  final bool canUseAiTransport;
  final FirebaseEnvironment? firebaseEnvironment;
}

final Provider<AppCapabilities> appCapabilitiesProvider =
    Provider<AppCapabilities>((Ref ref) {
      return AppCapabilities.fromRuntime();
    });
