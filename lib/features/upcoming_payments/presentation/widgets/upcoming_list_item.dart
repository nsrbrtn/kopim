import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/l10n/app_localizations.dart';

class UpcomingPaymentListItem extends StatelessWidget {
  const UpcomingPaymentListItem({
    super.key,
    required this.payment,
    required this.accounts,
    required this.categories,
    required this.onTap,
    required this.onDelete,
    required this.timeService,
  });

  final UpcomingPayment payment;
  final Map<String, AccountEntity> accounts;
  final Map<String, Category> categories;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final TimeService timeService;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    final AccountEntity? account = accounts[payment.accountId];
    final Category? category = categories[payment.categoryId];
    final PhosphorIconData? iconData = resolvePhosphorIconData(category?.icon);

    final NumberFormat formatter = NumberFormat.currency(
      locale: strings.localeName,
      symbol: (account?.currency ?? '').toUpperCase(),
    );
    final double amountAbs = payment.amount.abs();
    final bool isExpense = payment.amount >= 0;
    final Color amountColor = isExpense
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    final DateTime? nextRun = payment.nextRunAtMs != null
        ? timeService.toLocal(payment.nextRunAtMs!)
        : null;
    final DateTime? nextNotify = payment.nextNotifyAtMs != null
        ? timeService.toLocal(payment.nextNotifyAtMs!)
        : null;
    final DateTime? nextDate = _pickSoonest(nextRun, nextNotify);
    final DateFormat dateFormat = DateFormat.yMMMMd(strings.localeName);

    final List<String> subtitleParts = <String>[
      if (account != null && category != null)
        '${account.name} • ${category.name}'
      else if (account != null)
        account.name
      else if (category != null)
        category.name,
      strings.upcomingPaymentsMonthlySummary(payment.dayOfMonth),
      strings.upcomingPaymentsNotifySummary(
        payment.notifyDaysBefore,
        payment.notifyTimeHhmm,
      ),
      if (payment.note != null && payment.note!.isNotEmpty) payment.note!,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: iconData != null
              ? Icon(iconData, color: theme.colorScheme.primary)
              : const Icon(Icons.event_repeat),
        ),
        title: Text(payment.title, style: theme.textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final String line in subtitleParts)
                if (line.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  formatter.format(amountAbs),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (nextDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      dateFormat.format(nextDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<_UpcomingPaymentAction>(
              onSelected: (_UpcomingPaymentAction action) {
                switch (action) {
                  case _UpcomingPaymentAction.edit:
                    onTap();
                    break;
                  case _UpcomingPaymentAction.delete:
                    onDelete();
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<_UpcomingPaymentAction>>[
                  PopupMenuItem<_UpcomingPaymentAction>(
                    value: _UpcomingPaymentAction.edit,
                    child: Text(strings.upcomingPaymentsEditAction),
                  ),
                  PopupMenuItem<_UpcomingPaymentAction>(
                    value: _UpcomingPaymentAction.delete,
                    child: Text(strings.upcomingPaymentsDeleteAction),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _pickSoonest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isBefore(b) ? a : b;
  }
}

enum _UpcomingPaymentAction { edit, delete }
