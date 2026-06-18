import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/firebase_environment.dart';

void main() {
  tearDown(() {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    FirebaseEnvironmentConfig.configure(FirebaseEnvironment.dev);
  });

  test('offline runtime disables Firebase and AI capabilities', () {
    AppRuntimeConfig.configure(AppRuntimeFlavor.offline);

    final AppCapabilities capabilities = AppCapabilities.fromRuntime();

    expect(capabilities.canInitializeFirebase, isFalse);
    expect(capabilities.canUseFirebaseAuth, isFalse);
    expect(capabilities.canUseFirestore, isFalse);
    expect(capabilities.canUseAiTransport, isFalse);
    expect(capabilities.firebaseEnvironment, isNull);
  });

  test('dev runtime uses dev Firebase environment', () {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    FirebaseEnvironmentConfig.configure(FirebaseEnvironment.dev);

    final AppCapabilities capabilities = AppCapabilities.fromRuntime();

    expect(capabilities.firebaseEnvironment, FirebaseEnvironment.dev);
  });

  test('prod runtime uses prod Firebase environment', () {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseProd);
    FirebaseEnvironmentConfig.configure(FirebaseEnvironment.prod);

    final AppCapabilities capabilities = AppCapabilities.fromRuntime();

    expect(capabilities.firebaseEnvironment, FirebaseEnvironment.prod);
  });
}
