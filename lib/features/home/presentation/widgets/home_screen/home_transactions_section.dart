import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/features/profile/presentation/controllers/active_currency_code_provider.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/feed_item.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'home_transactions_filter_bar.dart';
import 'home_transaction_list_item.dart';
import 'home_grouped_credit_payment_list_item.dart';
import 'home_transactions_skeleton.dart';
import 'home_transaction_sliver_entry.dart';
import 'home_screen_commons.dart';

class HomeTransactionsSectionCard extends StatefulWidget {
  const HomeTransactionsSectionCard({
    super.key,
    required this.sections,
    required this.localeName,
    required this.strings,
    required this.onSeeAll,
  });

  final List<DaySection> sections;
  final String localeName;
  final AppLocalizations strings;
  final VoidCallback onSeeAll;

  @override
  State<HomeTransactionsSectionCard> createState() =>
      _HomeTransactionsSectionCardState();
}

class _HomeTransactionsSectionCardState
    extends State<HomeTransactionsSectionCard> {
  late List<HomeTransactionSliverEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _buildTransactionEntries(
      widget.sections,
      widget.localeName,
      widget.strings,
    );
  }

  @override
  void didUpdateWidget(covariant HomeTransactionsSectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.sections, widget.sections) ||
        oldWidget.localeName != widget.localeName) {
      _entries = _buildTransactionEntries(
        widget.sections,
        widget.localeName,
        widget.strings,
      );
    }
  }

  Widget _buildEntryList(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String fallbackCurrencySymbol = resolveCurrencySymbol(
      activeCurrencyCodeOf(context),
      locale: widget.localeName,
    );
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      widget.localeName,
      fallbackCurrencySymbol,
      decimalDigits: 0,
    );
    final TextStyle dateStyle =
        theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ) ??
        const TextStyle(fontSize: 16, height: 24 / 16);
    final TextStyle amountStyle =
        theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ) ??
        const TextStyle(fontSize: 14, height: 20 / 14);
    final bool hasTransactions = _entries.any(
      (HomeTransactionSliverEntry entry) =>
          entry is HomeTransactionItemEntry ||
          entry is HomeTransactionGroupEntry,
    );
    if (!hasTransactions) {
      return HomeEmptyMessage(message: widget.strings.homeTransactionsEmpty);
    }
    final List<Widget> widgets = <Widget>[];
    for (int i = 0; i < _entries.length; i++) {
      final HomeTransactionSliverEntry entry = _entries[i];
      if (entry is HomeTransactionHeaderEntry) {
        final MoneyAmount netAmount = resolveMoneyAmount(
          amount: entry.netAmount,
          scale: 2,
          useAbs: false,
        );
        final String formattedAmount = TransactionTileFormatters.formatAmount(
          formatter: moneyFormat,
          amount: netAmount,
        );
        final String amountLabel = netAmount.minor.isNegative
            ? '- $formattedAmount'
            : formattedAmount;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 24, bottom: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              child: SizedBox(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        entry.title,
                        style: dateStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(amountLabel, style: amountStyle),
                  ],
                ),
              ),
            ),
          ),
        );
        continue;
      }
      if (entry is HomeTransactionItemEntry) {
        widgets.add(
          HomeTransactionListItem(
            transactionId: entry.transactionId,
            localeName: widget.localeName,
            strings: widget.strings,
          ),
        );
        continue;
      }
      if (entry is HomeTransactionGroupEntry) {
        widgets.add(
          HomeGroupedCreditPaymentListItem(
            item: entry.item,
            localeName: widget.localeName,
            strings: widget.strings,
          ),
        );
        continue;
      }
      widgets.add(const SizedBox.shrink());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    return HomeTransactionsContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(widget.strings.homeTransactionsSection, style: titleStyle),
          const SizedBox(height: 16),
          HomeTransactionsFilterBar(strings: widget.strings),
          const SizedBox(height: 16),
          _buildEntryList(context),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: widget.onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              child: Text(widget.strings.homeTransactionsSeeAll),
            ),
          ),
        ],
      ),
    );
  }
}

List<HomeTransactionSliverEntry> _buildTransactionEntries(
  List<DaySection> sections,
  String localeName,
  AppLocalizations strings,
) {
  final DateTime today = DateUtils.dateOnly(DateTime.now());
  final DateTime yesterday = DateUtils.dateOnly(
    today.subtract(const Duration(days: 1)),
  );
  final DateFormat headerFormat = TransactionTileFormatters.dayHeader(
    localeName,
  );
  final List<HomeTransactionSliverEntry> entries =
      <HomeTransactionSliverEntry>[];
  for (final DaySection section in sections) {
    final String title = _formatSectionTitle(
      date: section.date,
      today: today,
      yesterday: yesterday,
      dateFormat: headerFormat,
      strings: strings,
    );
    final double netAmount = _calculateDayNet(section.items);
    entries.add(HomeTransactionHeaderEntry(title: title, netAmount: netAmount));
    for (final FeedItem item in section.items) {
      item.when(
        transaction: (TransactionEntity transaction) => entries.add(
          HomeTransactionItemEntry(transactionId: transaction.id),
        ),
        groupedCreditPayment:
            (
              String groupId,
              List<TransactionEntity> transactions,
              MoneyAmount totalOutflow,
              DateTime date,
              String? note,
            ) => entries.add(
              HomeTransactionGroupEntry(
                item: item as GroupedCreditPaymentFeedItem,
              ),
            ),
      );
    }
  }
  return entries;
}

double _calculateDayNet(List<FeedItem> items) {
  double income = 0;
  double expense = 0;
  for (final FeedItem item in items) {
    item.when(
      transaction: (TransactionEntity transaction) {
        if (transaction.type == TransactionType.income.storageValue) {
          income += transaction.amountValue.abs().toDouble();
        } else if (transaction.type == TransactionType.expense.storageValue) {
          expense += transaction.amountValue.abs().toDouble();
        }
      },
      groupedCreditPayment:
          (
            String groupId,
            List<TransactionEntity> transactions,
            MoneyAmount totalOutflow,
            DateTime date,
            String? note,
          ) {
            expense += totalOutflow.toDouble().abs();
          },
    );
  }
  return income - expense;
}

String _formatSectionTitle({
  required DateTime date,
  required DateTime today,
  required DateTime yesterday,
  required DateFormat dateFormat,
  required AppLocalizations strings,
}) {
  if (date.isAtSameMomentAs(today)) {
    return strings.homeTransactionsTodayLabel;
  }
  if (date.isAtSameMomentAs(yesterday)) {
    return strings.homeTransactionsYesterdayLabel;
  }
  final String formatted = dateFormat.format(date);
  return toBeginningOfSentenceCase(formatted) ?? formatted;
}
