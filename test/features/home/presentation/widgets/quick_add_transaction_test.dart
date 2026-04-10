import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/home/presentation/widgets/quick_add_transaction.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockAddTransactionUseCase extends Mock
    implements AddTransactionUseCase {}

class _MockProfileEventRecorder extends Mock implements ProfileEventRecorder {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      AddTransactionRequest(
        accountId: 'acc-1',
        amount: MoneyAmount(minor: BigInt.from(100), scale: 2),
        date: DateTime.utc(2024, 1, 1),
      ),
    );
  });

  testWidgets(
    'показывает плейсхолдер вместо списка, если избранных категорий нет',
    (WidgetTester tester) async {
      final AppLocalizations strings = await _pumpQuickAddCard(
        tester,
        categories: <Category>[
          _buildCategory(id: 'cat-1', name: 'Продукты'),
          _buildCategory(id: 'cat-2', name: 'Транспорт'),
        ],
      );

      expect(find.text(strings.homeQuickAddFavoritesEmpty), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    },
  );

  testWidgets('после быстрого добавления показывает snackbar на одну секунду', (
    WidgetTester tester,
  ) async {
    final _MockAccountRepository accountRepository = _MockAccountRepository();
    final _MockAddTransactionUseCase addTransactionUseCase =
        _MockAddTransactionUseCase();
    final _MockProfileEventRecorder eventRecorder = _MockProfileEventRecorder();
    final AccountEntity account = _buildAccount();
    final Category favorite = _buildCategory(
      id: 'cat-fav',
      name: 'Еда',
      isFavorite: true,
    );
    final TransactionEntity created = TransactionEntity(
      id: 'tx-1',
      accountId: account.id,
      categoryId: favorite.id,
      amountMinor: BigInt.from(1250),
      amountScale: 2,
      date: DateTime.utc(2024, 4, 10),
      type: TransactionType.expense.storageValue,
      createdAt: DateTime.utc(2024, 4, 10),
      updatedAt: DateTime.utc(2024, 4, 10),
    );

    when(
      () => accountRepository.findById(account.id),
    ).thenAnswer((_) async => account);
    when(() => addTransactionUseCase(any())).thenAnswer(
      (_) async => TransactionCommandResult<TransactionEntity>(value: created),
    );
    when(() => eventRecorder.record(any())).thenAnswer((_) async {});

    final AppLocalizations strings = await _pumpQuickAddCard(
      tester,
      categories: <Category>[favorite],
      accounts: <AccountEntity>[account],
      overrides: <Override>[
        accountRepositoryProvider.overrideWithValue(accountRepository),
        addTransactionUseCaseProvider.overrideWithValue(addTransactionUseCase),
        profileEventRecorderProvider.overrideWithValue(eventRecorder),
      ],
    );

    await tester.tap(find.byIcon(Icons.category_outlined).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '12.50');
    await tester.tap(find.text(strings.addTransactionSubmit));
    await tester.pumpAndSettle();

    final SnackBar snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, const Duration(seconds: 1));
    expect(find.text(strings.addTransactionSuccess), findsOneWidget);
  });
}

Future<AppLocalizations> _pumpQuickAddCard(
  WidgetTester tester, {
  required List<Category> categories,
  List<AccountEntity>? accounts,
  List<Override> overrides = const <Override>[],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        homeCategoriesProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(categories),
        ),
        homeAccountsProvider.overrideWith(
          (Ref ref) =>
              Stream<List<AccountEntity>>.value(accounts ?? <AccountEntity>[]),
        ),
        ...overrides,
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: QuickAddTransactionCard(
              strings: AppLocalizations.of(context)!,
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
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
