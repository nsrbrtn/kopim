import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/main_navigation_controller.dart';
import '../models/navigation_tab_config.dart';

class MainNavigationBar extends ConsumerWidget {
  const MainNavigationBar({super.key, required this.tabs});

  final List<NavigationTabConfig> tabs;

  static const double height = 96; // Эмпирическая высота контента бара без safe-area.
  static const Duration _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final double backgroundOpacity = isDark ? 0.20 : 0.35;
    final Color backgroundColor = colorScheme.surfaceContainerHighest
        .withOpacity(backgroundOpacity);
    final Color onSurface = colorScheme.onSurface;
    final Color activeIconBackground = colorScheme.inverseSurface;
    final Color activeIconColor = colorScheme.surface;
    final Color activeLabelColor = onSurface;
    final Color inactiveColor = onSurface;

    final int currentIndex = ref.watch(
      mainNavigationControllerProvider.select((int value) => value),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (int index = 0; index < tabs.length; index++)
                    Expanded(
                      child: _NavigationBarItem(
                        label: tabs[index].labelBuilder(context),
                        icon: tabs[index].icon,
                        activeIcon: tabs[index].activeIcon,
                        isActive: index == currentIndex,
                        activeIconBackground: activeIconBackground,
                        activeIconColor: activeIconColor,
                        activeLabelColor: activeLabelColor,
                        inactiveColor: inactiveColor,
                        onTap: () => _handleTap(ref, context, index, currentIndex),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(
    WidgetRef ref,
    BuildContext context,
    int index,
    int currentIndex,
  ) {
    if (index == currentIndex) {
      final NavigationTabSelectionCallback? onSelected =
          tabs[index].onSelected;
      onSelected?.call(context, ref);
      return;
    }
    ref.read(mainNavigationControllerProvider.notifier).setIndex(index);
    final NavigationTabSelectionCallback? onSelected = tabs[index].onSelected;
    onSelected?.call(context, ref);
  }
}

class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.activeIconBackground,
    required this.activeIconColor,
    required this.activeLabelColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final bool isActive;
  final Color activeIconBackground;
  final Color activeIconColor;
  final Color activeLabelColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final IconData displayIcon = isActive && activeIcon != null
        ? activeIcon!
        : icon;
    final TextStyle? labelStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: isActive ? activeLabelColor : inactiveColor,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: MainNavigationBar._animationDuration,
              curve: Curves.easeInOut,
              width: isActive ? 64 : 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? activeIconBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              alignment: Alignment.center,
              child: Icon(
                displayIcon,
                color: isActive ? activeIconColor : inactiveColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
