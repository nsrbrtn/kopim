import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeUpcomingItemsCard extends StatelessWidget {
  const HomeUpcomingItemsCard({
    super.key,
    required this.items,
    required this.strings,
    required this.timeService,
    required this.onMore,
  });

  final List<UpcomingItem> items;
  final AppLocalizations strings;
  final TimeService timeService;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    strings.homeUpcomingPaymentsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onMore,
                  child: Text(strings.homeUpcomingPaymentsMore),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  strings.homeUpcomingPaymentsEmpty,
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              Column(
                children: <Widget>[
                  for (final UpcomingItem item in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _UpcomingListRow(
                        item: item,
                        strings: strings,
                        theme: theme,
                        timeService: timeService,
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

class _UpcomingListRow extends StatelessWidget {
  const _UpcomingListRow({
    required this.item,
    required this.strings,
    required this.theme,
    required this.timeService,
  });

  final UpcomingItem item;
  final AppLocalizations strings;
  final ThemeData theme;
  final TimeService timeService;

  @override
  Widget build(BuildContext context) {
    final DateTime whenLocal = timeService.toLocal(item.whenMs);
    final DateFormat dateFormat = DateFormat.MMMd(strings.localeName);
    final DateFormat timeFormat = DateFormat.Hm(strings.localeName);
    final NumberFormat amountFormat = NumberFormat.currency(
      locale: strings.localeName,
      symbol: '',
      decimalDigits: 2,
    );
    final bool isPayment = item.type == UpcomingItemType.paymentRule;
    final IconData icon = isPayment ? Icons.event_repeat : Icons.alarm;
    final Color accentColor = isPayment
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;
    final Color amountColor = item.amount >= 0
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final String amountText = amountFormat.format(item.amount.abs()).trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                dateFormat.format(whenLocal),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeFormat.format(whenLocal),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, size: 18, color: accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                amountText,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.note != null && item.note!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
