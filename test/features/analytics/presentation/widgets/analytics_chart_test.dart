import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_chart.dart';

void main() {
  testWidgets('AnalyticsDonutChart отображает иконки для сегментов ≥5%', (
    WidgetTester tester,
  ) async {
    final List<AnalyticsChartItem> items = <AnalyticsChartItem>[
      const AnalyticsChartItem(
        key: 'a',
        title: 'A',
        amount: 60,
        color: Colors.red,
        icon: Icons.star,
      ),
      const AnalyticsChartItem(
        key: 'b',
        title: 'B',
        amount: 40,
        color: Colors.blue,
        icon: Icons.favorite,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              height: 360,
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

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
  });

  testWidgets('AnalyticsDonutChart avoids overflow with many slices', (
    WidgetTester tester,
  ) async {
    final List<AnalyticsChartItem> items = <AnalyticsChartItem>[
      for (int index = 0; index < 6; index++)
        AnalyticsChartItem(
          key: 'item-$index',
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

  testWidgets('AnalyticsDonutChart скрывает иконки для сегментов <5%', (
    WidgetTester tester,
  ) async {
    final List<AnalyticsChartItem> items = <AnalyticsChartItem>[
      const AnalyticsChartItem(
        key: 'major',
        title: 'Major',
        amount: 94,
        color: Colors.green,
        icon: Icons.wallet,
      ),
      const AnalyticsChartItem(
        key: 'minor',
        title: 'Minor',
        amount: 6,
        color: Colors.orange,
        icon: Icons.warning,
      ),
      const AnalyticsChartItem(
        key: 'tiny',
        title: 'Tiny',
        amount: 1,
        color: Colors.purple,
        icon: Icons.close,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
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

    expect(find.byIcon(Icons.wallet), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });
}
