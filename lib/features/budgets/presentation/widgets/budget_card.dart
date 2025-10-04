import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(progress.budget.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              BudgetProgressIndicator(value: ratio, exceeded: exceeded),
              const SizedBox(height: 12),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: valueStyle ?? theme.textTheme.bodyMedium),
      ],
    );
  }
}
