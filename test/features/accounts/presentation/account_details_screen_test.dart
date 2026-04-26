import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:kopim/core/widgets/web_responsive_wrapper.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/account_details_screen.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_details_providers.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/l10n/app_localizations.dart';

void main() {
  group('resolveResponsiveMaxWidthForLocation', () {
    test('uses default width for regular routes', () {
      expect(resolveResponsiveMaxWidthForLocation('/home'), 600);
      expect(resolveResponsiveMaxWidthForLocation(null), 600);
    });

    test('uses wide width for account details route', () {
      expect(
        resolveResponsiveMaxWidthForLocation('/accounts/details?accountId=42'),
        1120,
      );
    });
  });

  group('account details responsive helpers', () {
    test('keeps compact padding on narrow widths', () {
      expect(resolveAccountDetailsHorizontalPadding(480), 16);
      expect(resolveAccountDetailsHorizontalPadding(719), 16);
    });

    test('scales padding from available container width', () {
      expect(resolveAccountDetailsHorizontalPadding(720), 57.6);
      expect(resolveAccountDetailsHorizontalPadding(1120), 88);
      expect(resolveAccountDetailsHorizontalPadding(1600), 88);
    });

    test('switches summary to compact mode only on tight widths', () {
      expect(shouldUseCompactAccountSummary(480), isTrue);
      expect(shouldUseCompactAccountSummary(520), isFalse);
      expect(shouldUseCompactAccountSummary(760), isFalse);
    });
  });

  group('AccountDetailsScreen widget', () {
    testWidgets(
      'показывает кнопку "Показать больше", если есть скрытая старая история',
      (WidgetTester tester) async {
        const String accountId = 'acc-1';
        final AccountEntity account = AccountEntity(
          id: accountId,
          name: 'Основной счет',
          balanceMinor: BigInt.from(150000),
          openingBalanceMinor: BigInt.from(150000),
          currency: 'RUB',
          currencyScale: 2,
          type: 'bank',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        final DateTimeRange periodRange = DateTimeRange(
          start: DateTime(2024, 6, 1),
          end: DateTime(2024, 6, 30),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: <Override>[
              accountDetailsProvider.overrideWith((Ref ref, String id) {
                expect(id, accountId);
                return Stream<AccountEntity?>.value(account);
              }),
              accountTransactionSummaryProvider.overrideWith((
                Ref ref,
                String id,
              ) {
                expect(id, accountId);
                return AsyncValue<AccountTransactionSummary>.data(
                  AccountTransactionSummary(
                    totalIncome: MoneyAmount(minor: BigInt.zero, scale: 2),
                    totalExpense: MoneyAmount(minor: BigInt.zero, scale: 2),
                  ),
                );
              }),
              filteredAccountTransactionsProvider.overrideWith((
                Ref ref,
                String id,
              ) {
                expect(id, accountId);
                return const AsyncValue<List<TransactionEntity>>.data(
                  <TransactionEntity>[],
                );
              }),
              accountCategoriesProvider.overrideWith(
                (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
              ),
              accountTransactionsProvider.overrideWith((Ref ref, String id) {
                expect(id, accountId);
                return Stream<List<TransactionEntity>>.value(
                  const <TransactionEntity>[],
                );
              }),
              canShowMoreAccountTransactionsProvider.overrideWith((
                Ref ref,
                String id,
              ) {
                expect(id, accountId);
                return const AsyncValue<bool>.data(true);
              }),
              accountDetailsPeriodRangeProvider.overrideWith((
                Ref ref,
                String id,
              ) {
                expect(id, accountId);
                return periodRange;
              }),
              accountTopCategoryTotalsProvider(
                accountId: accountId,
                start: periodRange.start,
                end: periodRange.end,
              ).overrideWith(
                (Ref ref) => Stream<List<TransactionCategoryTotals>>.value(
                  const <TransactionCategoryTotals>[],
                ),
              ),
            ],
            child: const MaterialApp(
              locale: Locale('ru'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: AccountDetailsScreen(accountId: accountId),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Показать больше'),
          300,
          scrollable: find.byType(Scrollable).first,
        );

        expect(find.text('Показать больше'), findsOneWidget);
      },
    );
  });
}
