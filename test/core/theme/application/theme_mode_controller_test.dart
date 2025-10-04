import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/core/theme/application/theme_mode_controller.dart';
import 'package:kopim/core/theme/domain/app_theme_mode.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('loads persisted mode on initialization', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'core.theme.mode': 'dark',
    });

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final Completer<AppThemeMode> completer = Completer<AppThemeMode>();
    final ProviderSubscription<AppThemeMode> subscription = container.listen(
      themeModeControllerProvider,
      (AppThemeMode? previous, AppThemeMode next) {
        if (!completer.isCompleted && next == const AppThemeMode.dark()) {
          completer.complete(next);
        }
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    if (!completer.isCompleted &&
        container.read(themeModeControllerProvider) ==
            const AppThemeMode.dark()) {
      completer.complete(const AppThemeMode.dark());
    }

    expect(await completer.future, const AppThemeMode.dark());
  });

  test('persists selection across containers', () async {
    final ProviderContainer firstContainer = ProviderContainer();
    addTearDown(firstContainer.dispose);

    await firstContainer
        .read(themeModeControllerProvider.notifier)
        .setMode(const AppThemeMode.dark());

    final ProviderContainer secondContainer = ProviderContainer();
    addTearDown(secondContainer.dispose);

    final Completer<AppThemeMode> completer = Completer<AppThemeMode>();
    final ProviderSubscription<AppThemeMode> subscription = secondContainer
        .listen(themeModeControllerProvider, (
          AppThemeMode? previous,
          AppThemeMode next,
        ) {
          if (!completer.isCompleted && next == const AppThemeMode.dark()) {
            completer.complete(next);
          }
        }, fireImmediately: true);
    addTearDown(subscription.close);

    if (!completer.isCompleted &&
        secondContainer.read(themeModeControllerProvider) ==
            const AppThemeMode.dark()) {
      completer.complete(const AppThemeMode.dark());
    }

    expect(await completer.future, const AppThemeMode.dark());
  });
}
