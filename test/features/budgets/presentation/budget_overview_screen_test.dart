import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/presentation/budget_overview_screen.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/profile/presentation/controllers/active_currency_code_provider.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/presentation/providers/upcoming_payment_selection_providers.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:riverpod/src/framework.dart' show Override;

class _FakeTimeService implements TimeService {
  @override
  DateTime nowLocal() => DateTime(2024, 1, 15);

  @override
  int nowMs() => DateTime(2024, 1, 15).millisecondsSinceEpoch;

  @override
  DateTime toLocal(int epochMs) =>
      DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: false);

  @override
  int toEpochMs(DateTime dt) => dt.millisecondsSinceEpoch;

  @override
  DateTime atLocalDateTime(
    int year,
    int month,
    int day,
    int hour,
    int minute,
  ) => DateTime(year, month, day, hour, minute);

  @override
  int parseHhmmToMinutes(String hhmm) {
    final List<String> parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BudgetOverviewScreen Category Sorting', () {
    final Budget budget = Budget(
      id: 'budget-1',
      title: 'Food & Trans',
      period: BudgetPeriod.monthly,
      startDate: DateTime(2024, 1, 1),
      amountMinor: BigInt.from(80000),
      amountScale: 2,
      scope: BudgetScope.byCategory,
      categories: const <String>['cat-1', 'cat-2', 'cat-3'],
      categoryAllocations: <BudgetCategoryAllocation>[
        BudgetCategoryAllocation(
          categoryId: 'cat-1', // Category A
          limitMinor: BigInt.from(10000), // Limit: 100
          limitScale: 2,
        ),
        BudgetCategoryAllocation(
          categoryId: 'cat-2', // Category B
          limitMinor: BigInt.from(50000), // Limit: 500
          limitScale: 2,
        ),
        BudgetCategoryAllocation(
          categoryId: 'cat-3', // Category C
          limitMinor: BigInt.from(20000), // Limit: 200
          limitScale: 2,
        ),
      ],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final BudgetInstance instance = BudgetInstance(
      id: 'instance-1',
      budgetId: 'budget-1',
      periodStart: DateTime(2024, 1, 1),
      periodEnd: DateTime(2024, 1, 31),
      amountMinor: BigInt.from(80000),
      spentMinor: BigInt.from(0),
      amountScale: 2,
      status: BudgetInstanceStatus.active,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final BudgetProgress progress = BudgetProgress(
      budget: budget,
      instance: instance,
      spent: MoneyAmount(minor: BigInt.from(0), scale: 2),
      remaining: MoneyAmount(minor: BigInt.from(80000), scale: 2),
      utilization: 0.0,
      isExceeded: false,
    );

    final List<Category> categories = <Category>[
      Category(
        id: 'cat-1',
        name: 'Category A',
        type: 'expense',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Category(
        id: 'cat-2',
        name: 'Category B',
        type: 'expense',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Category(
        id: 'cat-3',
        name: 'Category C',
        type: 'expense',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ];

    List<Override> getCommonOverrides({
      required List<TransactionEntity> transactions,
    }) {
      return <Override>[
        budgetProgressByIdProvider(
          'budget-1',
        ).overrideWithValue(AsyncValue<BudgetProgress>.data(progress)),
        budgetTransactionsStreamProvider.overrideWith(
          (Ref ref) => Stream<List<TransactionEntity>>.value(transactions),
        ),
        budgetCategoriesStreamProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(categories),
        ),
        budgetAccountsStreamProvider.overrideWith(
          (Ref ref) =>
              Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
        ),
        homeUpcomingItemsProvider(limit: 12).overrideWithValue(
          const AsyncValue<List<UpcomingItem>>.data(<UpcomingItem>[]),
        ),
        watchUpcomingPaymentsProvider.overrideWith(
          (Ref ref) =>
              Stream<List<UpcomingPayment>>.value(const <UpcomingPayment>[]),
        ),
        upcomingPaymentAccountsProvider.overrideWith(
          (Ref ref) =>
              Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
        ),
        upcomingPaymentCategoriesProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
        ),
        timeServiceProvider.overrideWithValue(_FakeTimeService()),
        activeCurrencyCodeProvider.overrideWithValue('USD'),
      ];
    }

    testWidgets('sorts categories by limit descending when spent is equal', (
      WidgetTester tester,
    ) async {
      // No transactions => all spent = 0.
      // Expected order by limit descending: Category B (500) -> Category C (200) -> Category A (100)
      final ProviderContainer container = ProviderContainer(
        overrides: getCommonOverrides(
          transactions: const <TransactionEntity>[],
        ),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: BudgetOverviewScreen(budgetId: 'budget-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Iterable<Widget> nameWidgets = tester.widgetList(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.style?.fontWeight == FontWeight.w600,
        ),
      );

      final List<String?> categoryNames = nameWidgets
          .map((Widget w) => (w as Text).data)
          .where((String? name) => name != null && name.startsWith('Category'))
          .toList();

      expect(categoryNames, <String>['Category B', 'Category C', 'Category A']);
    });

    testWidgets(
      'sorts categories by spent descending first, then by limit descending',
      (WidgetTester tester) async {
        // Category A (Limit: 100) has spent 50.
        // Category B (Limit: 500) has spent 0.
        // Category C (Limit: 200) has spent 0.
        // Expected order: Category A (Spent: 50, Limit: 100) -> Category B (Spent: 0, Limit: 500) -> Category C (Spent: 0, Limit: 200)
        final TransactionEntity tx = TransactionEntity(
          id: 'tx-1',
          accountId: 'acc-1',
          categoryId: 'cat-1',
          amountMinor: BigInt.from(-5000), // -50
          amountScale: 2,
          date: DateTime(2024, 1, 10),
          type: 'expense',
          createdAt: DateTime(2024, 1, 10),
          updatedAt: DateTime(2024, 1, 10),
        );

        final ProviderContainer container = ProviderContainer(
          overrides: getCommonOverrides(transactions: <TransactionEntity>[tx]),
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('en'),
              home: BudgetOverviewScreen(budgetId: 'budget-1'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final Iterable<Widget> nameWidgets = tester.widgetList(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is Text && widget.style?.fontWeight == FontWeight.w600,
          ),
        );

        final List<String?> categoryNames = nameWidgets
            .map((Widget w) => (w as Text).data)
            .where(
              (String? name) => name != null && name.startsWith('Category'),
            )
            .toList();

        expect(categoryNames, <String>[
          'Category A',
          'Category B',
          'Category C',
        ]);
      },
    );
  });
}
