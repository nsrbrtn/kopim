import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/overview/domain/entities/overview_preferences.dart';
import 'package:kopim/features/overview/domain/models/financial_index_models.dart';
import 'package:kopim/features/overview/domain/models/overview_behavior_progress.dart';
import 'package:kopim/features/overview/domain/models/overview_daily_allowance.dart';
import 'package:kopim/features/overview/domain/models/overview_safety_cushion.dart';
import 'package:kopim/features/overview/presentation/controllers/overview_preferences_controller.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

final StreamProvider<FinancialIndexSeries>
overviewFinancialIndexSeriesProvider =
    StreamProvider.autoDispose<FinancialIndexSeries>((Ref ref) {
      final OverviewPreferences preferences = ref
          .watch(overviewPreferencesControllerProvider)
          .maybeWhen(
            data: (OverviewPreferences value) => value,
            orElse: () => const OverviewPreferences(),
          );

      return ref
          .watch(watchFinancialIndexUseCaseProvider)
          .call(
            accountIdsFilter: preferences.accountIdSet,
            categoryIdsFilter: preferences.categoryIdSet,
            historyMonths: 7,
          );
    });

final StreamProvider<OverviewDailyAllowance> overviewDailyAllowanceProvider =
    StreamProvider.autoDispose<OverviewDailyAllowance>((Ref ref) {
      final OverviewPreferences preferences = ref
          .watch(overviewPreferencesControllerProvider)
          .maybeWhen(
            data: (OverviewPreferences value) => value,
            orElse: () => const OverviewPreferences(),
          );
      return ref
          .watch(watchOverviewDailyAllowanceUseCaseProvider)
          .call(
            accountIdsFilter: preferences.accountIdSet,
            selectedUpcomingPaymentId:
                preferences.balanceAnchorUpcomingPaymentId,
          );
    });

final StreamProvider<OverviewSafetyCushion> overviewSafetyCushionProvider =
    StreamProvider.autoDispose<OverviewSafetyCushion>((Ref ref) {
      final OverviewPreferences preferences = ref
          .watch(overviewPreferencesControllerProvider)
          .maybeWhen(
            data: (OverviewPreferences value) => value,
            orElse: () => const OverviewPreferences(),
          );
      return ref
          .watch(watchOverviewSafetyCushionUseCaseProvider)
          .call(accountIdsFilter: preferences.accountIdSet);
    });

final StreamProvider<OverviewBehaviorProgress>
overviewBehaviorProgressProvider =
    StreamProvider.autoDispose<OverviewBehaviorProgress>((Ref ref) {
      final OverviewPreferences preferences = ref
          .watch(overviewPreferencesControllerProvider)
          .maybeWhen(
            data: (OverviewPreferences value) => value,
            orElse: () => const OverviewPreferences(),
          );
      return ref
          .watch(watchOverviewBehaviorProgressUseCaseProvider)
          .call(
            accountIdsFilter: preferences.accountIdSet,
            categoryIdsFilter: preferences.categoryIdSet,
          );
    });

final StreamProvider<List<SavingGoal>> overviewSavingGoalsProvider =
    StreamProvider.autoDispose<List<SavingGoal>>((Ref ref) {
      return ref
          .watch(watchSavingGoalsUseCaseProvider)
          .call(includeArchived: false);
    });
