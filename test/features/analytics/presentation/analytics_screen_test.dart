import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/presentation/analytics_screen.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_providers.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _FakeAnalyticsFilterController extends AnalyticsFilterController {
  _FakeAnalyticsFilterController(this._state);

  final AnalyticsFilterState _state;

  @override
  AnalyticsFilterState build() => _state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsScreen', () {
    testWidgets(
      'renders header with titleLarge typography and legend entries',
      (WidgetTester tester) async {
        final AnalyticsFilterState filterState = AnalyticsFilterState(
          dateRange: DateTimeRange(
            start: DateTime(2024, 1, 1),
            end: DateTime(2024, 1, 31),
          ),
        );

        const AnalyticsOverview overview = AnalyticsOverview(
          totalIncome: 0.0,
          totalExpense: 100.0,
          netBalance: -100.0,
          topExpenseCategories: <AnalyticsCategoryBreakdown>[
            AnalyticsCategoryBreakdown(categoryId: 'food', amount: 60.0),
            AnalyticsCategoryBreakdown(categoryId: 'transport', amount: 40.0),
          ],
          topIncomeCategories: <AnalyticsCategoryBreakdown>[],
        );

        final Category foodCategory = Category(
          id: 'food',
          name: 'Groceries',
          type: 'expense',
          color: '#FF5722',
          icon: null,
          parentId: null,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );
        final Category transportCategory = Category(
          id: 'transport',
          name: 'Transport',
          type: 'expense',
          color: '#03A9F4',
          icon: null,
          parentId: null,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: <Override>[
              analyticsFilterControllerProvider.overrideWith(
                () => _FakeAnalyticsFilterController(filterState),
              ),
              analyticsFilteredStatsProvider(
                topCategoriesLimit: 5,
              ).overrideWith(
                (Ref ref) => Stream<AnalyticsOverview>.value(overview),
              ),
              analyticsCategoriesProvider.overrideWith(
                (Ref ref) => Stream<List<Category>>.value(<Category>[
                  foodCategory,
                  transportCategory,
                ]),
              ),
              analyticsAccountsProvider.overrideWith(
                (Ref ref) => Stream<List<AccountEntity>>.value(<AccountEntity>[
                  AccountEntity(
                    id: 'acc',
                    name: 'Main',
                    balance: 0,
                    currency: 'USD',
                    type: 'checking',
                    createdAt: DateTime(2023, 1, 1),
                    updatedAt: DateTime(2023, 1, 1),
                    isDeleted: false,
                  ),
                ]),
              ),
            ],
            // ignore: prefer_const_constructors
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AnalyticsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final BuildContext context = tester.element(
          find.byType(AnalyticsScreen),
        );
        final AppLocalizations strings = AppLocalizations.of(context)!;
        final ThemeData theme = Theme.of(context);
        final DateFormat rangeFormat = DateFormat.yMMMMd(strings.localeName);
        final String start = rangeFormat.format(filterState.dateRange.start);
        final String end = rangeFormat.format(filterState.dateRange.end);
        final String rangeLabel = start == end
            ? start
            : strings.analyticsFilterDateValue(start, end);
        final String expectedHeader = strings.analyticsOverviewRangeTitle(
          rangeLabel,
        );

        final Text headerText = tester.widget<Text>(find.text(expectedHeader));
        expect(headerText.style, theme.textTheme.titleLarge);

        final Iterable<Card> cards = tester.widgetList<Card>(find.byType(Card));
        for (final Card card in cards) {
          expect(card.elevation, 0);
          expect(card.surfaceTintColor, Colors.transparent);
        }

        expect(find.text('Groceries'), findsOneWidget);
        expect(find.text('Transport'), findsOneWidget);

        final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
          locale: strings.localeName,
        );
        expect(find.text(currencyFormat.format(60)), findsWidgets);
      },
    );
  });
}
