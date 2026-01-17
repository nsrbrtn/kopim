import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/l10n/app_localizations.dart';

class ReminderListItem extends StatelessWidget {
  const ReminderListItem({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.timeService,
    required this.onMarkPaid,
    required this.onDelete,
  });

  final PaymentReminder reminder;
  final VoidCallback onTap;
  final TimeService timeService;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;

    final DateTime whenLocal = timeService.toLocal(reminder.whenAtMs);
    final DateFormat dateFormat = DateFormat.yMMMMd(strings.localeName);
    final DateFormat timeFormat = DateFormat.Hm(strings.localeName);
    final NumberFormat amountFormat = NumberFormat.currency(
      locale: strings.localeName,
      symbol: '',
      decimalDigits: 2,
    );
    final String amountText = amountFormat.format(reminder.amount).trim();

    final String scheduleLabel =
        '${strings.upcomingPaymentsReminderDue(dateFormat.format(whenLocal))} · ${timeFormat.format(whenLocal)}';
    final String secondaryLabel = reminder.note?.trim().isNotEmpty == true
        ? reminder.note!.trim()
        : scheduleLabel;
    final String rightLabel = reminder.note?.trim().isNotEmpty == true
        ? scheduleLabel
        : '';

    final Color iconBackground = reminder.isDone
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.primaryContainer;
    final Color iconForeground = reminder.isDone
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          onLongPress: onDelete,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      reminder.isDone ? Icons.check_circle : Icons.alarm,
                      color: iconForeground,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        reminder.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          secondaryLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      amountText,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (rightLabel.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          rightLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                if (!reminder.isDone) ...<Widget>[
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: strings.upcomingPaymentsReminderMarkPaidTooltip,
                    onPressed: onMarkPaid,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
