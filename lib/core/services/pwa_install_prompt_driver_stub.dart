import 'dart:async';

import 'pwa_install_prompt_types.dart';

abstract class PwaInstallPromptDriver {
  bool get isSupported;
  bool get canPrompt;
  bool get isInstalled;
  Stream<bool> get availabilityStream;
  Stream<bool> get installedStream;

  Future<PwaPromptResult> promptInstall();
  Future<void> dispose();
}

PwaInstallPromptDriver createPwaInstallPromptDriver() =>
    _UnsupportedPwaInstallPromptDriver();

class _UnsupportedPwaInstallPromptDriver implements PwaInstallPromptDriver {
  _UnsupportedPwaInstallPromptDriver();

  final StreamController<bool> _availabilityController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _installedController =
      StreamController<bool>.broadcast();

  @override
  bool get isSupported => false;

  @override
  bool get canPrompt => false;

  @override
  bool get isInstalled => false;

  @override
  Stream<bool> get availabilityStream => _availabilityController.stream;

  @override
  Stream<bool> get installedStream => _installedController.stream;

  @override
  Future<PwaPromptResult> promptInstall() async {
    return PwaPromptResult.unavailable;
  }

  @override
  Future<void> dispose() async {
    await _availabilityController.close();
    await _installedController.close();
  }
}
