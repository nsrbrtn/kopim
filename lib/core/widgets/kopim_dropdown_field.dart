import 'package:flutter/material.dart';

import '../config/theme_extensions.dart';

/// Dropdown с внешним видом/анимациями, аналогичными `KopimExpandableSectionPlayful`.
class KopimDropdownField<T> extends StatefulWidget {
  const KopimDropdownField({
    super.key,
    required this.items,
    required this.value,
    this.onChanged,
    this.label,
    this.leading,
    this.hint,
    this.duration = const Duration(milliseconds: 260),
    this.enabled = true,
    this.valueLabelBuilder,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? label;
  final Widget? leading;
  final String? hint;
  final Duration duration;
  final bool enabled;
  final String Function(T?)? valueLabelBuilder;

  @override
  State<KopimDropdownField<T>> createState() => _KopimDropdownFieldState<T>();
}

class _KopimDropdownFieldState<T> extends State<KopimDropdownField<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  late final Animation<double> _contentAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    _contentAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant KopimDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showMenu() async {
    if (!widget.enabled || widget.onChanged == null || widget.items.isEmpty) {
      return;
    }

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Rect buttonRect = offset & button.size;
    final RelativeRect position = RelativeRect.fromRect(
      buttonRect,
      Offset.zero & overlay.size,
    );
    final double minWidth = overlay.size.width * 0.7;
    final KopimLayout layout = context.kopimLayout;
    final double radius = layout.radius.xxl;
    setState(() {
      _isOpen = true;
    });
    _controller.forward();

    final List<PopupMenuEntry<T>> menuItems = <PopupMenuEntry<T>>[];
    final ColorScheme colors = Theme.of(context).colorScheme;
    for (int index = 0; index < widget.items.length; index++) {
      final DropdownMenuItem<T> item = widget.items[index];
      final bool isLast = index == widget.items.length - 1;
      final bool isSelected = item.value == widget.value;
      final Color textColor = isSelected
          ? colors.onSurface
          : colors.onSurfaceVariant;
      menuItems.add(
        PopupMenuItem<T>(
          enabled: item.enabled,
          value: item.value,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: DefaultTextStyle(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.copyWith(color: textColor),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: item.child,
                        ),
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          width: 1.5,
                        ),
                        color: isSelected ? colors.primary : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }
    final T? selected = await showMenu<T>(
      context: context,
      position: position,
      items: menuItems,
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: overlay.size.width,
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    if (!mounted) return;
    setState(() {
      _isOpen = false;
    });
    _controller.reverse();

    if (selected != null) {
      widget.onChanged?.call(selected);
    }
  }

  String _resolveValueLabel() {
    if (widget.value == null) {
      return widget.hint ?? '';
    }
    if (widget.valueLabelBuilder != null) {
      return widget.valueLabelBuilder!(widget.value);
    }
    if (widget.items.isEmpty) {
      return widget.hint ?? '';
    }
    final DropdownMenuItem<T> item = widget.items.firstWhere(
      (DropdownMenuItem<T> entry) => entry.value == widget.value,
      orElse: () => widget.items.first,
    );
    final Widget child = item.child;
    if (child is Text) {
      return child.data ?? '';
    }
    final T? fallbackValue = item.value;
    if (fallbackValue != null) {
      return fallbackValue.toString();
    }
    return widget.hint ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    const double amplitude = 0.03;
    final double contentT = _contentAnimation.value;
    final double wave = 1 - (2 * contentT - 1).abs();
    final double direction = _isOpen ? 1.0 : -1.0;
    final double scale = 1 + amplitude * direction * wave;

    final String labelText = _resolveValueLabel();

    return Transform.scale(
      alignment: Alignment.center,
      scale: scale,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _showMenu,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: <Widget>[
                if (widget.leading != null) ...<Widget>[
                  widget.leading!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (widget.label != null) ...<Widget>[
                        Text(
                          widget.label!,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        labelText,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: widget.value == null
                              ? colors.onSurfaceVariant
                              : colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                RotationTransition(
                  turns: Tween<double>(begin: 0.0, end: 0.5).animate(_curve),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
