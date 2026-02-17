import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/analytics/domain/models/monthly_balance_data.dart';
import 'package:kopim/features/analytics/presentation/widgets/total_money_chart_widget.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('ru', null);
  });

  testWidgets('TotalMoneyChartWidget renders correctly with data', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.now();
    final List<MonthlyBalanceData> data = <MonthlyBalanceData>[
      MonthlyBalanceData(
        month: DateTime(now.year, now.month - 1),
        totalBalance: MoneyAmount(minor: BigInt.from(100000), scale: 2),
      ),
      MonthlyBalanceData(
        month: now,
        totalBalance: MoneyAmount(minor: BigInt.from(200000), scale: 2),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TotalMoneyChartWidget(
            data: data,
            currencySymbol: '₽',
            selectedMonth: now,
            onMonthSelected: (_) {},
            localeName: 'en',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(Scaffold));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    // Verify chart is present
    expect(find.byType(SfCartesianChart), findsOneWidget);

    // Verify title
    expect(find.text(strings.analyticsTotalMoneyWidgetTitle), findsOneWidget);

    // Verify selected month balance is shown
    expect(find.text('2K ₽'), findsOneWidget);
  });

  testWidgets('TotalMoneyChartWidget has 2 series when data is selected', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.now();
    final List<MonthlyBalanceData> data = <MonthlyBalanceData>[
      MonthlyBalanceData(
        month: now,
        totalBalance: MoneyAmount(minor: BigInt.from(200000), scale: 2),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TotalMoneyChartWidget(
            data: data,
            currencySymbol: '₽',
            selectedMonth: now,
            onMonthSelected: (_) {},
            localeName: 'en',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    if (find.byType(SfCartesianChart).evaluate().isEmpty) {
      debugPrint('SfCartesianChart not found!');
      final Finder errorFinder = find.textContaining('Error:');
      if (errorFinder.evaluate().isNotEmpty) {
        debugPrint(
          'Found error text: ${tester.widget<Text>(errorFinder.first).data}',
        );
      } else {
        debugPrint('No error text found either.');
        debugDumpApp();
      }
    }

    final SfCartesianChart chart = tester.widget(find.byType(SfCartesianChart));
    // Should have SplineSeries + ScatterSeries (for glow)
    expect(chart.series.length, 2);
    expect(chart.series[0], isA<SplineSeries<MonthlyBalanceData, String>>());
    expect(chart.series[1], isA<ScatterSeries<MonthlyBalanceData, String>>());
  });

  testWidgets(
    'TotalMoneyChartWidget uses closest available month when selected is out of range',
    (WidgetTester tester) async {
      final List<MonthlyBalanceData> data = <MonthlyBalanceData>[
        MonthlyBalanceData(
          month: DateTime(2025, 1),
          totalBalance: MoneyAmount(minor: BigInt.from(100000), scale: 2),
        ),
        MonthlyBalanceData(
          month: DateTime(2025, 2),
          totalBalance: MoneyAmount(minor: BigInt.from(250000), scale: 2),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TotalMoneyChartWidget(
              data: data,
              currencySymbol: '₽',
              selectedMonth: DateTime(2030, 1),
              onMonthSelected: (_) {},
              localeName: 'en',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('February'), findsOneWidget);
      expect(find.text('2.5K ₽'), findsOneWidget);
    },
  );
}
