import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
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
      balance: 1200,
      currency: 'USD',
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
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AddTransactionScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byType(AddTransactionScreen),
    );
    final AppLocalizations strings = AppLocalizations.of(context)!;

    final Finder decoratorFinder = find.descendant(
      of: find.bySemanticsLabel(strings.addTransactionAmountLabel),
      matching: find.byType(InputDecorator),
    );
    final InputDecorator decorator = tester.widget<InputDecorator>(
      decoratorFinder,
    );
    final InputDecoration decoration = decorator.decoration;

    expect(decoration.filled, isTrue);
    expect(decoration.fillColor, isNotNull);
    final OutlineInputBorder border = decoration.border! as OutlineInputBorder;
    expect(border.borderSide.style, BorderStyle.none);
  });
}
