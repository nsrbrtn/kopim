import 'package:flutter/material.dart';

class SwipeHintArrows extends StatelessWidget {
  const SwipeHintArrows({
    super.key,
    required this.canGoPreviousRange,
    required this.canGoNextRange,
    this.onPrevious,
    this.onNext,
  });

  final bool canGoPreviousRange;
  final bool canGoNextRange;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (!canGoPreviousRange && !canGoNextRange) {
      return const SizedBox.shrink();
    }

    return ExcludeSemantics(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
          child: Row(
            children: <Widget>[
              _SwipeHintArrow(
                icon: Icons.chevron_left_rounded,
                enabled: canGoPreviousRange,
                onTap: canGoPreviousRange ? onPrevious : null,
              ),
              const Spacer(),
              _SwipeHintArrow(
                icon: Icons.chevron_right_rounded,
                enabled: canGoNextRange,
                onTap: canGoNextRange ? onNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeHintArrow extends StatelessWidget {
  const _SwipeHintArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = theme.colorScheme.onSurfaceVariant;
    final double opacity = enabled ? 0.45 : 0.14;

    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 180),
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }
}
