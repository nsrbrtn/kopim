import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/budget_form_screen.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_card.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
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

class _BudgetDetailBody extends StatelessWidget {
  const _BudgetDetailBody({
    required this.progress,
    required this.transactionsAsync,
  });

  final BudgetProgress progress;
  final AsyncValue<List<TransactionEntity>> transactionsAsync;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );
    final DateFormat dateFormat = DateFormat.yMMMMd(strings.localeName);
    final DateTime start = progress.instance.periodStart;
    final DateTime end = progress.instance.periodEnd;

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
              if (transactions.isEmpty) {
                return Text(
                  strings.budgetTransactionsEmpty,
                  style: theme.textTheme.bodyMedium,
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (BuildContext context, int index) {
                  final TransactionEntity transaction = transactions[index];
                  final bool isIncome =
                      transaction.type.toLowerCase() == 'income';
                  final double amount = transaction.amount.abs();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      transaction.note?.isNotEmpty == true
                          ? transaction.note!
                          : strings.transactionDefaultTitle,
                    ),
                    subtitle: Text(dateFormat.format(transaction.date)),
                    trailing: Text(
                      currencyFormat.format(amount),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isIncome
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(height: 1),
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
