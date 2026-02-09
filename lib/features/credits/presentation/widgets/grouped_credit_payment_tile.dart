import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/credits/presentation/screens/credit_payment_details_screen.dart';
import 'package:kopim/features/transactions/domain/models/feed_item.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/l10n/app_localizations.dart';

class GroupedCreditPaymentTile extends StatelessWidget {
  const GroupedCreditPaymentTile({
    super.key,
    required this.group,
    required this.currencySymbol,
    required this.strings,
  });

  final GroupedCreditPaymentFeedItem group;
  final String currencySymbol;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      strings.localeName,
      currencySymbol,
      decimalDigits: group.totalOutflow.scale,
    );
    final String summaryLabel = _buildSummaryLabel();
    final Widget content = Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.account_balance,
                size: 24,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  strings.homeTransactionsGroupedPayment,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (summaryLabel.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    summaryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            TransactionTileFormatters.formatAmount(
              formatter: moneyFormat,
              amount: MoneyAmount(
                minor: group.totalOutflow.minor,
                scale: group.totalOutflow.scale,
              ),
            ),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );

    Widget buildCard({VoidCallback? onTap}) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        surfaceTintColor: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return buildCard(
      onTap: () {
        context.push(
          CreditPaymentDetailsScreen.routeName,
          extra: CreditPaymentDetailsScreenArgs(
            group: group,
            currencySymbol: currencySymbol,
          ),
        );
      },
    );
  }

  String _buildSummaryLabel() {
    if (group.note != null && group.note!.isNotEmpty) {
      return group.note!;
    }
    return '';
  }
}
