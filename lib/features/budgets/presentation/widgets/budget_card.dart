import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/config/theme_extensions.dart';

import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_progress_indicator.dart';
import 'package:kopim/l10n/app_localizations.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({required this.progress, this.onTap, super.key});

  final BudgetProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );
    final double limit = progress.budget.amount;
    final double spent = progress.spent;
    final double remaining = progress.remaining;
    final double ratio = progress.utilization.isFinite
        ? progress.utilization.clamp(0, 2)
        : 1.0;
    final bool exceeded = progress.isExceeded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(layout.radius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(layout.radius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(progress.budget.title, style: theme.textTheme.titleMedium),
                SizedBox(height: spacing.section),
                BudgetProgressIndicator(value: ratio, exceeded: exceeded),
                SizedBox(height: spacing.section),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _BudgetMetric(
                      label: strings.budgetsSpentLabel,
                      value: currencyFormat.format(spent),
                    ),
                    _BudgetMetric(
                      label: strings.budgetsLimitLabel,
                      value: currencyFormat.format(limit),
                    ),
                    _BudgetMetric(
                      label: exceeded
                          ? strings.budgetsExceededLabel
                          : strings.budgetsRemainingLabel,
                      value: currencyFormat.format(
                        exceeded ? (spent - limit) : remaining,
                      ),
                      valueStyle: exceeded
                          ? theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            )
                          : null,
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

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimSpacingScale spacing = context.kopimLayout.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: spacing.between / 2),
        Text(value, style: valueStyle ?? theme.textTheme.bodyMedium),
      ],
    );
  }
}
