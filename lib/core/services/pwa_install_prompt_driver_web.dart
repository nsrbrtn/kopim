// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, uri_does_not_exist

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'pwa_install_prompt_driver_stub.dart';
import 'pwa_install_prompt_types.dart';

class HtmlPwaInstallPromptDriver implements PwaInstallPromptDriver {
  HtmlPwaInstallPromptDriver() {
    _isSupported = js_util.hasProperty(html.window, 'BeforeInstallPromptEvent');
    _installed = _resolveInstalled();
    _beforeInstallListener = (html.Event event) {
      event.preventDefault();
      _deferredPrompt = event;
      _canPrompt = true;
      _availabilityController.add(true);
    };
    _appInstalledListener = (html.Event _) {
      _canPrompt = false;
      _installed = true;
      _availabilityController.add(false);
      _installedController.add(true);
    };
    html.window.addEventListener('beforeinstallprompt', _beforeInstallListener);
    html.window.addEventListener('appinstalled', _appInstalledListener);
  }

  final StreamController<bool> _availabilityController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _installedController =
      StreamController<bool>.broadcast();

  late final html.EventListener _beforeInstallListener;
  late final html.EventListener _appInstalledListener;
  dynamic _deferredPrompt;
  late bool _isSupported;
  bool _canPrompt = false;
  bool _installed = false;

  @override
  bool get isSupported => _isSupported;

  @override
  bool get canPrompt => _canPrompt;

  @override
  bool get isInstalled => _installed;

  @override
  Stream<bool> get availabilityStream => _availabilityController.stream;

  @override
  Stream<bool> get installedStream => _installedController.stream;

  @override
  Future<PwaPromptResult> promptInstall() async {
    final dynamic promptEvent = _deferredPrompt;
    if (promptEvent == null) {
      return PwaPromptResult.unavailable;
    }

    _deferredPrompt = null;
    _canPrompt = false;
    _availabilityController.add(false);

    try {
      await js_util.promiseToFuture<void>(
        js_util.callMethod(promptEvent, 'prompt', <Object?>[]),
      );
      final Object? choiceResult = await js_util.promiseToFuture(
        js_util.getProperty(promptEvent, 'userChoice'),
      );
      final String outcome = (choiceResult != null)
          ? (js_util.getProperty(choiceResult, 'outcome') as String? ?? '')
          : '';
      if (outcome == 'accepted') {
        _installed = true;
        _installedController.add(true);
        return PwaPromptResult.accepted;
      }
      return PwaPromptResult.dismissed;
    } catch (_) {
      return PwaPromptResult.unavailable;
    }
  }

  @override
  Future<void> dispose() async {
    html.window.removeEventListener(
      'beforeinstallprompt',
      _beforeInstallListener,
    );
    html.window.removeEventListener('appinstalled', _appInstalledListener);
    await _availabilityController.close();
    await _installedController.close();
  }

  bool _resolveInstalled() {
    final bool standaloneDisplay = html.window
        .matchMedia('(display-mode: standalone)')
        .matches;
    final bool navigatorStandalone =
        js_util.getProperty<bool?>(html.window.navigator, 'standalone') == true;
    return standaloneDisplay || navigatorStandalone;
  }
}

PwaInstallPromptDriver createPwaInstallPromptDriver() {
  return HtmlPwaInstallPromptDriver();
}
