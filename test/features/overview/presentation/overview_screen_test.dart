import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/overview/domain/models/financial_index_models.dart';
import 'package:kopim/features/overview/domain/models/overview_daily_allowance.dart';
import 'package:kopim/features/overview/presentation/controllers/overview_financial_index_providers.dart';
import 'package:kopim/features/overview/presentation/overview_screen.dart';
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
        ],
        child: const MaterialApp(
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
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OverviewScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(OverviewScreen));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    await tester.tap(find.byIcon(Icons.help_outline_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text(strings.overviewFinancialIndexInfoTitle), findsOneWidget);
    expect(find.text(strings.overviewFinancialIndexInfoBody), findsOneWidget);
  });

  testWidgets(
    'при ошибке расчета лимита не показывает фиктивную сумму 2000',
    (WidgetTester tester) async {
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
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OverviewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is RichText && widget.text.toPlainText() == '2000.00 per day',
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
    },
  );
}
