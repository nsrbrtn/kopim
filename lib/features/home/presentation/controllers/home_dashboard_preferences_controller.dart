import 'dart:async';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/domain/repositories/home_dashboard_preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_dashboard_preferences_controller.g.dart';

@riverpod
class HomeDashboardPreferencesController
    extends _$HomeDashboardPreferencesController {
  late final HomeDashboardPreferencesRepository _repository;

  @override
  FutureOr<HomeDashboardPreferences> build() async {
    _repository = ref.watch(homeDashboardPreferencesRepositoryProvider);
    return _repository.load();
  }

  Future<void> setShowGamification(bool value) async {
    final HomeDashboardPreferences current = await future;
    final HomeDashboardPreferences updated = current.copyWith(
      showGamificationWidget: value,
    );
    await _persist(updated, previous: current);
  }

  Future<void> setShowBudget(bool value) async {
    final HomeDashboardPreferences current = await future;
    final HomeDashboardPreferences updated = current.copyWith(
      showBudgetWidget: value,
      budgetId: value ? current.budgetId : null,
    );
    await _persist(updated, previous: current);
  }

  Future<void> setShowRecurring(bool value) async {
    final HomeDashboardPreferences current = await future;
    final HomeDashboardPreferences updated = current.copyWith(
      showRecurringWidget: value,
    );
    await _persist(updated, previous: current);
  }

  Future<void> setBudgetId(String? budgetId) async {
    final HomeDashboardPreferences current = await future;
    final HomeDashboardPreferences updated = current.copyWith(
      budgetId: budgetId,
    );
    await _persist(updated, previous: current);
  }

  Future<void> _persist(
    HomeDashboardPreferences preferences, {
    required HomeDashboardPreferences previous,
  }) async {
    state = AsyncValue<HomeDashboardPreferences>.data(preferences);
    try {
      await _repository.save(preferences);
    } catch (error, stackTrace) {
      state = AsyncValue<HomeDashboardPreferences>.data(previous);
      ref
          .read(loggerServiceProvider)
          .logError('Failed to save home dashboard preferences', error);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
