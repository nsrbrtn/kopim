import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/domain/use_cases/get_account_by_id_use_case.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/tags/domain/repositories/transaction_tags_repository.dart';
import 'package:kopim/features/tags/domain/use_cases/get_transaction_tag_ids_use_case.dart';
import 'package:kopim/features/tags/domain/use_cases/set_transaction_tags_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _StubGetAccountByIdUseCase extends GetAccountByIdUseCase {
  _StubGetAccountByIdUseCase(this._accounts)
    : super(_NeverUsedAccountRepository());

  final Map<String, AccountEntity> _accounts;

  @override
  Future<AccountEntity?> call(String id) async => _accounts[id];
}

class _NeverUsedAccountRepository implements AccountRepository {
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
  Stream<List<AccountEntity>> watchAccounts() {
    throw UnimplementedError();
  }
}

class _NeverUsedTransactionTagsRepository implements TransactionTagsRepository {
  @override
  Future<List<TransactionTagEntity>> loadAllTransactionTags() async {
    throw UnimplementedError();
  }

  @override
  Future<List<TagEntity>> loadTagsForTransaction(String transactionId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getTagIdsForTransaction(String transactionId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> upsertAll(List<TransactionTagEntity> links) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setTransactionTags(
    String transactionId,
    List<String> tagIds,
  ) async {
    throw UnimplementedError();
  }

  @override
  Stream<List<TagEntity>> watchTagsForTransaction(String transactionId) {
    throw UnimplementedError();
  }
}

class _StubGetTransactionTagIdsUseCase extends GetTransactionTagIdsUseCase {
  _StubGetTransactionTagIdsUseCase()
    : super(_NeverUsedTransactionTagsRepository());

  @override
  Future<List<String>> call(String transactionId) async => const <String>[];
}

class _StubSetTransactionTagsUseCase extends SetTransactionTagsUseCase {
  _StubSetTransactionTagsUseCase()
    : super(_NeverUsedTransactionTagsRepository());

  @override
  Future<void> call({
    required String transactionId,
    required List<String> tagIds,
  }) async {}
}

class _StubProfileEventRecorder extends ProfileEventRecorder {
  _StubProfileEventRecorder()
    : super(
        analyticsService: const AnalyticsService(),
        loggerService: LoggerService(),
      );

  @override
  Future<void> record(Iterable<ProfileDomainEvent> events) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('amount field uses filled decoration', (
    WidgetTester tester,
  ) async {
    final AccountEntity account = AccountEntity(
      id: 'acc-1',
      name: 'Cash',
      balanceMinor: BigInt.from(120000),
      currency: 'USD',
      currencyScale: 2,
      type: 'wallet',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
      isDeleted: false,
    );
    final Category category = Category(
      id: 'groceries',
      name: 'Groceries',
      type: 'expense',
      color: '#FF5722',
      icon: null,
      parentId: null,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          transactionFormAccountsProvider.overrideWith(
            (Ref ref) =>
                Stream<List<AccountEntity>>.value(<AccountEntity>[account]),
          ),
          transactionFormCategoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(<Category>[category]),
          ),
          transactionFormTagsProvider.overrideWith(
            (Ref ref) => const Stream<List<TagEntity>>.empty(),
          ),
          getAccountByIdUseCaseProvider.overrideWithValue(
            _StubGetAccountByIdUseCase(<String, AccountEntity>{
              account.id: account,
            }),
          ),
          getTransactionTagIdsUseCaseProvider.overrideWithValue(
            _StubGetTransactionTagIdsUseCase(),
          ),
          setTransactionTagsUseCaseProvider.overrideWithValue(
            _StubSetTransactionTagsUseCase(),
          ),
          profileEventRecorderProvider.overrideWithValue(
            _StubProfileEventRecorder(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AddTransactionScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    final BuildContext context = tester.element(find.byType(Scaffold));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    final InputDecorator decorator = tester.widget<InputDecorator>(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is InputDecorator &&
            widget.decoration.hintText == strings.addTransactionAmountHint,
      ),
    );
    final InputDecoration decoration = decorator.decoration;

    expect(decoration.filled, isTrue);
    expect(decoration.fillColor, isNotNull);
    final OutlineInputBorder border = decoration.border! as OutlineInputBorder;
    expect(border.borderSide.style, BorderStyle.none);
  });

  testWidgets('transfer target list hides accounts with another currency', (
    WidgetTester tester,
  ) async {
    final AccountEntity usdAccount = AccountEntity(
      id: 'acc-usd',
      name: 'USD Cash',
      balanceMinor: BigInt.from(120000),
      currency: 'USD',
      currencyScale: 2,
      type: 'wallet',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
      isDeleted: false,
    );
    final AccountEntity secondUsdAccount = AccountEntity(
      id: 'acc-usd-2',
      name: 'USD Card',
      balanceMinor: BigInt.from(50000),
      currency: 'USD',
      currencyScale: 2,
      type: 'card',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
      isDeleted: false,
    );
    final AccountEntity eurAccount = AccountEntity(
      id: 'acc-eur',
      name: 'EUR Wallet',
      balanceMinor: BigInt.from(70000),
      currency: 'EUR',
      currencyScale: 2,
      type: 'wallet',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
      isDeleted: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          transactionFormAccountsProvider.overrideWith(
            (Ref ref) => Stream<List<AccountEntity>>.value(<AccountEntity>[
              usdAccount,
              secondUsdAccount,
              eurAccount,
            ]),
          ),
          transactionFormCategoriesProvider.overrideWith(
            (Ref ref) => const Stream<List<Category>>.empty(),
          ),
          transactionFormTagsProvider.overrideWith(
            (Ref ref) => const Stream<List<TagEntity>>.empty(),
          ),
          getAccountByIdUseCaseProvider.overrideWithValue(
            _StubGetAccountByIdUseCase(<String, AccountEntity>{
              usdAccount.id: usdAccount,
              secondUsdAccount.id: secondUsdAccount,
              eurAccount.id: eurAccount,
            }),
          ),
          getTransactionTagIdsUseCaseProvider.overrideWithValue(
            _StubGetTransactionTagIdsUseCase(),
          ),
          setTransactionTagsUseCaseProvider.overrideWithValue(
            _StubSetTransactionTagsUseCase(),
          ),
          profileEventRecorderProvider.overrideWithValue(
            _StubProfileEventRecorder(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AddTransactionScreen(
            formArgs: TransactionFormArgs(
              defaultAccountId: 'acc-usd',
              initialType: TransactionType.transfer,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final BuildContext context = tester.element(find.byType(Scaffold));
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final Element labelElement = tester.element(
      find.text(strings.addTransactionTransferTargetLabel),
    );
    Element? transferSectionElement;
    labelElement.visitAncestorElements((Element ancestor) {
      if (ancestor.widget is Container) {
        transferSectionElement = ancestor;
        return false;
      }
      return true;
    });

    expect(transferSectionElement, isNotNull);

    final List<String> texts = <String>[];
    void collectTexts(Element element) {
      final Widget widget = element.widget;
      if (widget is Text && widget.data != null) {
        texts.add(widget.data!);
      }
      element.visitChildElements(collectTexts);
    }

    collectTexts(transferSectionElement!);

    expect(texts.where((String text) => text == 'USD Card'), isNotEmpty);
    expect(texts.where((String text) => text == 'EUR Wallet'), isEmpty);
  });

  testWidgets(
    'в редактировании перевода счет поступления показывается первым',
    (WidgetTester tester) async {
      final AccountEntity sourceAccount = AccountEntity(
        id: 'acc-usd',
        name: 'USD Cash',
        balanceMinor: BigInt.from(120000),
        currency: 'USD',
        currencyScale: 2,
        type: 'wallet',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        isDeleted: false,
      );
      final AccountEntity firstTarget = AccountEntity(
        id: 'acc-usd-2',
        name: 'USD Card',
        balanceMinor: BigInt.from(50000),
        currency: 'USD',
        currencyScale: 2,
        type: 'card',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        isDeleted: false,
      );
      final AccountEntity selectedTarget = AccountEntity(
        id: 'acc-usd-3',
        name: 'USD Savings',
        balanceMinor: BigInt.from(90000),
        currency: 'USD',
        currencyScale: 2,
        type: 'bank',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        isDeleted: false,
      );
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-transfer',
        accountId: sourceAccount.id,
        transferAccountId: selectedTarget.id,
        amountMinor: BigInt.from(10000),
        amountScale: 2,
        date: DateTime(2023, 1, 2),
        type: TransactionType.transfer.storageValue,
        createdAt: DateTime(2023, 1, 2),
        updatedAt: DateTime(2023, 1, 2),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            transactionFormAccountsProvider.overrideWith(
              (Ref ref) => Stream<List<AccountEntity>>.value(<AccountEntity>[
                sourceAccount,
                firstTarget,
                selectedTarget,
              ]),
            ),
            transactionFormCategoriesProvider.overrideWith(
              (Ref ref) => const Stream<List<Category>>.empty(),
            ),
            transactionFormTagsProvider.overrideWith(
              (Ref ref) => const Stream<List<TagEntity>>.empty(),
            ),
            getAccountByIdUseCaseProvider.overrideWithValue(
              _StubGetAccountByIdUseCase(<String, AccountEntity>{
                sourceAccount.id: sourceAccount,
                firstTarget.id: firstTarget,
                selectedTarget.id: selectedTarget,
              }),
            ),
            getTransactionTagIdsUseCaseProvider.overrideWithValue(
              _StubGetTransactionTagIdsUseCase(),
            ),
            setTransactionTagsUseCaseProvider.overrideWithValue(
              _StubSetTransactionTagsUseCase(),
            ),
            profileEventRecorderProvider.overrideWithValue(
              _StubProfileEventRecorder(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AddTransactionScreen(
              formArgs: TransactionFormArgs(initialTransaction: transaction),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final BuildContext context = tester.element(find.byType(Scaffold));
      final AppLocalizations strings = AppLocalizations.of(context)!;
      final Element transferSection = _findTransferSectionElement(
        tester,
        strings,
      )!;
      final List<String> texts = _collectTextValues(transferSection);
      final int selectedIndex = texts.indexOf('USD Savings');
      final int firstTargetIndex = texts.indexOf('USD Card');

      expect(selectedIndex, isNonNegative);
      expect(firstTargetIndex, isNonNegative);
      expect(selectedIndex, lessThan(firstTargetIndex));
    },
  );

  testWidgets(
    'по умолчанию форма показывает избранные и только пять обычных категорий',
    (WidgetTester tester) async {
      final AccountEntity account = _buildAccount();
      final List<Category> categories = <Category>[
        _buildCategory(id: 'fav-food', name: 'Еда', isFavorite: true),
        _buildCategory(id: 'fav-home', name: 'Дом', isFavorite: true),
        _buildCategory(id: 'regular-1', name: 'Категория 1'),
        _buildCategory(id: 'regular-2', name: 'Категория 2'),
        _buildCategory(id: 'regular-3', name: 'Категория 3'),
        _buildCategory(id: 'regular-4', name: 'Категория 4'),
        _buildCategory(id: 'regular-5', name: 'Категория 5'),
        _buildCategory(id: 'regular-6', name: 'Категория 6'),
        _buildCategory(id: 'regular-7', name: 'Категория 7'),
      ];

      await _pumpTransactionForm(
        tester,
        account: account,
        categories: categories,
      );

      expect(find.text('Еда'), findsOneWidget);
      expect(find.text('Дом'), findsOneWidget);
      expect(find.text('Категория 1'), findsOneWidget);
      expect(find.text('Категория 2'), findsOneWidget);
      expect(find.text('Категория 3'), findsOneWidget);
      expect(find.text('Категория 4'), findsOneWidget);
      expect(find.text('Категория 5'), findsOneWidget);
      expect(find.text('Категория 6'), findsNothing);
      expect(find.text('Категория 7'), findsNothing);
    },
  );

  testWidgets(
    'при редактировании выбранная категория остается видимой вместе с превью',
    (WidgetTester tester) async {
      final AccountEntity account = _buildAccount();
      final List<Category> categories = <Category>[
        _buildCategory(id: 'fav-food', name: 'Еда', isFavorite: true),
        _buildCategory(id: 'regular-1', name: 'Категория 1'),
        _buildCategory(id: 'regular-2', name: 'Категория 2'),
        _buildCategory(id: 'regular-3', name: 'Категория 3'),
        _buildCategory(id: 'regular-4', name: 'Категория 4'),
        _buildCategory(id: 'regular-5', name: 'Категория 5'),
        _buildCategory(id: 'regular-6', name: 'Категория 6'),
        _buildCategory(id: 'regular-7', name: 'Категория 7'),
      ];
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-1',
        accountId: account.id,
        categoryId: 'regular-7',
        amountMinor: BigInt.from(1550),
        amountScale: 2,
        date: DateTime(2023, 1, 2),
        note: 'coffee',
        type: TransactionType.expense.storageValue,
        createdAt: DateTime(2023, 1, 2),
        updatedAt: DateTime(2023, 1, 2),
      );

      await _pumpTransactionForm(
        tester,
        account: account,
        categories: categories,
        formArgs: TransactionFormArgs(initialTransaction: transaction),
      );

      expect(find.text('Еда'), findsOneWidget);
      expect(find.text('Категория 1'), findsOneWidget);
      expect(find.text('Категория 2'), findsOneWidget);
      expect(find.text('Категория 3'), findsOneWidget);
      expect(find.text('Категория 4'), findsOneWidget);
      expect(find.text('Категория 5'), findsOneWidget);
      expect(find.text('Категория 7'), findsOneWidget);
      expect(find.text('Категория 6'), findsNothing);
    },
  );

  testWidgets('при выборе подкатегории чип не дублируется', (
    WidgetTester tester,
  ) async {
    final AccountEntity account = _buildAccount();
    final List<Category> categories = <Category>[
      _buildCategory(id: 'food', name: 'Еда'),
      _buildCategory(id: 'coffee', name: 'Кофе', parentId: 'food'),
    ];

    await _pumpTransactionForm(
      tester,
      account: account,
      categories: categories,
    );

    await tester.tap(find.text('Еда'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Кофе'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Кофе'), findsOneWidget);
  });

  testWidgets(
    'при поиске родительской категории её можно раскрыть и показать подкатегории, даже если они не подходят по названию',
    (WidgetTester tester) async {
      final AccountEntity account = _buildAccount();
      final List<Category> categories = <Category>[
        _buildCategory(id: 'food', name: 'Еда'),
        _buildCategory(id: 'coffee', name: 'Кофе', parentId: 'food'),
      ];

      await _pumpTransactionForm(
        tester,
        account: account,
        categories: categories,
      );

      final BuildContext context = tester.element(find.byType(Scaffold));
      final AppLocalizations strings = AppLocalizations.of(context)!;

      final Finder searchField = find.byWidgetPredicate(
        (Widget widget) =>
            widget is TextField &&
            widget.decoration?.hintText ==
                strings.addTransactionCategorySearchHint,
      );

      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Ед');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Еда'), findsOneWidget);
      expect(find.text('Кофе'), findsNothing);

      await tester.tap(find.text('Еда'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Кофе'), findsOneWidget);

      await tester.tap(find.text('Кофе'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Кофе'), findsOneWidget);
    },
  );

  testWidgets('carousel interaction keeps section expanded', (
    WidgetTester tester,
  ) async {
    final AccountEntity account = _buildAccount();
    final List<Category> categories = <Category>[
      _buildCategory(id: 'cat-1', name: 'Food'),
    ];

    await _pumpTransactionForm(
      tester,
      account: account,
      categories: categories,
    );

    final BuildContext context = tester.element(find.byType(Scaffold));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    final Finder amountFinder = find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField &&
          widget.decoration?.hintText == strings.addTransactionAmountHint,
    );
    expect(amountFinder, findsOneWidget);

    await tester.tap(amountFinder);
    await tester.enterText(amountFinder, '100');
    await tester.pump();

    final FocusNode focusNode = tester
        .widget<TextField>(amountFinder)
        .focusNode!;
    expect(focusNode.hasFocus, isTrue);

    final Finder carousel = find.byKey(
      const ValueKey<String>('transaction_account_field'),
    );
    expect(carousel, findsOneWidget);

    await tester.drag(carousel, const Offset(-50, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(focusNode.hasFocus, isTrue);
    expect(
      find.byKey(const ValueKey<String>('transaction_account_field')),
      findsOneWidget,
    );
  });

  testWidgets(
    'amount entered + immediate account selection before debounce => latest amount preserved',
    (WidgetTester tester) async {
      final AccountEntity account1 = _buildAccount();
      final AccountEntity account2 = AccountEntity(
        id: 'acc-2',
        name: 'Card',
        balanceMinor: BigInt.from(50000),
        currency: 'USD',
        currencyScale: 2,
        type: 'card',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        isDeleted: false,
      );
      final List<Category> categories = <Category>[
        _buildCategory(id: 'cat-1', name: 'Food'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            transactionFormAccountsProvider.overrideWith(
              (Ref ref) => Stream<List<AccountEntity>>.value(<AccountEntity>[
                account1,
                account2,
              ]),
            ),
            transactionFormCategoriesProvider.overrideWith(
              (Ref ref) => Stream<List<Category>>.value(categories),
            ),
            transactionFormTagsProvider.overrideWith(
              (Ref ref) => const Stream<List<TagEntity>>.empty(),
            ),
            getAccountByIdUseCaseProvider.overrideWithValue(
              _StubGetAccountByIdUseCase(<String, AccountEntity>{
                account1.id: account1,
                account2.id: account2,
              }),
            ),
            getTransactionTagIdsUseCaseProvider.overrideWithValue(
              _StubGetTransactionTagIdsUseCase(),
            ),
            setTransactionTagsUseCaseProvider.overrideWithValue(
              _StubSetTransactionTagsUseCase(),
            ),
            profileEventRecorderProvider.overrideWithValue(
              _StubProfileEventRecorder(),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AddTransactionScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final BuildContext context = tester.element(find.byType(Scaffold));
      final AppLocalizations strings = AppLocalizations.of(context)!;

      final Finder amountFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is TextField &&
            widget.decoration?.hintText == strings.addTransactionAmountHint,
      );

      await tester.tap(amountFinder);
      await tester.enterText(amountFinder, '123.45');
      await tester.pump();

      await tester.tap(find.text('Card'));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 300));

      final StateNotifierProvider<
        TransactionFormController,
        TransactionDraftState
      >
      formProvider = transactionFormControllerProvider(
        const TransactionFormArgs(),
      );
      final ProviderContainer container = ProviderScope.containerOf(context);
      final TransactionDraftState state = container.read(formProvider);

      expect(state.accountId, equals('acc-2'));
      expect(state.amount, equals('123.45'));
    },
  );

  testWidgets('amount entered + tap note collapses section', (
    WidgetTester tester,
  ) async {
    final AccountEntity account = _buildAccount();
    final List<Category> categories = <Category>[
      _buildCategory(id: 'cat-1', name: 'Food'),
    ];

    await _pumpTransactionForm(
      tester,
      account: account,
      categories: categories,
    );

    final BuildContext context = tester.element(find.byType(Scaffold));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    final Finder amountFinder = find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField &&
          widget.decoration?.hintText == strings.addTransactionAmountHint,
    );

    await tester.tap(amountFinder);
    await tester.enterText(amountFinder, '100');
    await tester.pump();

    final AnimatedCrossFade crossFadeBefore = tester.widget<AnimatedCrossFade>(
      find.byType(AnimatedCrossFade),
    );
    expect(crossFadeBefore.crossFadeState, equals(CrossFadeState.showFirst));

    final Finder noteFinder = find.byType(TextFormField).last;
    expect(noteFinder, findsOneWidget);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final AnimatedCrossFade crossFadeAfter = tester.widget<AnimatedCrossFade>(
      find.byType(AnimatedCrossFade),
    );
    expect(crossFadeAfter.crossFadeState, equals(CrossFadeState.showSecond));
  });

  testWidgets(
    'invalid amount + account carousel interaction => no collapse or crash',
    (WidgetTester tester) async {
      final AccountEntity account = _buildAccount();
      final List<Category> categories = <Category>[
        _buildCategory(id: 'cat-1', name: 'Food'),
      ];

      await _pumpTransactionForm(
        tester,
        account: account,
        categories: categories,
      );

      final BuildContext context = tester.element(find.byType(Scaffold));
      final AppLocalizations strings = AppLocalizations.of(context)!;

      final Finder amountFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is TextField &&
            widget.decoration?.hintText == strings.addTransactionAmountHint,
      );
      await tester.tap(amountFinder);
      await tester.enterText(amountFinder, '');
      await tester.pump();

      final Finder carousel = find.byKey(
        const ValueKey<String>('transaction_account_field'),
      );
      await tester.drag(carousel, const Offset(-50, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const ValueKey<String>('transaction_account_field')),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpTransactionForm(
  WidgetTester tester, {
  required AccountEntity account,
  required List<Category> categories,
  TransactionFormArgs formArgs = const TransactionFormArgs(),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        transactionFormAccountsProvider.overrideWith(
          (Ref ref) =>
              Stream<List<AccountEntity>>.value(<AccountEntity>[account]),
        ),
        transactionFormCategoriesProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(categories),
        ),
        transactionFormTagsProvider.overrideWith(
          (Ref ref) => const Stream<List<TagEntity>>.empty(),
        ),
        getAccountByIdUseCaseProvider.overrideWithValue(
          _StubGetAccountByIdUseCase(<String, AccountEntity>{
            account.id: account,
          }),
        ),
        getTransactionTagIdsUseCaseProvider.overrideWithValue(
          _StubGetTransactionTagIdsUseCase(),
        ),
        setTransactionTagsUseCaseProvider.overrideWithValue(
          _StubSetTransactionTagsUseCase(),
        ),
        profileEventRecorderProvider.overrideWithValue(
          _StubProfileEventRecorder(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AddTransactionScreen(formArgs: formArgs),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

AccountEntity _buildAccount() {
  return AccountEntity(
    id: 'acc-1',
    name: 'Cash',
    balanceMinor: BigInt.from(120000),
    currency: 'USD',
    currencyScale: 2,
    type: 'wallet',
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
    isDeleted: false,
  );
}

Element? _findTransferSectionElement(
  WidgetTester tester,
  AppLocalizations strings,
) {
  final Element labelElement = tester.element(
    find.text(strings.addTransactionTransferTargetLabel),
  );
  Element? transferSectionElement;
  labelElement.visitAncestorElements((Element ancestor) {
    if (ancestor.widget is Container) {
      transferSectionElement = ancestor;
      return false;
    }
    return true;
  });
  return transferSectionElement;
}

List<String> _collectTextValues(Element element) {
  final List<String> texts = <String>[];

  void collectTexts(Element current) {
    final Widget widget = current.widget;
    if (widget is Text && widget.data != null) {
      texts.add(widget.data!);
    }
    current.visitChildElements(collectTexts);
  }

  collectTexts(element);
  return texts;
}

Category _buildCategory({
  required String id,
  required String name,
  bool isFavorite = false,
  String? parentId,
}) {
  return Category(
    id: id,
    name: name,
    type: 'expense',
    color: '#FF5722',
    icon: null,
    parentId: parentId,
    isFavorite: isFavorite,
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
  );
}
