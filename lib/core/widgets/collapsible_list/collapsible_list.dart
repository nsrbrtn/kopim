import 'package:flutter/material.dart';

class KopimExpandableSectionPlayful extends StatefulWidget {
  const KopimExpandableSectionPlayful({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.duration = const Duration(milliseconds: 260),
    this.onChanged,
    this.leading,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final Duration duration;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;

  @override
  State<KopimExpandableSectionPlayful> createState() =>
      _KopimExpandableSectionPlayfulState();
}

class _KopimExpandableSectionPlayfulState
    extends State<KopimExpandableSectionPlayful>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  late final Animation<double> _contentAnimation;
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: _expanded ? 1.0 : 0.0,
    );

    // Более "игровая" кривая: лёгкий овершут при раскрытии
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    // Анимация контента без оверсшута для Fade/Size transitions.
    _contentAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant KopimExpandableSectionPlayful oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onChanged?.call(_expanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return AnimatedBuilder(
      animation: _curve,
      builder: (BuildContext context, Widget? _) {
        final double t = _curve.value;
        final double contentT = _contentAnimation.value;

        // Поп-эффект: при раскрытии слегка увеличиваем масштаб
        final double scale = 1.0 + 0.02 * t;
        // Лёгкое "парение": при открытии панель немного поднимается
        final double yOffset = t * 6.0;

        final Color bgColor = colors.surfaceContainer;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Хедер
                  InkWell(
                    onTap: _toggle,
                    borderRadius: BorderRadius.circular(28),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          if (widget.leading != null) ...<Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: widget.leading!,
                            ),
                          ],
                          Expanded(
                            child: Text(
                              widget.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          RotationTransition(
                            turns: Tween<double>(begin: 0.0, end: 0.5)
                                .animate(_curve),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: colors.onSurface,
                              size: 21,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Контент: высота + прозрачность + лёгкий сдвиг вверх
                  SizeTransition(
                    sizeFactor: _contentAnimation,
                    axisAlignment: -1.0, // схлопываем вверх — хедер не скачет
                    child: FadeTransition(
                      opacity: _contentAnimation,
                      child: Transform.translate(
                        offset: Offset(0, (1 - contentT) * 8),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
