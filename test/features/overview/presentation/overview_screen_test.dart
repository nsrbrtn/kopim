import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/presentation/controllers/active_currency_code_provider.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/overview/domain/models/financial_index_models.dart';
import 'package:kopim/features/overview/domain/models/overview_behavior_progress.dart';
import 'package:kopim/features/overview/domain/models/overview_daily_allowance.dart';
import 'package:kopim/features/overview/domain/models/overview_safety_cushion.dart';
import 'package:kopim/features/overview/presentation/controllers/overview_financial_index_providers.dart';
import 'package:kopim/features/overview/presentation/overview_screen.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:riverpod/src/framework.dart' show Override;

void main() {
  testWidgets('показывает статус и чип с баллами текущего месяца', (
    WidgetTester tester,
  ) async {
    final FinancialIndexSeries series = FinancialIndexSeries(
      current: const FinancialIndexSnapshot(
        totalScore: 82,
        status: FinancialIndexStatus.confidentGrowth,
        factors: FinancialIndexFactors(
          budgetScore: 80,
          safetyScore: 84,
          dynamicsScore: 79,
          disciplineScore: 90,
        ),
      ),
      monthly: <FinancialIndexMonthlyPoint>[
        FinancialIndexMonthlyPoint(month: DateTime(2025, 8), score: 62),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 9), score: 65),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 10), score: 68),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 11), score: 72),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 12), score: 76),
        FinancialIndexMonthlyPoint(month: DateTime(2026, 1), score: 79),
        FinancialIndexMonthlyPoint(month: DateTime(2026, 2), score: 82),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewFinancialIndexSeriesProvider.overrideWith(
            (Ref ref) => Stream<FinancialIndexSeries>.value(series),
          ),
          overviewDailyAllowanceProvider.overrideWith(
            (Ref ref) => Stream<OverviewDailyAllowance>.value(
              OverviewDailyAllowance(
                dailyAllowance: MoneyAmount(
                  minor: BigInt.from(200000),
                  scale: 2,
                ),
                daysLeft: 8,
                horizonDate: DateTime(2026, 2, 18),
                disposableAtHorizon: MoneyAmount(
                  minor: BigInt.from(1600000),
                  scale: 2,
                ),
                plannedIncome: MoneyAmount(minor: BigInt.from(0), scale: 2),
                plannedExpense: MoneyAmount(minor: BigInt.from(0), scale: 2),
                hasIncomeAnchor: true,
              ),
            ),
          ),
          overviewSafetyCushionProvider.overrideWith(
            (Ref ref) => Stream<OverviewSafetyCushion>.value(
              _safetyCushion(monthsCovered: 3.2, targetMonths: 6),
            ),
          ),
          overviewBehaviorProgressProvider.overrideWith(
            (Ref ref) => Stream<OverviewBehaviorProgress>.value(
              _behaviorProgress(disciplineScore: 84, streakDays: 8),
            ),
          ),
          overviewSavingGoalsProvider.overrideWith(
            (Ref ref) => Stream<List<SavingGoal>>.value(<SavingGoal>[
              _goal(name: 'Vacation'),
            ]),
          ),
          activeCurrencyCodeProvider.overrideWithValue('RUB'),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OverviewScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(OverviewScreen));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    expect(find.text(strings.overviewFinancialIndexTitle), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is RichText && widget.text.toPlainText() == '82/100',
      ),
      findsOneWidget,
    );
    expect(
      find.text(strings.overviewFinancialIndexStatusGrowth),
      findsOneWidget,
    );
    expect(
      find.text(strings.overviewFinancialIndexMonthScoreChip(82)),
      findsOneWidget,
    );
    expect(
      find.text(strings.overviewSafetyPillowSubtitleProgress('3.2', '6.0')),
      findsOneWidget,
    );
    expect(
      find.text(strings.overviewBehaviorProgressSubtitleStreak(8)),
      findsOneWidget,
    );
    expect(
      find.text(strings.overviewBehaviorProgressValueMultiplier(8)),
      findsOneWidget,
    );
    expect(
      find.text(strings.overviewGoalTitleDynamic('Vacation')),
      findsOneWidget,
    );
    expect(find.textContaining('₽'), findsWidgets);
  });

  testWidgets('по нажатию на иконку вопроса открывается попап логики индекса', (
    WidgetTester tester,
  ) async {
    final FinancialIndexSeries series = FinancialIndexSeries(
      current: const FinancialIndexSnapshot(
        totalScore: 74,
        status: FinancialIndexStatus.stable,
        factors: FinancialIndexFactors(
          budgetScore: 80,
          safetyScore: 60,
          dynamicsScore: 70,
          disciplineScore: 90,
        ),
      ),
      monthly: <FinancialIndexMonthlyPoint>[
        FinancialIndexMonthlyPoint(month: DateTime(2025, 8), score: 62),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 9), score: 65),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 10), score: 68),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 11), score: 72),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 12), score: 76),
        FinancialIndexMonthlyPoint(month: DateTime(2026, 1), score: 71),
        FinancialIndexMonthlyPoint(month: DateTime(2026, 2), score: 74),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewFinancialIndexSeriesProvider.overrideWith(
            (Ref ref) => Stream<FinancialIndexSeries>.value(series),
          ),
          overviewDailyAllowanceProvider.overrideWith(
            (Ref ref) => Stream<OverviewDailyAllowance>.value(
              OverviewDailyAllowance(
                dailyAllowance: MoneyAmount(
                  minor: BigInt.from(200000),
                  scale: 2,
                ),
                daysLeft: 8,
                horizonDate: DateTime(2026, 2, 18),
                disposableAtHorizon: MoneyAmount(
                  minor: BigInt.from(1600000),
                  scale: 2,
                ),
                plannedIncome: MoneyAmount(minor: BigInt.from(0), scale: 2),
                plannedExpense: MoneyAmount(minor: BigInt.from(0), scale: 2),
                hasIncomeAnchor: true,
              ),
            ),
          ),
          overviewSafetyCushionProvider.overrideWith(
            (Ref ref) => Stream<OverviewSafetyCushion>.value(
              _safetyCushion(monthsCovered: 4.1, targetMonths: 6),
            ),
          ),
          overviewBehaviorProgressProvider.overrideWith(
            (Ref ref) => Stream<OverviewBehaviorProgress>.value(
              _behaviorProgress(disciplineScore: 72, streakDays: 5),
            ),
          ),
          overviewSavingGoalsProvider.overrideWith(
            (Ref ref) => Stream<List<SavingGoal>>.value(<SavingGoal>[
              _goal(name: 'Vacation'),
            ]),
          ),
          activeCurrencyCodeProvider.overrideWithValue('RUB'),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OverviewScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(OverviewScreen));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    await tester.tap(find.byIcon(Icons.question_mark).first);
    await tester.pumpAndSettle();

    expect(find.text(strings.overviewFinancialIndexInfoTitle), findsOneWidget);
    expect(find.text(strings.overviewFinancialIndexInfoBody), findsOneWidget);
  });

  testWidgets('при ошибке расчета лимита не показывает фиктивную сумму 2000', (
    WidgetTester tester,
  ) async {
    final FinancialIndexSeries series = FinancialIndexSeries(
      current: const FinancialIndexSnapshot(
        totalScore: 74,
        status: FinancialIndexStatus.stable,
        factors: FinancialIndexFactors(
          budgetScore: 80,
          safetyScore: 60,
          dynamicsScore: 70,
          disciplineScore: 90,
        ),
      ),
      monthly: <FinancialIndexMonthlyPoint>[
        FinancialIndexMonthlyPoint(month: DateTime(2025, 8), score: 62),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 9), score: 65),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 10), score: 68),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 11), score: 72),
        FinancialIndexMonthlyPoint(month: DateTime(2025, 12), score: 76),
        FinancialIndexMonthlyPoint(month: DateTime(2026, 1), score: 71),
        FinancialIndexMonthlyPoint(month: DateTime(2026, 2), score: 74),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewFinancialIndexSeriesProvider.overrideWith(
            (Ref ref) => Stream<FinancialIndexSeries>.value(series),
          ),
          overviewDailyAllowanceProvider.overrideWith(
            (Ref ref) =>
                Stream<OverviewDailyAllowance>.error(Exception('boom')),
          ),
          overviewSafetyCushionProvider.overrideWith(
            (Ref ref) => Stream<OverviewSafetyCushion>.error(Exception('boom')),
          ),
          overviewBehaviorProgressProvider.overrideWith(
            (Ref ref) =>
                Stream<OverviewBehaviorProgress>.error(Exception('boom')),
          ),
          overviewSavingGoalsProvider.overrideWith(
            (Ref ref) => Stream<List<SavingGoal>>.error(Exception('boom')),
          ),
          activeCurrencyCodeProvider.overrideWithValue('RUB'),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OverviewScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final BuildContext context = tester.element(find.byType(OverviewScreen));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is RichText &&
            widget.text.toPlainText() == '2000.00 per day',
      ),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is RichText && widget.text.toPlainText() == '-- per day',
      ),
      findsOneWidget,
    );
    expect(find.text('7.4 / 10 months'), findsNothing);
    final int safetyFallbackCount =
        find
            .text(strings.overviewSafetyPillowSubtitleUnavailable)
            .evaluate()
            .length +
        find
            .text(strings.overviewSafetyPillowSubtitleLoading)
            .evaluate()
            .length;
    expect(safetyFallbackCount, greaterThan(0));
    expect(find.text('x6'), findsNothing);
    expect(
      find.text(strings.overviewBehaviorProgressValuePlaceholder),
      findsOneWidget,
    );
  });
}

SavingGoal _goal({required String name}) {
  final DateTime now = DateTime(2026, 2, 26);
  return SavingGoal(
    id: 'goal-1',
    userId: 'user-1',
    name: name,
    accountId: 'goal-account-1',
    targetAmount: 100000,
    currentAmount: 45000,
    createdAt: now,
    updatedAt: now,
  );
}

OverviewBehaviorProgress _behaviorProgress({
  required int disciplineScore,
  required int streakDays,
}) {
  return OverviewBehaviorProgress(
    disciplineScore: disciplineScore,
    streakDays: streakDays,
    activeDays30d: streakDays,
    progress: disciplineScore / 100,
  );
}

OverviewSafetyCushion _safetyCushion({
  required double monthsCovered,
  required double targetMonths,
}) {
  return OverviewSafetyCushion(
    monthsCovered: monthsCovered,
    targetMonths: targetMonths,
    progress: monthsCovered / targetMonths,
    safetyScore: 70,
    state: OverviewSafetyCushionState.safe,
    liquidAssets: MoneyAmount(minor: BigInt.from(300000), scale: 2),
    avgMonthlyExpense: MoneyAmount(minor: BigInt.from(100000), scale: 2),
  );
}
