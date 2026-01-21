import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/mark_reminder_done_uc.dart';

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
    final double cardRadius = context.kopimLayout.radius.xxl;
    final BorderRadius borderRadius = BorderRadius.circular(cardRadius);
    final bool hasItems = widget.items.isNotEmpty;
    final int paymentCount = widget.items
        .where((UpcomingItem item) => item.type == UpcomingItemType.paymentRule)
        .length;
    final int reminderCount = widget.items
        .where((UpcomingItem item) => item.type == UpcomingItemType.reminder)
        .length;

    Widget content;
    if (!hasItems) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          widget.strings.homeUpcomingPaymentsEmpty,
          style: theme.textTheme.bodyMedium,
        ),
      );
    } else if (_isExpanded) {
      content = Column(
        children: <Widget>[
          for (final UpcomingItem item in widget.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _UpcomingListRow(
                item: item,
                strings: widget.strings,
                timeService: widget.timeService,
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onMore,
              child: Text(widget.strings.homeUpcomingPaymentsMore),
            ),
          ),
        ],
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: _UpcomingSummaryBadges(
          paymentCount: paymentCount,
          reminderCount: reminderCount,
          strings: widget.strings,
          theme: theme,
        ),
      );
    }

    final TextStyle? headerStyle = theme.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w400,
    );
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.strings.homeUpcomingPaymentsTitle,
                    style: headerStyle,
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
              ],
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }
}

class _UpcomingSummaryBadges extends StatelessWidget {
  const _UpcomingSummaryBadges({
    required this.paymentCount,
    required this.reminderCount,
    required this.strings,
    required this.theme,
  });

  final int paymentCount;
  final int reminderCount;
  final AppLocalizations strings;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final List<Widget> badges = <Widget>[];
    if (paymentCount > 0) {
      badges.add(
        _UpcomingBadge(
          count: paymentCount,
          icon: Icons.event_repeat,
          color: theme.colorScheme.primary,
          label: strings.homeUpcomingPaymentsBadgePaymentsLabel,
          semanticsLabel: strings.homeUpcomingPaymentsBadgePaymentsSemantics(
            paymentCount,
          ),
        ),
      );
    }
    if (reminderCount > 0) {
      badges.add(
        _UpcomingBadge(
          count: reminderCount,
          icon: Icons.alarm,
          color: theme.colorScheme.secondary,
          label: strings.homeUpcomingPaymentsBadgeRemindersLabel,
          semanticsLabel: strings.homeUpcomingPaymentsBadgeRemindersSemantics(
            reminderCount,
          ),
        ),
      );
    }

    if (badges.isEmpty) {
      return Text(
        strings.homeUpcomingPaymentsEmpty,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Wrap(spacing: 12, runSpacing: 8, children: badges);
  }
}

class _UpcomingBadge extends StatelessWidget {
  const _UpcomingBadge({
    required this.count,
    required this.icon,
    required this.color,
    required this.label,
    required this.semanticsLabel,
  });

  final int count;
  final IconData icon;
  final Color color;
  final String label;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color badgeTextColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Badge.count(
              count: count,
              backgroundColor: color,
              textColor: badgeTextColor,
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingListRow extends ConsumerWidget {
  const _UpcomingListRow({
    required this.item,
    required this.strings,
    required this.timeService,
  });

  final UpcomingItem item;
  final AppLocalizations strings;
  final TimeService timeService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final DateTime whenLocal = timeService.toLocal(item.whenMs);
    final DateFormat dateFormat = DateFormat('dd.MM.yyyy', strings.localeName);
    final NumberFormat amountFormat = NumberFormat.currency(
      locale: strings.localeName,
      symbol: '',
      decimalDigits: 2,
    );
    final String amountText = amountFormat
        .format(item.amount.abs().toDouble())
        .trim();
    final bool isReminder = item.type == UpcomingItemType.reminder;
    final MarkReminderDoneUC markDone = ref.read(markReminderDoneUCProvider);

    Future<void> markReminderDone() async {
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      try {
        await markDone(MarkReminderDoneInput(id: item.id, isDone: true));
        if (!context.mounted) {
          return;
        }
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(strings.upcomingPaymentsReminderMarkPaidSuccess),
          ),
        );
      } catch (error) {
        if (!context.mounted) {
          return;
        }
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(
              strings.upcomingPaymentsReminderMarkPaidError(error.toString()),
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        amountText,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              dateFormat.format(whenLocal),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                letterSpacing: 0.4,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.calendar_today,
                            size: 16.3,
                            color: theme.colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isReminder)
            IconButton(
              onPressed: markReminderDone,
              icon: const Icon(Icons.check_circle_outline),
              color: theme.colorScheme.onSurface,
              tooltip: strings.upcomingPaymentsReminderMarkPaidTooltip,
            ),
        ],
      ),
    );
  }
}
