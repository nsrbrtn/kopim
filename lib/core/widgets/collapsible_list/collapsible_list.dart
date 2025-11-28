import 'package:flutter/material.dart';

class KopimExpandableSectionPlayful extends StatefulWidget {
  const KopimExpandableSectionPlayful({
    super.key,
    this.title,
    this.header,
    required this.child,
    this.initiallyExpanded = false,
    this.duration = const Duration(milliseconds: 260),
    this.onChanged,
    this.leading,
  }) : assert(title != null || header != null, 'Нужен title или header');

  final String? title;
  final Widget? header;
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
  late bool _isExpanding;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _isExpanding = _expanded;
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
      _isExpanding = _expanded;
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
      _isExpanding = _expanded;
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
        final double contentT = _contentAnimation.value;

        // Игра масштаба: при раскрытии появляется импульс вверх, при сворачивании — вниз.
        const double amplitude = 0.03;
        final double wave = 1 - (2 * contentT - 1).abs();
        final double direction = _isExpanding ? 1.0 : -1.0;
        final double scale = 1 + amplitude * direction * wave;

        return Transform.scale(
          alignment: Alignment.center,
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
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
                          child: widget.header ??
                              Text(
                                widget.title ?? '',
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
        );
      },
    );
  }
}
