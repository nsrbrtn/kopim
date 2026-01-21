import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/presentation/analytics_screen.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_providers.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _FakeAnalyticsFilterController extends AnalyticsFilterController {
  _FakeAnalyticsFilterController(this._state);

  final AnalyticsFilterState _state;

  @override
  AnalyticsFilterState build() => _state;
}

class _EmptyTransactionRepository implements TransactionRepository {
  @override
  Stream<List<TransactionEntity>> watchTransactions() =>
      const Stream<List<TransactionEntity>>.empty();

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) =>
      const Stream<List<TransactionEntity>>.empty();

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) => const Stream<List<AccountMonthlyTotals>>.empty();

  @override
  Future<List<TransactionEntity>> loadTransactions() async =>
      const <TransactionEntity>[];

  @override
  Future<TransactionEntity?> findById(String id) async => null;

  @override
  Future<void> upsert(TransactionEntity transaction) async {}

  @override
  Future<void> softDelete(String id) async {}
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

        final AnalyticsOverview overview = AnalyticsOverview(
          totalIncome: _amount(0),
          totalExpense: _amount(100),
          netBalance: _amount(-100),
          topExpenseCategories: <AnalyticsCategoryBreakdown>[
            AnalyticsCategoryBreakdown(categoryId: 'food', amount: _amount(60)),
            AnalyticsCategoryBreakdown(
              categoryId: 'transport',
              amount: _amount(40),
            ),
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
        final TransactionRepository transactionRepository =
            _EmptyTransactionRepository();

        await tester.pumpWidget(
          ProviderScope(
            overrides: <Override>[
              transactionRepositoryProvider.overrideWithValue(
                transactionRepository,
              ),
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
                    balanceMinor: BigInt.zero,
                    currency: 'USD',
                    currencyScale: 2,
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
        final Text headerText = tester.widget<Text>(
          find.text(strings.analyticsTitle),
        );
        expect(headerText.style, theme.textTheme.headlineSmall);

        expect(find.text('Groceries'), findsOneWidget);
        expect(find.text('Transport'), findsOneWidget);

        final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
          locale: strings.localeName,
        );
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is Tooltip &&
                widget.message == currencyFormat.format(60),
          ),
          findsOneWidget,
        );

        expect(find.text(strings.analyticsTitle), findsOneWidget);
      },
    );

    testWidgets('date filter button handles narrow layouts without overflow', (
      WidgetTester tester,
    ) async {
      final AnalyticsFilterState filterState = AnalyticsFilterState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 10, 10),
          end: DateTime(2024, 10, 21),
        ),
      );

      final AnalyticsOverview overview = AnalyticsOverview(
        totalIncome: _amount(50),
        totalExpense: _amount(120),
        netBalance: _amount(-70),
        topExpenseCategories: <AnalyticsCategoryBreakdown>[
          AnalyticsCategoryBreakdown(categoryId: 'food', amount: _amount(80)),
        ],
        topIncomeCategories: <AnalyticsCategoryBreakdown>[
          AnalyticsCategoryBreakdown(categoryId: 'salary', amount: _amount(50)),
        ],
      );

      final Category foodCategory = Category(
        id: 'food',
        name: 'Food',
        type: 'expense',
        color: '#FF9800',
        icon: null,
        parentId: null,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );
      final Category salaryCategory = Category(
        id: 'salary',
        name: 'Salary',
        type: 'income',
        color: '#4CAF50',
        icon: null,
        parentId: null,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );
      final TransactionRepository transactionRepository =
          _EmptyTransactionRepository();

      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            transactionRepositoryProvider.overrideWithValue(
              transactionRepository,
            ),
            analyticsFilterControllerProvider.overrideWith(
              () => _FakeAnalyticsFilterController(filterState),
            ),
            analyticsFilteredStatsProvider(topCategoriesLimit: 5).overrideWith(
              (Ref ref) => Stream<AnalyticsOverview>.value(overview),
            ),
            analyticsCategoriesProvider.overrideWith(
              (Ref ref) => Stream<List<Category>>.value(<Category>[
                foodCategory,
                salaryCategory,
              ]),
            ),
            analyticsAccountsProvider.overrideWith(
              (Ref ref) => Stream<List<AccountEntity>>.value(<AccountEntity>[
                AccountEntity(
                  id: 'acc',
                  name: 'Main',
                  balanceMinor: BigInt.zero,
                  currency: 'USD',
                  currencyScale: 2,
                  type: 'checking',
                  createdAt: DateTime(2023, 1, 1),
                  updatedAt: DateTime(2023, 1, 1),
                  isDeleted: false,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('top categories segmented button renders without outline', (
      WidgetTester tester,
    ) async {
      final AnalyticsFilterState filterState = AnalyticsFilterState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
      );

      final AnalyticsOverview overview = AnalyticsOverview(
        totalIncome: _amount(80),
        totalExpense: _amount(120),
        netBalance: _amount(-40),
        topExpenseCategories: <AnalyticsCategoryBreakdown>[
          AnalyticsCategoryBreakdown(categoryId: 'food', amount: _amount(120)),
        ],
        topIncomeCategories: <AnalyticsCategoryBreakdown>[
          AnalyticsCategoryBreakdown(categoryId: 'salary', amount: _amount(80)),
        ],
      );

      final Category foodCategory = Category(
        id: 'food',
        name: 'Food',
        type: 'expense',
        color: '#FF9800',
        icon: null,
        parentId: null,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );
      final Category salaryCategory = Category(
        id: 'salary',
        name: 'Salary',
        type: 'income',
        color: '#4CAF50',
        icon: null,
        parentId: null,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );
      final TransactionRepository transactionRepository =
          _EmptyTransactionRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            transactionRepositoryProvider.overrideWithValue(
              transactionRepository,
            ),
            analyticsFilterControllerProvider.overrideWith(
              () => _FakeAnalyticsFilterController(filterState),
            ),
            analyticsFilteredStatsProvider(topCategoriesLimit: 5).overrideWith(
              (Ref ref) => Stream<AnalyticsOverview>.value(overview),
            ),
            analyticsCategoriesProvider.overrideWith(
              (Ref ref) => Stream<List<Category>>.value(<Category>[
                foodCategory,
                salaryCategory,
              ]),
            ),
            analyticsAccountsProvider.overrideWith(
              (Ref ref) => Stream<List<AccountEntity>>.value(<AccountEntity>[
                AccountEntity(
                  id: 'acc',
                  name: 'Main',
                  balanceMinor: BigInt.zero,
                  currency: 'USD',
                  currencyScale: 2,
                  type: 'checking',
                  createdAt: DateTime(2023, 1, 1),
                  updatedAt: DateTime(2023, 1, 1),
                  isDeleted: false,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(AnalyticsScreen));
      final AppLocalizations strings = AppLocalizations.of(context)!;

      expect(
        find.text(strings.analyticsTopCategoriesExpensesTab),
        findsWidgets,
      );
      expect(find.text(strings.analyticsTopCategoriesIncomeTab), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('раскрывает детали "Остальные" при выборе категории', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final AnalyticsFilterState filterState = AnalyticsFilterState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 5, 1),
          end: DateTime(2024, 5, 31),
        ),
      );

      final AnalyticsOverview overview = AnalyticsOverview(
        totalIncome: _amount(0),
        totalExpense: _amount(150),
        netBalance: _amount(-150),
        topExpenseCategories: <AnalyticsCategoryBreakdown>[
          AnalyticsCategoryBreakdown(categoryId: 'food', amount: _amount(60)),
          AnalyticsCategoryBreakdown(
            categoryId: 'transport',
            amount: _amount(40),
          ),
          AnalyticsCategoryBreakdown(
            categoryId: '_others',
            amount: _amount(50),
            children: <AnalyticsCategoryBreakdown>[
              AnalyticsCategoryBreakdown(
                categoryId: 'coffee',
                amount: _amount(20),
              ),
              AnalyticsCategoryBreakdown(
                categoryId: 'books',
                amount: _amount(30),
              ),
            ],
          ),
        ],
        topIncomeCategories: <AnalyticsCategoryBreakdown>[],
      );

      final Category foodCategory = Category(
        id: 'food',
        name: 'Food',
        type: 'expense',
        color: '#FF9800',
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
      final Category coffeeCategory = Category(
        id: 'coffee',
        name: 'Coffee',
        type: 'expense',
        color: '#795548',
        icon: null,
        parentId: null,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );
      final Category booksCategory = Category(
        id: 'books',
        name: 'Books',
        type: 'expense',
        color: '#9C27B0',
        icon: null,
        parentId: null,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );
      final TransactionRepository transactionRepository =
          _EmptyTransactionRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            transactionRepositoryProvider.overrideWithValue(
              transactionRepository,
            ),
            analyticsFilterControllerProvider.overrideWith(
              () => _FakeAnalyticsFilterController(filterState),
            ),
            analyticsFilteredStatsProvider(topCategoriesLimit: 5).overrideWith(
              (Ref ref) => Stream<AnalyticsOverview>.value(overview),
            ),
            analyticsCategoriesProvider.overrideWith(
              (Ref ref) => Stream<List<Category>>.value(<Category>[
                foodCategory,
                transportCategory,
                coffeeCategory,
                booksCategory,
              ]),
            ),
            analyticsAccountsProvider.overrideWith(
              (Ref ref) => Stream<List<AccountEntity>>.value(<AccountEntity>[
                AccountEntity(
                  id: 'acc',
                  name: 'Main',
                  balanceMinor: BigInt.zero,
                  currency: 'USD',
                  currencyScale: 2,
                  type: 'checking',
                  createdAt: DateTime(2023, 1, 1),
                  updatedAt: DateTime(2023, 1, 1),
                  isDeleted: false,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(AnalyticsScreen));
      final AppLocalizations strings = AppLocalizations.of(context)!;

      final Finder othersFinder = find.text(
        strings.analyticsTopCategoriesOthers,
      );
      await tester.tap(othersFinder);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
    });
  });
}

MoneyAmount _amount(num value, {int scale = 2}) {
  final double scaled = value * 100;
  return MoneyAmount(minor: BigInt.from(scaled.round()), scale: scale);
}
