import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/domain/models/home_overview_summary.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/home/presentation/widgets/home_overview_summary_card.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:riverpod/src/framework.dart' show Override;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeOverviewSummaryCard', () {
    Future<void> pumpOverviewCard(
      WidgetTester tester, {
      required List<Override> overrides,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: HomeOverviewSummaryCard(onTap: _noop)),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('renders balance, daily summary and top category', (
      WidgetTester tester,
    ) async {
      const HomeOverviewSummary summary = HomeOverviewSummary(
        totalBalance: 128987,
        todayIncome: 12000,
        todayExpense: 8000,
        topExpenseCategory: HomeTopExpenseCategory(
          categoryId: 'food',
          amount: 8000,
        ),
      );

      final Category food = Category(
        id: 'food',
        name: 'Food',
        type: 'expense',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await pumpOverviewCard(
        tester,
        overrides: <Override>[
          homeOverviewSummaryProvider.overrideWith(
            (Ref ref) => Stream<HomeOverviewSummary>.value(summary),
          ),
          homeCategoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(<Category>[food]),
          ),
        ],
      );

      expect(find.text('Total balance'), findsOneWidget);
      expect(find.text('Top expenses'), findsOneWidget);
      expect(find.textContaining('Income:'), findsOneWidget);
      expect(find.textContaining('Expense:'), findsWidgets);
      expect(find.text('Food'), findsOneWidget);
    });
  });
}

void _noop() {}
