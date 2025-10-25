import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pwa_install_prompt_driver_stub.dart'
    if (dart.library.html) 'pwa_install_prompt_driver_web.dart';
import 'pwa_install_prompt_types.dart';

part 'pwa_install_prompt.freezed.dart';
part 'pwa_install_prompt.g.dart';

@freezed
class PwaInstallPromptState with _$PwaInstallPromptState {
  const factory PwaInstallPromptState({
    @Default(false) bool isSupported,
    @Default(false) bool canPrompt,
    @Default(false) bool isInstalled,
    DateTime? lastPromptTime,
  }) = _PwaInstallPromptState;
}

@Riverpod(keepAlive: true)
class PwaInstallPromptController extends _$PwaInstallPromptController {
  PwaInstallPromptDriver? _driver;
  StreamSubscription<bool>? _availabilitySub;
  StreamSubscription<bool>? _installedSub;

  @override
  PwaInstallPromptState build() {
    const PwaInstallPromptState baseState = PwaInstallPromptState();
    if (!kIsWeb) {
      return baseState;
    }

    final PwaInstallPromptDriver driver = createPwaInstallPromptDriver();
    _driver = driver;

    final PwaInstallPromptState nextState = baseState.copyWith(
      isSupported: driver.isSupported,
      canPrompt: driver.canPrompt,
      isInstalled: driver.isInstalled,
    );

    _availabilitySub = driver.availabilityStream.listen((bool value) {
      state = state.copyWith(isSupported: driver.isSupported, canPrompt: value);
    });

    _installedSub = driver.installedStream.listen((bool installed) {
      state = state.copyWith(
        isSupported: driver.isSupported,
        isInstalled: installed,
      );
    });

    ref.onDispose(() {
      unawaited(_availabilitySub?.cancel());
      unawaited(_installedSub?.cancel());
      unawaited(driver.dispose());
    });

    return nextState;
  }

  Future<PwaPromptResult> promptInstall() async {
    final PwaInstallPromptDriver? driver = _driver;
    if (driver == null) {
      return PwaPromptResult.unavailable;
    }
    final PwaPromptResult result = await driver.promptInstall();
    switch (result) {
      case PwaPromptResult.accepted:
        state = state.copyWith(
          canPrompt: false,
          isInstalled: true,
          lastPromptTime: DateTime.now(),
        );
      case PwaPromptResult.dismissed:
        state = state.copyWith(
          canPrompt: false,
          lastPromptTime: DateTime.now(),
        );
      case PwaPromptResult.unavailable:
        break;
    }
    return result;
  }

  void clearPromptAvailability() {
    if (!state.canPrompt) {
      return;
    }
    state = state.copyWith(canPrompt: false);
  }
}
