import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/use_cases/watch_accounts_use_case.dart';
import 'package:kopim/features/analytics/domain/use_cases/watch_monthly_analytics_use_case.dart';
import 'package:kopim/features/app_shell/presentation/widgets/main_navigation_shell.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/use_cases/watch_categories_use_case.dart';
import 'package:kopim/features/categories/domain/use_cases/watch_category_tree_use_case.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_recent_transactions_use_case.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:riverpod/src/framework.dart';

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  FutureOr<AuthUser?> build() => _user;
}

class _StreamAccountRepository implements AccountRepository {
  _StreamAccountRepository(this._stream);

  final Stream<List<AccountEntity>> _stream;

  @override
  Stream<List<AccountEntity>> watchAccounts() => _stream;

  @override
  Future<AccountEntity?> findById(String id) => throw UnimplementedError();

  @override
  Future<List<AccountEntity>> loadAccounts() => throw UnimplementedError();

  @override
  Future<void> softDelete(String id) => throw UnimplementedError();

  @override
  Future<void> upsert(AccountEntity account) => throw UnimplementedError();
}

class _StreamTransactionRepository implements TransactionRepository {
  _StreamTransactionRepository(this._stream);

  final Stream<List<TransactionEntity>> _stream;

  @override
  Stream<List<TransactionEntity>> watchTransactions() => _stream;

  @override
  Future<TransactionEntity?> findById(String id) => throw UnimplementedError();

  @override
  Future<List<TransactionEntity>> loadTransactions() =>
      throw UnimplementedError();

  @override
  Future<void> softDelete(String id) => throw UnimplementedError();

  @override
  Future<void> upsert(TransactionEntity transaction) =>
      throw UnimplementedError();
}

class _StreamCategoryRepository implements CategoryRepository {
  _StreamCategoryRepository(this._stream);

  final Stream<List<Category>> _stream;

  @override
  Stream<List<Category>> watchCategories() => _stream;

  @override
  Stream<List<CategoryTreeNode>> watchCategoryTree() =>
      Stream<List<CategoryTreeNode>>.value(const <CategoryTreeNode>[]);

  @override
  Future<Category?> findById(String id) => throw UnimplementedError();

  @override
  Future<List<Category>> loadCategories() => throw UnimplementedError();

  @override
  Future<List<CategoryTreeNode>> loadCategoryTree() =>
      throw UnimplementedError();

  @override
  Future<void> softDelete(String id) => throw UnimplementedError();

  @override
  Future<void> upsert(Category category) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final DateTime now = DateTime.utc(2024, 1, 1);
  final AccountEntity account = AccountEntity(
    id: 'acc-1',
    name: 'Wallet',
    balance: 1200,
    currency: 'USD',
    type: 'cash',
    createdAt: now,
    updatedAt: now,
  );

  const AuthUser? anonymousUser = null;

  ProviderScope buildShell(Widget child) {
    final _StreamTransactionRepository transactionRepository =
        _StreamTransactionRepository(
          Stream<List<TransactionEntity>>.value(const <TransactionEntity>[]),
        );

    return ProviderScope(
      overrides: <Override>[
        authControllerProvider.overrideWith(
          () => _FakeAuthController(anonymousUser),
        ),
        watchAccountsUseCaseProvider.overrideWithValue(
          WatchAccountsUseCase(
            _StreamAccountRepository(Stream.value(<AccountEntity>[account])),
          ),
        ),
        transactionRepositoryProvider.overrideWithValue(transactionRepository),
        watchRecentTransactionsUseCaseProvider.overrideWithValue(
          WatchRecentTransactionsUseCase(transactionRepository),
        ),
        watchMonthlyAnalyticsUseCaseProvider.overrideWithValue(
          WatchMonthlyAnalyticsUseCase(
            transactionRepository: transactionRepository,
          ),
        ),
        watchCategoriesUseCaseProvider.overrideWithValue(
          WatchCategoriesUseCase(
            _StreamCategoryRepository(
              Stream<List<Category>>.value(const <Category>[]),
            ),
          ),
        ),
        watchCategoryTreeUseCaseProvider.overrideWithValue(
          WatchCategoryTreeUseCase(
            _StreamCategoryRepository(
              Stream<List<Category>>.value(const <Category>[]),
            ),
          ),
        ),
        manageCategoryTreeProvider.overrideWith(
          (Ref ref) =>
              Stream<List<CategoryTreeNode>>.value(const <CategoryTreeNode>[]),
        ),
      ],
      child: child,
    );
  }

  testWidgets('displays bottom navigation bar on every primary tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildShell(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainNavigationShell(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Finder bottomNavFinder = find.byType(BottomNavigationBar);
    expect(bottomNavFinder, findsOneWidget);

    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(bottomNavFinder, findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(bottomNavFinder, findsOneWidget);
  });

  testWidgets('hides bottom navigation when a secondary route is pushed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildShell(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainNavigationShell(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final NavigatorState navigator =
        tester.state(find.byType(Navigator)) as NavigatorState;

    navigator.push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            const Scaffold(body: Center(child: Text('Child screen'))),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsNothing);

    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
