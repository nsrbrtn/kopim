import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/application/sync_status_provider.dart';
import 'package:kopim/core/config/theme.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/services/sync_status.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/use_cases/watch_accounts_use_case.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/repositories/credit_card_repository.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/use_cases/watch_credit_cards_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/watch_credits_use_case.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/features/home/domain/models/home_overview_summary.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/home/presentation/screens/home_screen.dart';
import 'package:kopim/features/overview/domain/entities/overview_preferences.dart';
import 'package:kopim/features/overview/presentation/controllers/overview_preferences_controller.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/models/budget_expense_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_recent_transactions_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_account_monthly_totals_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:riverpod/src/framework.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home providers', () {
    late StreamController<List<AccountEntity>> accountsController;
    late StreamController<List<TransactionEntity>> transactionsController;
    late ProviderContainer container;

    setUp(() {
      accountsController = StreamController<List<AccountEntity>>.broadcast();
      transactionsController =
          StreamController<List<TransactionEntity>>.broadcast();

      container = ProviderContainer(
        overrides: <Override>[
          watchAccountsUseCaseProvider.overrideWithValue(
            WatchAccountsUseCase(
              _InMemoryAccountRepository(accountsController.stream),
            ),
          ),
          watchRecentTransactionsUseCaseProvider.overrideWithValue(
            WatchRecentTransactionsUseCase(
              _InMemoryTransactionRepository(transactionsController.stream),
            ),
          ),
          watchAccountMonthlyTotalsUseCaseProvider.overrideWithValue(
            WatchAccountMonthlyTotalsUseCase(
              _InMemoryTransactionRepository(transactionsController.stream),
            ),
          ),
          watchCreditsUseCaseProvider.overrideWithValue(
            _StubWatchCreditsUseCase(
              Stream<List<CreditEntity>>.value(const <CreditEntity>[]),
            ),
          ),
          watchCreditCardsUseCaseProvider.overrideWithValue(
            _StubWatchCreditCardsUseCase(
              Stream<List<CreditCardEntity>>.value(const <CreditCardEntity>[]),
            ),
          ),
        ],
      );
    });

    tearDown(() async {
      await accountsController.close();
      await transactionsController.close();
      container.dispose();
    });

    test('homeAccountsProvider exposes the account stream', () async {
      final List<AccountEntity> expectedAccounts = <AccountEntity>[
        _account('1'),
        _account('2'),
      ];

      final Completer<List<AccountEntity>> completer =
          Completer<List<AccountEntity>>();
      final ProviderSubscription<AsyncValue<List<AccountEntity>>> subscription =
          container.listen(homeAccountsProvider, (
            AsyncValue<List<AccountEntity>>? previous,
            AsyncValue<List<AccountEntity>> next,
          ) {
            next.whenData((List<AccountEntity> accounts) {
              if (!completer.isCompleted) {
                completer.complete(accounts);
              }
            });
          }, fireImmediately: true);
      addTearDown(subscription.close);

      accountsController.add(expectedAccounts);

      expect(await completer.future, expectedAccounts);
    });

    test(
      'homeRecentTransactionsProvider forwards the limit to the use case',
      () async {
        final List<TransactionEntity> expectedTransactions =
            <TransactionEntity>[_transaction('1'), _transaction('2')];
        final _RecordingWatchRecentTransactionsUseCase recordingUseCase =
            _RecordingWatchRecentTransactionsUseCase(
              transactionsController.stream,
            );

        final ProviderContainer scopedContainer = ProviderContainer(
          overrides: <Override>[
            watchRecentTransactionsUseCaseProvider.overrideWithValue(
              recordingUseCase,
            ),
          ],
        );

        addTearDown(scopedContainer.dispose);

        final Completer<List<TransactionEntity>> completer =
            Completer<List<TransactionEntity>>();
        final ProviderSubscription<AsyncValue<List<TransactionEntity>>>
        subscription = scopedContainer
            .listen(homeRecentTransactionsProvider(limit: 7), (
              AsyncValue<List<TransactionEntity>>? previous,
              AsyncValue<List<TransactionEntity>> next,
            ) {
              next.whenData((List<TransactionEntity> transactions) {
                if (!completer.isCompleted) {
                  completer.complete(transactions);
                }
              });
            }, fireImmediately: true);
        addTearDown(subscription.close);

        transactionsController.add(expectedTransactions);

        expect(await completer.future, expectedTransactions);
        expect(recordingUseCase.lastLimit, 7);
      },
    );

    test(
      'homeRecentTransactionsProvider uses the default limit when omitted',
      () async {
        final StreamController<List<TransactionEntity>> controller =
            StreamController<List<TransactionEntity>>.broadcast();
        addTearDown(controller.close);

        final _RecordingWatchRecentTransactionsUseCase recordingUseCase =
            _RecordingWatchRecentTransactionsUseCase(controller.stream);

        final ProviderContainer scopedContainer = ProviderContainer(
          overrides: <Override>[
            watchRecentTransactionsUseCaseProvider.overrideWithValue(
              recordingUseCase,
            ),
          ],
        );
        addTearDown(scopedContainer.dispose);

        final Completer<List<TransactionEntity>> completer =
            Completer<List<TransactionEntity>>();
        final ProviderSubscription<AsyncValue<List<TransactionEntity>>>
        subscription = scopedContainer
            .listen(homeRecentTransactionsProvider(), (
              AsyncValue<List<TransactionEntity>>? previous,
              AsyncValue<List<TransactionEntity>> next,
            ) {
              next.whenData((List<TransactionEntity> transactions) {
                if (!completer.isCompleted) {
                  completer.complete(transactions);
                }
              });
            }, fireImmediately: true);
        addTearDown(subscription.close);

        controller.add(<TransactionEntity>[_transaction('a')]);

        await completer.future;
        expect(recordingUseCase.lastLimit, kDefaultRecentTransactionsLimit);
      },
    );

    test(
      'homeAccountMonthlySummariesProvider aggregates current month income and expenses',
      () async {
        final DateTime now = DateTime.now();
        final TransactionEntity incomeTransaction = _transaction('income')
            .copyWith(
              accountId: 'account-1',
              amountMinor: BigInt.from(12000),
              amountScale: 2,
              type: TransactionType.income.storageValue,
              date: now,
            );
        final TransactionEntity expenseTransaction = _transaction('expense')
            .copyWith(
              accountId: 'account-1',
              amountMinor: BigInt.from(4500),
              amountScale: 2,
              type: TransactionType.expense.storageValue,
              date: now.subtract(const Duration(hours: 1)),
            );
        final TransactionEntity otherAccountTransaction = _transaction('other')
            .copyWith(
              accountId: 'account-2',
              amountMinor: BigInt.from(7500),
              amountScale: 2,
              type: TransactionType.expense.storageValue,
              date: now,
            );
        final TransactionEntity previousMonthTransaction = _transaction('past')
            .copyWith(
              accountId: 'account-1',
              amountMinor: BigInt.from(99900),
              amountScale: 2,
              type: TransactionType.income.storageValue,
              date: DateTime(now.year, now.month - 1, 15),
            );

        final Completer<Map<String, HomeAccountMonthlySummary>> completer =
            Completer<Map<String, HomeAccountMonthlySummary>>();
        final ProviderSubscription<
          AsyncValue<Map<String, HomeAccountMonthlySummary>>
        >
        subscription = container.listen(homeAccountMonthlySummariesProvider, (
          AsyncValue<Map<String, HomeAccountMonthlySummary>>? previous,
          AsyncValue<Map<String, HomeAccountMonthlySummary>> next,
        ) {
          next.whenData((Map<String, HomeAccountMonthlySummary> summaries) {
            if (!completer.isCompleted) {
              completer.complete(summaries);
            }
          });
        }, fireImmediately: true);
        addTearDown(subscription.close);

        transactionsController.add(<TransactionEntity>[
          incomeTransaction,
          expenseTransaction,
          otherAccountTransaction,
          previousMonthTransaction,
        ]);

        final Map<String, HomeAccountMonthlySummary> summaries =
            await completer.future;
        expect(
          summaries['account-1'],
          HomeAccountMonthlySummary(
            income: MoneyAmount(minor: BigInt.from(12000), scale: 2),
            expense: MoneyAmount(minor: BigInt.from(4500), scale: 2),
          ),
        );
        expect(
          summaries['account-2'],
          HomeAccountMonthlySummary(
            income: MoneyAmount(minor: BigInt.zero, scale: 2),
            expense: MoneyAmount(minor: BigInt.from(7500), scale: 2),
          ),
        );
        expect(summaries.containsKey('account-3'), isFalse);
      },
    );
  });

  group('Home screen', () {
    Future<void> pumpHomeBody(
      WidgetTester tester, {
      required List<Override> overrides,
      ThemeMode themeMode = ThemeMode.light,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            darkTheme: buildAppTheme(brightness: Brightness.dark),
            themeMode: themeMode,
            locale: const Locale('ru'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final NavigationTabContent content = buildHomeTabContent(
                  context,
                  ref,
                );
                return Scaffold(body: content.bodyBuilder(context, ref));
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('renders monthly income and expense under account balance', (
      WidgetTester tester,
    ) async {
      final DateTime now = DateTime.now();
      final AccountEntity account = AccountEntity(
        id: 'cash-1',
        name: 'Основной счет',
        balanceMinor: BigInt.from(128987),
        currency: 'RUB',
        currencyScale: 2,
        type: 'cash',
        createdAt: now,
        updatedAt: now,
      );

      await pumpHomeBody(
        tester,
        overrides: <Override>[
          authControllerProvider.overrideWith(() => _FakeAuthController(null)),
          homeDashboardPreferencesControllerProvider.overrideWith(
            () => _FakeHomeDashboardPreferencesController(),
          ),
          overviewPreferencesControllerProvider.overrideWith(
            () => _FakeOverviewPreferencesController(),
          ),
          syncStatusProvider.overrideWith(
            (Ref ref) => Stream<SyncStatus>.value(SyncStatus.offline),
          ),
          timeServiceProvider.overrideWith(
            (Ref ref) => const SystemTimeService(),
          ),
          homeAccountsProvider.overrideWith(
            (Ref ref) =>
                Stream<List<AccountEntity>>.value(<AccountEntity>[account]),
          ),
          homeAccountMonthlySummariesProvider.overrideWith(
            (Ref ref) => Stream<Map<String, HomeAccountMonthlySummary>>.value(
              <String, HomeAccountMonthlySummary>{
                account.id: HomeAccountMonthlySummary(
                  income: MoneyAmount(minor: BigInt.from(12000), scale: 2),
                  expense: MoneyAmount(minor: BigInt.from(8000), scale: 2),
                ),
              },
            ),
          ),
          homeOverviewSummaryProvider.overrideWith(
            (Ref ref) => Stream<HomeOverviewSummary>.value(
              HomeOverviewSummary(
                totalBalance: MoneyAmount(minor: BigInt.from(128987), scale: 2),
                todayIncome: MoneyAmount(minor: BigInt.zero, scale: 2),
                todayExpense: MoneyAmount(minor: BigInt.zero, scale: 2),
              ),
            ),
          ),
          homeCategoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
          ),
          homeGroupedTransactionsProvider.overrideWith(
            (Ref ref) =>
                const AsyncValue<List<DaySection>>.data(<DaySection>[]),
          ),
          homeUpcomingItemsProvider(limit: 6).overrideWith(
            (Ref ref) =>
                Stream<List<UpcomingItem>>.value(const <UpcomingItem>[]),
          ),
        ],
      );

      expect(find.text('Основной счет'), findsOneWidget);
      expect(find.text('В этом месяце'), findsOneWidget);
      expect(find.textContaining('Доход:'), findsWidgets);
      expect(find.textContaining('Расход:'), findsWidgets);
    });

    testWidgets(
      'uses the same default account card color in light and dark themes',
      (WidgetTester tester) async {
        final DateTime now = DateTime.now();
        final AccountEntity account = AccountEntity(
          id: 'cash-1',
          name: 'Основной счет',
          balanceMinor: BigInt.from(128987),
          currency: 'RUB',
          currencyScale: 2,
          type: 'cash',
          createdAt: now,
          updatedAt: now,
        );

        Future<Color?> pumpAndReadCardColor(ThemeMode themeMode) async {
          await pumpHomeBody(
            tester,
            themeMode: themeMode,
            overrides: <Override>[
              authControllerProvider.overrideWith(
                () => _FakeAuthController(null),
              ),
              homeDashboardPreferencesControllerProvider.overrideWith(
                () => _FakeHomeDashboardPreferencesController(),
              ),
              overviewPreferencesControllerProvider.overrideWith(
                () => _FakeOverviewPreferencesController(),
              ),
              syncStatusProvider.overrideWith(
                (Ref ref) => Stream<SyncStatus>.value(SyncStatus.offline),
              ),
              timeServiceProvider.overrideWith(
                (Ref ref) => const SystemTimeService(),
              ),
              homeAccountsProvider.overrideWith(
                (Ref ref) =>
                    Stream<List<AccountEntity>>.value(<AccountEntity>[account]),
              ),
              homeAccountMonthlySummariesProvider.overrideWith(
                (
                  Ref ref,
                ) => Stream<Map<String, HomeAccountMonthlySummary>>.value(
                  <String, HomeAccountMonthlySummary>{
                    account.id: HomeAccountMonthlySummary(
                      income: MoneyAmount(minor: BigInt.from(12000), scale: 2),
                      expense: MoneyAmount(minor: BigInt.from(8000), scale: 2),
                    ),
                  },
                ),
              ),
              homeOverviewSummaryProvider.overrideWith(
                (Ref ref) => Stream<HomeOverviewSummary>.value(
                  HomeOverviewSummary(
                    totalBalance: MoneyAmount(
                      minor: BigInt.from(128987),
                      scale: 2,
                    ),
                    todayIncome: MoneyAmount(minor: BigInt.zero, scale: 2),
                    todayExpense: MoneyAmount(minor: BigInt.zero, scale: 2),
                  ),
                ),
              ),
              homeCategoriesProvider.overrideWith(
                (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
              ),
              homeGroupedTransactionsProvider.overrideWith(
                (Ref ref) =>
                    const AsyncValue<List<DaySection>>.data(<DaySection>[]),
              ),
              homeUpcomingItemsProvider(limit: 6).overrideWith(
                (Ref ref) =>
                    Stream<List<UpcomingItem>>.value(const <UpcomingItem>[]),
              ),
            ],
          );

          final Finder cardFinder = find.ancestor(
            of: find.text('Основной счет'),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is Ink && widget.decoration is BoxDecoration,
            ),
          );
          final Ink cardInk = tester.widget<Ink>(cardFinder.first);
          final BoxDecoration decoration = cardInk.decoration! as BoxDecoration;
          return decoration.color;
        }

        final Color? lightColor = await pumpAndReadCardColor(ThemeMode.light);
        final Color? darkColor = await pumpAndReadCardColor(ThemeMode.dark);

        expect(lightColor, isNotNull);
        expect(darkColor, isNotNull);
        expect(lightColor, darkColor);
      },
    );

    testWidgets(
      'uses darker secondary text and eye icon colors in light theme',
      (WidgetTester tester) async {
        final DateTime now = DateTime.now();
        final AccountEntity account = AccountEntity(
          id: 'cash-1',
          name: 'Основной счет',
          balanceMinor: BigInt.from(128987),
          currency: 'RUB',
          currencyScale: 2,
          type: 'cash',
          createdAt: now,
          updatedAt: now,
        );

        await pumpHomeBody(
          tester,
          themeMode: ThemeMode.light,
          overrides: <Override>[
            authControllerProvider.overrideWith(
              () => _FakeAuthController(null),
            ),
            homeDashboardPreferencesControllerProvider.overrideWith(
              () => _FakeHomeDashboardPreferencesController(),
            ),
            overviewPreferencesControllerProvider.overrideWith(
              () => _FakeOverviewPreferencesController(),
            ),
            syncStatusProvider.overrideWith(
              (Ref ref) => Stream<SyncStatus>.value(SyncStatus.offline),
            ),
            timeServiceProvider.overrideWith(
              (Ref ref) => const SystemTimeService(),
            ),
            homeAccountsProvider.overrideWith(
              (Ref ref) =>
                  Stream<List<AccountEntity>>.value(<AccountEntity>[account]),
            ),
            homeAccountMonthlySummariesProvider.overrideWith(
              (Ref ref) => Stream<Map<String, HomeAccountMonthlySummary>>.value(
                <String, HomeAccountMonthlySummary>{
                  account.id: HomeAccountMonthlySummary(
                    income: MoneyAmount(minor: BigInt.from(12000), scale: 2),
                    expense: MoneyAmount(minor: BigInt.from(8000), scale: 2),
                  ),
                },
              ),
            ),
            homeOverviewSummaryProvider.overrideWith(
              (Ref ref) => Stream<HomeOverviewSummary>.value(
                HomeOverviewSummary(
                  totalBalance: MoneyAmount(
                    minor: BigInt.from(128987),
                    scale: 2,
                  ),
                  todayIncome: MoneyAmount(minor: BigInt.zero, scale: 2),
                  todayExpense: MoneyAmount(minor: BigInt.zero, scale: 2),
                ),
              ),
            ),
            homeCategoriesProvider.overrideWith(
              (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
            ),
            homeGroupedTransactionsProvider.overrideWith(
              (Ref ref) =>
                  const AsyncValue<List<DaySection>>.data(<DaySection>[]),
            ),
            homeUpcomingItemsProvider(limit: 6).overrideWith(
              (Ref ref) =>
                  Stream<List<UpcomingItem>>.value(const <UpcomingItem>[]),
            ),
          ],
        );

        final BuildContext context = tester.element(find.text('Основной счет'));
        final AppLocalizations strings = AppLocalizations.of(context)!;
        final Color expectedMutedColor = Theme.of(
          context,
        ).colorScheme.onSurface;

        final Text accountTypeText = tester
            .widgetList<Text>(find.text(strings.addAccountTypeCash))
            .first;
        final Text incomeText = tester
            .widgetList<Text>(find.textContaining('Доход:'))
            .first;
        final Icon eyeIcon = tester.widget<Icon>(
          find.byIcon(PhosphorIcons.eyeSlash(PhosphorIconsStyle.regular)),
        );

        expect(accountTypeText.style?.color, expectedMutedColor);
        expect(incomeText.style?.color, expectedMutedColor);
        expect(eyeIcon.color, expectedMutedColor);
      },
    );
  });
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  FutureOr<AuthUser?> build() => _user;
}

class _FakeHomeDashboardPreferencesController
    extends HomeDashboardPreferencesController {
  @override
  Future<HomeDashboardPreferences> build() async {
    return const HomeDashboardPreferences();
  }
}

class _FakeOverviewPreferencesController extends OverviewPreferencesController {
  @override
  Future<OverviewPreferences> build() async {
    return const OverviewPreferences();
  }
}

AccountEntity _account(String id) {
  final DateTime now = DateTime.now();
  return AccountEntity(
    id: id,
    name: 'Account $id',
    balanceMinor: BigInt.zero,
    currency: 'RUB',
    currencyScale: 2,
    type: 'cash',
    createdAt: now,
    updatedAt: now,
  );
}

TransactionEntity _transaction(String id) {
  final DateTime now = DateTime.now();
  return TransactionEntity(
    id: id,
    accountId: 'acc',
    categoryId: 'cat',
    amountMinor: BigInt.from(1000),
    amountScale: 2,
    date: now,
    note: null,
    type: 'expense',
    createdAt: now,
    updatedAt: now,
  );
}

class _InMemoryAccountRepository implements AccountRepository {
  _InMemoryAccountRepository(this._stream);

  final Stream<List<AccountEntity>> _stream;

  @override
  Future<AccountEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<AccountEntity>> loadAccounts() {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(AccountEntity account) {
    throw UnimplementedError();
  }

  @override
  Stream<List<AccountEntity>> watchAccounts() => _stream;
}

class _InMemoryTransactionRepository implements TransactionRepository {
  _InMemoryTransactionRepository(this._stream);

  final Stream<List<TransactionEntity>> _stream;

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    return _stream.map((List<TransactionEntity> items) {
      final Map<String, ({MoneyAccumulator income, MoneyAccumulator expense})>
      acc = <String, ({MoneyAccumulator income, MoneyAccumulator expense})>{};
      for (final TransactionEntity transaction in items) {
        if (transaction.date.isBefore(start) ||
            !transaction.date.isBefore(end)) {
          continue;
        }
        final ({MoneyAccumulator income, MoneyAccumulator expense}) current =
            acc[transaction.accountId] ??
            (income: MoneyAccumulator(), expense: MoneyAccumulator());
        if (transaction.type == TransactionType.income.storageValue) {
          acc[transaction.accountId] = (
            income: current.income..add(transaction.amountValue.abs()),
            expense: current.expense,
          );
        } else if (transaction.type == TransactionType.expense.storageValue) {
          acc[transaction.accountId] = (
            income: current.income,
            expense: current.expense..add(transaction.amountValue.abs()),
          );
        }
      }
      return acc.entries
          .map(
            (
              MapEntry<
                String,
                ({MoneyAccumulator income, MoneyAccumulator expense})
              >
              entry,
            ) => AccountMonthlyTotals(
              accountId: entry.key,
              income: MoneyAmount(
                minor: entry.value.income.minor,
                scale: entry.value.income.scale,
              ),
              expense: MoneyAmount(
                minor: entry.value.expense.minor,
                scale: entry.value.expense.scale,
              ),
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Future<TransactionEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionEntity>> findByGroupId(String groupId) async {
    return const <TransactionEntity>[];
  }

  @override
  Future<TransactionEntity?> findByIdempotencyKey(String idempotencyKey) {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findLatestByCategoryId(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionEntity>> loadTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(TransactionEntity transaction) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) {
    return _stream.map((List<TransactionEntity> items) {
      if (limit == null || limit >= items.length) {
        return items;
      }
      return items.take(limit).toList(growable: false);
    });
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() => _stream;

  @override
  Stream<List<TransactionCategoryTotals>> watchAnalyticsCategoryTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
    String? accountId,
  }) => const Stream<List<TransactionCategoryTotals>>.empty();

  @override
  Stream<List<MonthlyCashflowTotals>> watchMonthlyCashflowTotals({
    required DateTime start,
    required DateTime end,
    required DateTime nowInclusive,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<MonthlyCashflowTotals>>.empty();

  @override
  Stream<List<MonthlyBalanceTotals>> watchMonthlyBalanceTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<MonthlyBalanceTotals>>.empty();

  @override
  Stream<List<BudgetExpenseTotals>> watchBudgetExpenseTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<BudgetExpenseTotals>>.empty();

  @override
  Stream<List<TransactionEntity>> watchCategoryTransactions({
    required DateTime start,
    required DateTime end,
    required List<String> categoryIds,
    required bool includeUncategorized,
    required String type,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<TransactionEntity>>.empty();

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) => action();
}

class _RecordingWatchRecentTransactionsUseCase
    extends WatchRecentTransactionsUseCase {
  _RecordingWatchRecentTransactionsUseCase(this._stream)
    : lastLimit = null,
      super(_DummyTransactionRepository());

  final Stream<List<TransactionEntity>> _stream;
  int? lastLimit;

  @override
  Stream<List<TransactionEntity>> call({
    int limit = kDefaultRecentTransactionsLimit,
  }) {
    lastLimit = limit;
    return _stream;
  }
}

class _DummyTransactionRepository implements TransactionRepository {
  @override
  Future<TransactionEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionEntity>> findByGroupId(String groupId) async {
    return const <TransactionEntity>[];
  }

  @override
  Future<TransactionEntity?> findByIdempotencyKey(String idempotencyKey) {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findLatestByCategoryId(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionEntity>> loadTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(TransactionEntity transaction) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionCategoryTotals>> watchAnalyticsCategoryTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
    String? accountId,
  }) => const Stream<List<TransactionCategoryTotals>>.empty();

  @override
  Stream<List<MonthlyCashflowTotals>> watchMonthlyCashflowTotals({
    required DateTime start,
    required DateTime end,
    required DateTime nowInclusive,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<MonthlyCashflowTotals>>.empty();

  @override
  Stream<List<MonthlyBalanceTotals>> watchMonthlyBalanceTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<MonthlyBalanceTotals>>.empty();

  @override
  Stream<List<BudgetExpenseTotals>> watchBudgetExpenseTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<BudgetExpenseTotals>>.empty();

  @override
  Stream<List<TransactionEntity>> watchCategoryTransactions({
    required DateTime start,
    required DateTime end,
    required List<String> categoryIds,
    required bool includeUncategorized,
    required String type,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<TransactionEntity>>.empty();

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) => action();
}

class _StubWatchCreditsUseCase extends WatchCreditsUseCase {
  _StubWatchCreditsUseCase(this._stream) : super(_DummyCreditRepository());

  final Stream<List<CreditEntity>> _stream;

  @override
  Stream<List<CreditEntity>> call() => _stream;
}

class _StubWatchCreditCardsUseCase extends WatchCreditCardsUseCase {
  _StubWatchCreditCardsUseCase(this._stream)
    : super(_DummyCreditCardRepository());

  final Stream<List<CreditCardEntity>> _stream;

  @override
  Stream<List<CreditCardEntity>> call() => _stream;
}

class _DummyCreditRepository implements CreditRepository {
  @override
  Future<void> addCredit(CreditEntity credit) {
    throw UnimplementedError();
  }

  @override
  Future<void> addPaymentGroup(CreditPaymentGroupEntity group) {
    throw UnimplementedError();
  }

  @override
  Future<bool> addPaymentGroupIfAbsent(CreditPaymentGroupEntity group) {
    throw UnimplementedError();
  }

  @override
  Future<void> addSchedule(List<CreditPaymentScheduleEntity> schedule) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCredit(String id) {
    throw UnimplementedError();
  }

  @override
  Future<CreditEntity?> getCreditByAccountId(String accountId) {
    throw UnimplementedError();
  }

  @override
  Future<CreditEntity?> getCreditByCategoryId(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<List<CreditEntity>> getCredits() {
    throw UnimplementedError();
  }

  @override
  Future<List<CreditPaymentGroupEntity>> getPaymentGroups(String creditId) {
    throw UnimplementedError();
  }

  @override
  Future<CreditPaymentGroupEntity?> findPaymentGroupById(String groupId) async {
    return null;
  }

  @override
  Future<CreditPaymentGroupEntity?> findPaymentGroupByIdempotencyKey({
    required String creditId,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<CreditPaymentScheduleEntity>> getSchedule(String creditId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCredit(CreditEntity credit) {
    throw UnimplementedError();
  }

  @override
  Future<void> updatePaymentGroup(CreditPaymentGroupEntity group) async {}

  @override
  Future<void> updateScheduleItem(CreditPaymentScheduleEntity item) {
    throw UnimplementedError();
  }

  @override
  Stream<List<CreditEntity>> watchCredits() =>
      const Stream<List<CreditEntity>>.empty();

  @override
  Stream<List<CreditPaymentScheduleEntity>> watchSchedule(String creditId) =>
      const Stream<List<CreditPaymentScheduleEntity>>.empty();
}

class _DummyCreditCardRepository implements CreditCardRepository {
  @override
  Future<void> addCreditCard(CreditCardEntity creditCard) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCreditCard(String id) {
    throw UnimplementedError();
  }

  @override
  Future<CreditCardEntity?> getByAccountId(String accountId) {
    throw UnimplementedError();
  }

  @override
  Future<List<CreditCardEntity>> getCreditCards() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCreditCard(CreditCardEntity creditCard) {
    throw UnimplementedError();
  }

  @override
  Stream<List<CreditCardEntity>> watchCreditCards() =>
      const Stream<List<CreditCardEntity>>.empty();
}
