import 'package:flutter/material.dart';

class BudgetProgressIndicator extends StatelessWidget {
  const BudgetProgressIndicator({
    required this.value,
    this.exceeded = false,
    super.key,
  });

  final double value;
  final bool exceeded;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double clamped = value.isFinite ? value.clamp(0.0, 1.5) : 1.0;
    final Color activeColor = exceeded
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LinearProgressIndicator(
        minHeight: 12,
        value: clamped > 1 ? 1 : clamped,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(activeColor),
      ),
    );
  }
}
