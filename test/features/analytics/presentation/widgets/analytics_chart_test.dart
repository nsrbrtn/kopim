import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_chart.dart';

void main() {
  testWidgets('AnalyticsDonutChart renders percentage labels for segments', (
    WidgetTester tester,
  ) async {
    final List<AnalyticsChartItem> items = <AnalyticsChartItem>[
      const AnalyticsChartItem(title: 'A', amount: 60, color: Colors.red),
      const AnalyticsChartItem(title: 'B', amount: 40, color: Colors.blue),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: AnalyticsDonutChart(
                items: items,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('60%'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
  });

  testWidgets('AnalyticsDonutChart avoids overflow with many slices', (
    WidgetTester tester,
  ) async {
    final List<AnalyticsChartItem> items = <AnalyticsChartItem>[
      for (int index = 0; index < 6; index++)
        AnalyticsChartItem(
          title: 'Item $index',
          amount: 10 + index.toDouble(),
          color: Colors.primaries[index % Colors.primaries.length],
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: AnalyticsDonutChart(
                items: items,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
