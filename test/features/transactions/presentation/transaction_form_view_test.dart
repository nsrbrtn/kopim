import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

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

Category _buildCategory({
  required String id,
  required String name,
  bool isFavorite = false,
}) {
  return Category(
    id: id,
    name: name,
    type: 'expense',
    color: '#FF5722',
    icon: null,
    parentId: null,
    isFavorite: isFavorite,
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
  );
}
