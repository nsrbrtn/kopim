import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
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
    final double amountAbs = payment.amountValue.abs().toDouble();
    final Color amountColor = theme.colorScheme.onSurface;

    final String secondaryLabel = payment.note?.trim().isNotEmpty == true
        ? payment.note!.trim()
        : payment.title;

    final DateTime? nextDate = payment.nextRunAtMs != null
        ? timeService.toLocal(payment.nextRunAtMs!)
        : null;
    final DateFormat dateFormat = DateFormat.yMMMMd(strings.localeName);
    final String primaryLabel = nextDate != null
        ? dateFormat.format(nextDate)
        : strings.upcomingPaymentsMonthlySummary(payment.dayOfMonth);
    final CategoryColorStyle colorStyle = resolveCategoryColorStyle(
      category?.color,
    );
    final Gradient? iconBackgroundGradient = colorStyle.backgroundGradient;
    final Color iconBackground =
        colorStyle.sampleColor ?? theme.colorScheme.surfaceContainerHigh;
    final Color iconForeground = theme.colorScheme.shadow;

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
                    color: iconBackgroundGradient == null
                        ? iconBackground
                        : null,
                    gradient: iconBackgroundGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      iconData ?? PhosphorIcons.tag(PhosphorIconsStyle.fill),
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
                        primaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (secondaryLabel.isNotEmpty)
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
                      formatter.format(amountAbs),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (account != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          account.name,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
