import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kopim/features/analytics/presentation/models/monthly_cashflow_data.dart';
import 'package:kopim/features/analytics/presentation/widgets/monthly_cashflow_bar_chart_widget.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('ru', null);
  });

  testWidgets(
    'MonthlyCashflowBarChartWidget uses closest available month when selected is out of range',
    (WidgetTester tester) async {
      final List<MonthlyCashflowData> data = <MonthlyCashflowData>[
        MonthlyCashflowData(
          month: DateTime(2025, 1),
          income: 1000,
          expense: 200,
        ),
        MonthlyCashflowData(
          month: DateTime(2025, 2),
          income: 5000,
          expense: 1500,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MonthlyCashflowBarChartWidget(
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

      expect(find.byType(SfCartesianChart), findsOneWidget);
      expect(find.text('February'), findsOneWidget);
      expect(find.text('5K ₽'), findsOneWidget);
    },
  );
}
