import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';

import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/models/budget_category_spend.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_category_spending_chart_card.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_progress_indicator.dart';
import 'package:kopim/l10n/app_localizations.dart';

class BudgetCard extends StatefulWidget {
  const BudgetCard({
    required this.progress,
    required this.categorySpend,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onDelete,
    this.showDetailsButton = true,
    super.key,
  });

  final BudgetProgress progress;
  final List<BudgetCategorySpend> categorySpend;
  final VoidCallback onOpenDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDetailsButton;

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );
    final double limit = widget.progress.budget.amountValue.toDouble();
    final double spent = widget.progress.spent.toDouble();
    final double remaining = widget.progress.remaining.toDouble();
    final double ratio = widget.progress.utilization.isFinite
        ? widget.progress.utilization.clamp(0, 2)
        : 1.0;
    final bool exceeded = widget.progress.isExceeded;

    final Widget titleRow = Row(
      children: <Widget>[
        Expanded(
          child: Text(
            widget.progress.budget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.15,
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: _isExpanded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 24),
                onPressed: _isExpanded ? widget.onEdit : null,
                tooltip: strings.editButtonLabel,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(24, 24),
                ),
              ),
              const SizedBox(width: 32),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 24),
                onPressed: _isExpanded ? widget.onDelete : null,
                tooltip: strings.deleteButtonLabel,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(24, 24),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
      ],
    );

    final Widget statsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        BudgetProgressIndicator(value: ratio, exceeded: exceeded),
        const SizedBox(height: 16),
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
                  ? theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
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
        header: titleRow,
        bottomHeader: statsColumn,
        initiallyExpanded: false,
        onChanged: (bool expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.showDetailsButton) ...<Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onOpenDetails,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    textStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                  child: Text(strings.budgetsDetailsButton),
                ),
              ),
              SizedBox(height: spacing.section),
            ],
            BudgetCategorySpendingView(
              data: widget.categorySpend,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style:
              valueStyle ??
              theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
                color: theme.colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}
