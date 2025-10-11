import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeUpcomingItemsCard extends StatefulWidget {
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
  State<HomeUpcomingItemsCard> createState() => _HomeUpcomingItemsCardState();
}

class _HomeUpcomingItemsCardState extends State<HomeUpcomingItemsCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasItems = widget.items.isNotEmpty;
    final String collapsedSummary = widget.strings
        .homeUpcomingPaymentsCollapsedSummary(widget.items.length);

    Widget content;
    if (!hasItems) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          widget.strings.homeUpcomingPaymentsEmpty,
          style: theme.textTheme.bodyMedium,
        ),
      );
    } else {
      content = AnimatedCrossFade(
        crossFadeState: _isExpanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 220),
        firstCurve: Curves.easeInOut,
        secondCurve: Curves.easeInOut,
        sizeCurve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        firstChild: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            collapsedSummary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        secondChild: Column(
          children: <Widget>[
            for (final UpcomingItem item in widget.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _UpcomingListRow(
                  item: item,
                  strings: widget.strings,
                  theme: theme,
                  timeService: widget.timeService,
                ),
              ),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.strings.homeUpcomingPaymentsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: hasItems ? _toggleExpanded : null,
                  tooltip: _isExpanded
                      ? widget.strings.homeUpcomingPaymentsCollapse
                      : widget.strings.homeUpcomingPaymentsExpand,
                  icon: AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: _isExpanded ? 0.5 : 0,
                    child: const Icon(Icons.expand_more),
                  ),
                ),
                TextButton(
                  onPressed: widget.onMore,
                  child: Text(widget.strings.homeUpcomingPaymentsMore),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
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
