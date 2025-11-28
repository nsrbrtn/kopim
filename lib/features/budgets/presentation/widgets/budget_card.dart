import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';

import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/models/budget_category_spend.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_category_spending_chart_card.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_progress_indicator.dart';
import 'package:kopim/l10n/app_localizations.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    required this.progress,
    required this.categorySpend,
    required this.onOpenDetails,
    this.showDetailsButton = true,
    super.key,
  });

  final BudgetProgress progress;
  final List<BudgetCategorySpend> categorySpend;
  final VoidCallback onOpenDetails;
  final bool showDetailsButton;

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

    final Widget header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          progress.budget.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
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
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: KopimExpandableSectionPlayful(
        header: header,
        initiallyExpanded: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (showDetailsButton) ...<Widget>[
              SizedBox(height: spacing.section),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onOpenDetails,
                  icon: const Icon(Icons.chevron_right),
                  label: Text(strings.budgetsDetailsButton),
                ),
              ),
              SizedBox(height: spacing.section),
            ],
            BudgetCategorySpendingView(
              data: categorySpend,
              localeName: strings.localeName,
              strings: strings,
              wrapWithContainers: false,
              padding: EdgeInsets.zero,
            ),
          ],
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
        Text(
          value,
          style: valueStyle ??
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
