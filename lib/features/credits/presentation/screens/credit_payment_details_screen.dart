import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/feed_item.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_draft_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_open_container.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';

class CreditPaymentDetailsScreenArgs {
  const CreditPaymentDetailsScreenArgs({
    required this.group,
    required this.currencySymbol,
  });

  final GroupedCreditPaymentFeedItem group;
  final String currencySymbol;
}

class CreditPaymentDetailsScreen extends StatelessWidget {
  const CreditPaymentDetailsScreen({required this.args, super.key});

  static const String routeName = '/credits/payment/details';

  final CreditPaymentDetailsScreenArgs args;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      context.loc.localeName,
      args.currencySymbol,
      decimalDigits: args.group.totalOutflow.scale,
    );
    final DateFormat dateFormat = DateFormat.yMMMMd(context.loc.localeName);
    final _PaymentBreakdown breakdown = _buildBreakdown(
      args.group.transactions,
    );
    final String? note = args.group.note;

    return Scaffold(
      appBar: AppBar(title: Text(context.loc.homeTransactionsGroupedPayment)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: <Widget>[
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              surfaceTintColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.loc.homeTransactionsGroupedPayment,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TransactionTileFormatters.formatAmount(
                        formatter: moneyFormat,
                        amount: MoneyAmount(
                          minor: args.group.totalOutflow.minor,
                          scale: args.group.totalOutflow.scale,
                        ),
                      ),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateFormat.format(args.group.date),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (note != null && note.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(note, style: theme.textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              surfaceTintColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.loc.creditsAmountLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BreakdownRow(
                      label: context.loc.creditPaymentDetailsPrincipalLabel,
                      value: breakdown.principal,
                      formatter: moneyFormat,
                    ),
                    _BreakdownRow(
                      label: context.loc.creditDetailsInterestLabel,
                      value: breakdown.interest,
                      formatter: moneyFormat,
                    ),
                    _BreakdownRow(
                      label: context.loc.creditPaymentDetailsFeesLabel,
                      value: breakdown.fees,
                      formatter: moneyFormat,
                    ),
                    if (breakdown.other.minor > BigInt.zero)
                      _BreakdownRow(
                        label: context.loc.creditPaymentDetailsOtherLabel,
                        value: breakdown.other,
                        formatter: moneyFormat,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              surfaceTintColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.loc.creditDetailsHistoryTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final TransactionEntity transaction
                        in args.group.transactions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TransactionRow(
                          transaction: transaction,
                          formatter: moneyFormat,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.formatter,
  });

  final String label;
  final MoneyAmount value;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            TransactionTileFormatters.formatAmount(
              formatter: formatter,
              amount: value,
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction, required this.formatter});

  final TransactionEntity transaction;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TransactionType type = parseTransactionType(transaction.type);
    final String label = switch (type) {
      TransactionType.transfer =>
        context.loc.creditPaymentDetailsPrincipalLabel,
      TransactionType.expense => context.loc.addTransactionTypeExpense,
      TransactionType.income => context.loc.addTransactionTypeIncome,
    };

    return TransactionFormOpenContainer(
      formArgs: TransactionFormArgs(initialTransaction: transaction),
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return Material(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: openContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      type == TransactionType.transfer
                          ? Icons.swap_horiz
                          : Icons.receipt_long,
                      size: 18,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((transaction.note ?? '').isNotEmpty)
                          Text(
                            transaction.note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    TransactionTileFormatters.formatAmount(
                      formatter: formatter,
                      amount: transaction.amountValue,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PaymentBreakdown {
  const _PaymentBreakdown({
    required this.principal,
    required this.interest,
    required this.fees,
    required this.other,
  });

  final MoneyAmount principal;
  final MoneyAmount interest;
  final MoneyAmount fees;
  final MoneyAmount other;
}

_PaymentBreakdown _buildBreakdown(List<TransactionEntity> transactions) {
  int scale = 2;
  BigInt principal = BigInt.zero;
  BigInt interest = BigInt.zero;
  BigInt fees = BigInt.zero;
  BigInt other = BigInt.zero;

  for (final TransactionEntity transaction in transactions) {
    scale = transaction.amountScale ?? scale;
    final BigInt amount = transaction.amountValue.abs().minor;
    final TransactionType type = parseTransactionType(transaction.type);
    final String note = (transaction.note ?? '').toLowerCase();

    if (type == TransactionType.transfer) {
      principal += amount;
      continue;
    }
    if (note.contains('interest') || note.contains('процент')) {
      interest += amount;
      continue;
    }
    if (note.contains('fee') ||
        note.contains('fees') ||
        note.contains('комисс')) {
      fees += amount;
      continue;
    }
    other += amount;
  }

  return _PaymentBreakdown(
    principal: MoneyAmount(minor: principal, scale: scale),
    interest: MoneyAmount(minor: interest, scale: scale),
    fees: MoneyAmount(minor: fees, scale: scale),
    other: MoneyAmount(minor: other, scale: scale),
  );
}
