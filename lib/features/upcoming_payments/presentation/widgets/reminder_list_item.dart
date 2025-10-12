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

    final List<Widget> subtitleChildren = <Widget>[
      Text(
        '${strings.upcomingPaymentsReminderDue(dateFormat.format(whenLocal))} · ${timeFormat.format(whenLocal)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      if (reminder.note != null && reminder.note!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            reminder.note!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: reminder.isDone
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            reminder.isDone ? Icons.check_circle : Icons.alarm,
            color: reminder.isDone
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(reminder.title, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: subtitleChildren,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  amountText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                reminder.isDone
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
              ),
              tooltip: strings.upcomingPaymentsReminderMarkPaidTooltip,
              onPressed: reminder.isDone ? null : onMarkPaid,
            ),
            const SizedBox(width: 4),
            PopupMenuButton<_ReminderAction>(
              onSelected: (_ReminderAction action) {
                switch (action) {
                  case _ReminderAction.edit:
                    onTap();
                    break;
                  case _ReminderAction.delete:
                    onDelete();
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<_ReminderAction>>[
                  PopupMenuItem<_ReminderAction>(
                    value: _ReminderAction.edit,
                    child: Text(strings.upcomingPaymentsReminderEditAction),
                  ),
                  PopupMenuItem<_ReminderAction>(
                    value: _ReminderAction.delete,
                    child: Text(strings.upcomingPaymentsReminderDeleteAction),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum _ReminderAction { edit, delete }
