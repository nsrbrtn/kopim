import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_details_providers.dart';
import 'package:kopim/features/accounts/presentation/edit_account_screen.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountDetailsScreen extends ConsumerWidget {
  const AccountDetailsScreen({super.key, required this.accountId});

  static const String routeName = '/accounts/details';

  final String accountId;

  static Route<void> route({required String accountId}) {
    return MaterialPageRoute<void>(
      builder: (_) => AccountDetailsScreen(accountId: accountId),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<AccountEntity?> accountAsync = ref.watch(
      accountDetailsProvider(accountId),
    );
    final AsyncValue<AccountTransactionSummary> summaryAsync = ref.watch(
      accountTransactionSummaryProvider(accountId),
    );
    final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
      filteredAccountTransactionsProvider(accountId),
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      accountCategoriesProvider,
    );
    return Scaffold(
      appBar: AppBar(
        title: accountAsync.maybeWhen(
          data: (AccountEntity? account) =>
              Text(account?.name ?? strings.accountDetailsTitle),
          orElse: () => Text(strings.accountDetailsTitle),
        ),
        actions: <Widget>[
          accountAsync.maybeWhen(
            data: (AccountEntity? account) => IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: strings.accountDetailsEditTooltip,
              onPressed: account == null
                  ? null
                  : () => _openEditScreen(context, account),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: accountAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => _ErrorMessage(
            message: strings.accountDetailsError(error.toString()),
          ),
          data: (AccountEntity? account) {
            if (account == null) {
              return _ErrorMessage(message: strings.accountDetailsMissing);
            }

            final NumberFormat currencyFormat = NumberFormat.currency(
              locale: strings.localeName,
              symbol: account.currency.toUpperCase(),
            );
            final bool isWideLayout = MediaQuery.of(context).size.width >= 720;
            final EdgeInsets padding = EdgeInsets.symmetric(
              horizontal: isWideLayout
                  ? MediaQuery.of(context).size.width * 0.15
                  : 16,
              vertical: 16,
            );

            final Map<String, Category> categoriesById = <String, Category>{
              for (final Category category
                  in categoriesAsync.asData?.value ?? const <Category>[])
                category.id: category,
            };

            final Widget summarySection = summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => _ErrorMessage(
                message: strings.accountDetailsSummaryError(error.toString()),
              ),
              data: (AccountTransactionSummary summary) => _AccountSummaryCard(
                account: account,
                summary: summary,
                currencyFormat: currencyFormat,
                strings: strings,
              ),
            );

            final Widget transactionsSection = transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => _ErrorMessage(
                message: strings.accountDetailsTransactionsError(
                  error.toString(),
                ),
              ),
              data: (List<TransactionEntity> transactions) {
                if (transactions.isEmpty) {
                  return _EmptyMessage(
                    message: strings.accountDetailsTransactionsEmpty,
                  );
                }

                return Column(
                  children: List<Widget>.generate(transactions.length, (
                    int index,
                  ) {
                    final TransactionEntity transaction = transactions[index];
                    return _TransactionTile(
                      transaction: transaction,
                      account: account,
                      currencyFormat: currencyFormat,
                      strings: strings,
                      category: transaction.categoryId == null
                          ? null
                          : categoriesById[transaction.categoryId!],
                    );
                  }),
                );
              },
            );

            return ListView(
              padding: padding,
              children: <Widget>[
                summarySection,
                const SizedBox(height: 24),
                transactionsSection,
              ],
            );
          },
        ),
      ),
    );
  }

  void _openEditScreen(BuildContext context, AccountEntity account) {
    Navigator.of(context).pushNamed(
      EditAccountScreen.routeName,
      arguments: EditAccountScreenArgs(account: account),
    );
  }
}

class AccountDetailsScreenArgs {
  const AccountDetailsScreenArgs({required this.accountId});

  final String accountId;
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({
    required this.account,
    required this.summary,
    required this.currencyFormat,
    required this.strings,
  });

  final AccountEntity account;
  final AccountTransactionSummary summary;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(account.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              strings.accountDetailsBalanceLabel(
                currencyFormat.format(account.balance),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryValue(
                    label: strings.accountDetailsIncomeLabel,
                    value: currencyFormat.format(summary.totalIncome),
                    valueColor: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryValue(
                    label: strings.accountDetailsExpenseLabel,
                    value: currencyFormat.format(summary.totalExpense),
                    valueColor: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.account,
    required this.currencyFormat,
    required this.strings,
    this.category,
  });

  final TransactionEntity transaction;
  final AccountEntity account;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isIncome =
        transaction.type == TransactionType.income.storageValue;
    final Color amountColor = isIncome
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final String amountText = currencyFormat.format(transaction.amount.abs());
    final PhosphorIconData? categoryIcon = resolvePhosphorIconData(
      category?.icon,
    );
    final Color? categoryColor = parseHexColor(category?.color);
    final Color avatarIconColor = categoryColor != null
        ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : theme.colorScheme.onSurfaceVariant;
    final DateFormat dateFormat = DateFormat.yMMMd(strings.localeName);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundColor:
                  categoryColor ?? theme.colorScheme.surfaceContainerHighest,
              foregroundColor: avatarIconColor,
              child: categoryIcon != null
                  ? Icon(categoryIcon)
                  : const Icon(Icons.category_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    category?.name ??
                        strings.accountDetailsTransactionsUncategorized,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(transaction.date),
                    style: theme.textTheme.bodySmall,
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        transaction.note!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  amountText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isIncome
                      ? strings.accountDetailsTypeIncome
                      : strings.accountDetailsTypeExpense,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}
