import 'dart:async';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/overview/domain/entities/overview_preferences.dart';
import 'package:kopim/features/overview/domain/repositories/overview_preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'overview_preferences_controller.g.dart';

@riverpod
class OverviewPreferencesController extends _$OverviewPreferencesController {
  late final OverviewPreferencesRepository _repository;

  @override
  FutureOr<OverviewPreferences> build() async {
    _repository = ref.watch(overviewPreferencesRepositoryProvider);
    return _repository.load();
  }

  Future<void> setAccountSelection({
    required Set<String> selectedIds,
    required List<String> allIds,
  }) async {
    final OverviewPreferences current = await future;
    final OverviewPreferences updated = current.copyWith(
      accountIds: _normalizeSelection(selectedIds, allIds),
    );
    await _persist(updated, previous: current);
  }

  Future<void> setCategorySelection({
    required Set<String> selectedIds,
    required List<String> allIds,
  }) async {
    final OverviewPreferences current = await future;
    final OverviewPreferences updated = current.copyWith(
      categoryIds: _normalizeSelection(selectedIds, allIds),
    );
    await _persist(updated, previous: current);
  }

  List<String>? _normalizeSelection(
    Set<String> selectedIds,
    List<String> allIds,
  ) {
    final Set<String> allowed = allIds.toSet();
    final List<String> sanitized = selectedIds
        .where(allowed.contains)
        .toList(growable: false);
    if (sanitized.length == allIds.length) {
      return null;
    }
    return sanitized;
  }

  Future<void> _persist(
    OverviewPreferences preferences, {
    required OverviewPreferences previous,
  }) async {
    state = AsyncValue<OverviewPreferences>.data(preferences);
    try {
      await _repository.save(preferences);
    } catch (error, stackTrace) {
      state = AsyncValue<OverviewPreferences>.data(previous);
      ref
          .read(loggerServiceProvider)
          .logError('Не удалось сохранить настройки обзора', error);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
