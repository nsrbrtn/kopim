import 'package:flutter/material.dart';
import 'package:kopim/core/config/theme_extensions.dart';

class KopimSegmentedOption<T> {
  const KopimSegmentedOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class KopimSegmentedControl<T> extends StatelessWidget {
  const KopimSegmentedControl({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.height = 48,
    this.padding = const EdgeInsets.all(6),
  }) : assert(options.length >= 2, 'Нужно минимум два сегмента');

  final List<KopimSegmentedOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;
    final int selectedIndex = options
        .indexWhere(
          (KopimSegmentedOption<T> option) => option.value == selectedValue,
        )
        .clamp(0, options.length - 1);

    const Duration duration = Duration(milliseconds: 260);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(layout.radius.xxl),
      ),
      padding: padding,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double segmentWidth = constraints.maxWidth / options.length;
          return SizedBox(
            height: height,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: duration,
                  curve: Curves.easeOutBack,
                  left: selectedIndex * segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: Curves.easeOutBack,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: colors.primary,
                    ),
                  ),
                ),
                Row(
                  children: options
                      .map((KopimSegmentedOption<T> option) {
                        final bool isSelected =
                            option.value == options[selectedIndex].value;
                        return Expanded(
                          child: _SegmentItem(
                            label: option.label,
                            icon: option.icon,
                            selected: isSelected,
                            selectedTextColor: colors.onPrimary,
                            onTap: () => onChanged(option.value),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.selected,
    required this.selectedTextColor,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final Color selectedTextColor;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle baseStyle =
        theme.textTheme.labelLarge ?? const TextStyle(fontSize: 16);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          scale: selected ? 1.0 : 0.95,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            style: baseStyle.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected
                  ? selectedTextColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: 18,
                    color: selected ? selectedTextColor : null,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
