import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

import 'package:kopim/core/theme/application/theme_mode_controller.dart';
import 'package:kopim/core/theme/data/app_theme_factory.dart';
import 'package:kopim/core/theme/data/theme_repository_impl.dart';
import 'package:kopim/core/theme/data/dto/kopim_theme_tokens.dart';
import 'package:kopim/core/theme/data/generated/kopim_theme_tokens.g.dart';
import 'package:kopim/core/theme/domain/app_theme_mode.dart';
import 'package:kopim/core/theme/domain/repositories/theme_repository.dart';

class _FakeThemeRepository implements ThemeRepository {
  _FakeThemeRepository(this.mode);

  AppThemeMode mode;
  int loadCalls = 0;
  final Queue<Completer<void>> _expectedLoads = Queue<Completer<void>>();

  Future<void> expectLoad() {
    final Completer<void> completer = Completer<void>();
    _expectedLoads.add(completer);
    return completer.future;
  }

  @override
  Future<AppThemeMode> loadThemeMode() {
    loadCalls += 1;
    final Completer<void>? completer = _expectedLoads.isNotEmpty
        ? _expectedLoads.removeFirst()
        : null;
    completer?.complete();
    return Future<AppThemeMode>.value(mode);
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    this.mode = mode;
  }
}

void main() {
  test('reloads stored mode when theme tokens update', () async {
    final _FakeThemeRepository repository = _FakeThemeRepository(
      const AppThemeMode.light(),
    );
    KopimThemeTokenBundle currentTokens = kopimThemeTokens;

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        themeRepositoryProvider.overrideWithValue(repository),
        appThemeTokensProvider.overrideWith((Ref ref) async => currentTokens),
      ],
    );
    addTearDown(container.dispose);

    final Future<void> firstLoad = repository.expectLoad();
    final Completer<void> initialModeLoaded = Completer<void>();
    final ProviderSubscription<AppThemeMode> initialSubscription = container
        .listen<AppThemeMode>(themeModeControllerProvider, (
          AppThemeMode? _,
          AppThemeMode next,
        ) {
          if (next == const AppThemeMode.light() &&
              !initialModeLoaded.isCompleted) {
            initialModeLoaded.complete();
          }
        }, fireImmediately: true);

    container.read(themeModeControllerProvider);
    await firstLoad;
    await initialModeLoaded.future;
    initialSubscription.close();

    expect(repository.loadCalls, 1);
    expect(
      container.read(themeModeControllerProvider),
      const AppThemeMode.light(),
    );

    repository.mode = const AppThemeMode.dark();

    final Future<void> secondLoad = repository.expectLoad();
    final Completer<void> reloadedMode = Completer<void>();
    final ProviderSubscription<AppThemeMode> reloadSubscription = container
        .listen<AppThemeMode>(themeModeControllerProvider, (
          AppThemeMode? _,
          AppThemeMode next,
        ) {
          if (next == const AppThemeMode.dark() && !reloadedMode.isCompleted) {
            reloadedMode.complete();
          }
        });

    currentTokens = kopimThemeTokens.copyWith(
      lightColors: kopimThemeTokens.lightColors.copyWith(
        primary: const Color(0xFF000001), // Change any color to trigger update
      ),
    );
    container.invalidate(appThemeTokensProvider);
    await secondLoad;
    await reloadedMode.future;
    reloadSubscription.close();

    expect(repository.loadCalls, 2);
    expect(
      container.read(themeModeControllerProvider),
      const AppThemeMode.dark(),
    );
  });
}
