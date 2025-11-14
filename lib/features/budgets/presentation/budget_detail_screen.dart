import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/budget_form_screen.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_card.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/l10n/app_localizations.dart';

class BudgetDetailScreen extends ConsumerWidget {
  const BudgetDetailScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<BudgetProgress> progressAsync = ref.watch(
      budgetProgressByIdProvider(budgetId),
    );
    final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
      budgetTransactionsByIdProvider(budgetId),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.budgetDetailTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: strings.editButtonLabel,
            onPressed: progressAsync.maybeWhen(
              data: (BudgetProgress progress) => () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        BudgetFormScreen(initialBudget: progress.budget),
                  ),
                );
              },
              orElse: () => null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: strings.deleteButtonLabel,
            onPressed: progressAsync.maybeWhen(
              data: (BudgetProgress progress) => () async {
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(strings.budgetDeleteTitle),
                      content: Text(strings.budgetDeleteMessage),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(strings.cancelButtonLabel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(strings.deleteButtonLabel),
                        ),
                      ],
                    );
                  },
                );
                if (confirmed != true) return;
                await ref
                    .read(deleteBudgetUseCaseProvider)
                    .call(progress.budget.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              orElse: () => null,
            ),
          ),
        ],
      ),
      body: progressAsync.when(
        data: (BudgetProgress progress) {
          return _BudgetDetailBody(
            progress: progress,
            transactionsAsync: transactionsAsync,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(error.toString()),
            ),
          );
        },
      ),
    );
  }
}

class _BudgetDetailBody extends ConsumerWidget {
  const _BudgetDetailBody({
    required this.progress,
    required this.transactionsAsync,
  });

  final BudgetProgress progress;
  final AsyncValue<List<TransactionEntity>> transactionsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat.yMMMMd(strings.localeName);
    final DateTime start = progress.instance.periodStart;
    final DateTime end = progress.instance.periodEnd;
    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      budgetAccountsStreamProvider,
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      budgetCategoriesStreamProvider,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BudgetCard(progress: progress),
          const SizedBox(height: 16),
          Text(
            strings.budgetPeriodLabel(
              dateFormat.format(start),
              dateFormat.format(end.subtract(const Duration(minutes: 1))),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            strings.budgetTransactionsTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          transactionsAsync.when(
            data: (List<TransactionEntity> transactions) {
              if (accountsAsync.isLoading || categoriesAsync.isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final Object? metaError =
                  accountsAsync.error ?? categoriesAsync.error;
              if (metaError != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    metaError.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                );
              }
              final Map<String, AccountEntity> accountsById =
                  <String, AccountEntity>{
                    for (final AccountEntity account
                        in accountsAsync.value ?? const <AccountEntity>[])
                      account.id: account,
                  };
              final Map<String, Category> categoriesById = <String, Category>{
                for (final Category category
                    in categoriesAsync.value ?? const <Category>[])
                  category.id: category,
              };
              final List<TransactionEntity> visibleTransactions = transactions
                  .where(
                    (TransactionEntity tx) =>
                        accountsById.containsKey(tx.accountId),
                  )
                  .toList(growable: false);
              if (visibleTransactions.isEmpty) {
                return Text(
                  strings.budgetTransactionsEmpty,
                  style: theme.textTheme.bodyMedium,
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleTransactions.length,
                itemBuilder: (BuildContext context, int index) {
                  final TransactionEntity transaction =
                      visibleTransactions[index];
                  final AccountEntity account =
                      accountsById[transaction.accountId]!;
                  final Category? category = transaction.categoryId == null
                      ? null
                      : categoriesById[transaction.categoryId!];
                  return _BudgetTransactionTile(
                    transaction: transaction,
                    account: account,
                    category: category,
                    strings: strings,
                    localeName: strings.localeName,
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stackTrace) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetTransactionTile extends ConsumerWidget {
  const _BudgetTransactionTile({
    required this.transaction,
    required this.account,
    required this.category,
    required this.strings,
    required this.localeName,
  });

  final TransactionEntity transaction;
  final AccountEntity account;
  final Category? category;
  final AppLocalizations strings;
  final String localeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isExpense =
        transaction.type == TransactionType.expense.storageValue;
    final IconData? categoryIcon = resolvePhosphorIconData(category?.icon);
    final Color? categoryColor = parseHexColor(category?.color);
    final Color avatarColor =
        categoryColor ?? theme.colorScheme.surfaceContainerHighest;
    final Color avatarForeground = categoryColor != null
        ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : theme.colorScheme.onSurfaceVariant;
    final String categoryName =
        category?.name ?? strings.homeTransactionsUncategorized;
    final String currencySymbol = account.currency.isNotEmpty
        ? resolveCurrencySymbol(account.currency, locale: localeName)
        : TransactionTileFormatters.fallbackCurrencySymbol(localeName);
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      localeName,
      currencySymbol,
    );
    final Color amountColor = isExpense
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final DateFormat dateFormat = DateFormat.yMMMd(localeName);
    final DateFormat timeFormat = DateFormat.Hm(localeName);

    return Dismissible(
      key: ValueKey<String>(transaction.id),
      direction: DismissDirection.endToStart,
      background: buildDeleteBackground(theme.colorScheme.error),
      confirmDismiss: (DismissDirection direction) =>
          deleteTransactionWithFeedback(
            context: context,
            ref: ref,
            transactionId: transaction.id,
            strings: strings,
          ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        surfaceTintColor: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          onTap: () => showTransactionEditorSheet(
            context: context,
            ref: ref,
            transaction: transaction,
            submitLabel: strings.editTransactionSubmit,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor,
                  foregroundColor: avatarForeground,
                  child: categoryIcon != null
                      ? Icon(categoryIcon, size: 22)
                      : const Icon(Icons.category_outlined, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        categoryName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${dateFormat.format(transaction.date)} · '
                          '${timeFormat.format(transaction.date)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (transaction.note != null &&
                          transaction.note!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            transaction.note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.68,
                              ),
                            ),
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
                      moneyFormat.format(transaction.amount.abs()),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.68,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
