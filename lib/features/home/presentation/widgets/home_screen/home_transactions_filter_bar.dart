import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/features/home/presentation/controllers/home_transactions_filter_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeTransactionsFilterBar extends ConsumerWidget {
  const HomeTransactionsFilterBar({super.key, required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final HomeTransactionsFilter selected = ref.watch(
      homeTransactionsFilterControllerProvider,
    );
    final KopimLayout layout = context.kopimLayout;
    final double containerRadius = layout.radius.xxl;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double segmentWidth = constraints.maxWidth / 3;
          final Color accent = theme.colorScheme.primary;
          const Duration duration = Duration(milliseconds: 260);

          int selectedIndex = 0;
          switch (selected) {
            case HomeTransactionsFilter.all:
              selectedIndex = 0;
            case HomeTransactionsFilter.income:
              selectedIndex = 1;
            case HomeTransactionsFilter.expense:
              selectedIndex = 2;
          }

          return SizedBox(
            height: 48,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
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
                      color: accent,
                      boxShadow: const <BoxShadow>[],
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: HomeFilterSegmentItem(
                        label: strings.homeTransactionsFilterAll,
                        selected: selected == HomeTransactionsFilter.all,
                        onTap: () => ref
                            .read(
                              homeTransactionsFilterControllerProvider.notifier,
                            )
                            .update(HomeTransactionsFilter.all),
                        selectedTextColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                    Expanded(
                      child: HomeFilterSegmentItem(
                        label: strings.homeTransactionsFilterIncome,
                        selected: selected == HomeTransactionsFilter.income,
                        onTap: () => ref
                            .read(
                              homeTransactionsFilterControllerProvider.notifier,
                            )
                            .update(HomeTransactionsFilter.income),
                        selectedTextColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                    Expanded(
                      child: HomeFilterSegmentItem(
                        label: strings.homeTransactionsFilterExpense,
                        selected: selected == HomeTransactionsFilter.expense,
                        onTap: () => ref
                            .read(
                              homeTransactionsFilterControllerProvider.notifier,
                            )
                            .update(HomeTransactionsFilter.expense),
                        selectedTextColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HomeFilterSegmentItem extends StatelessWidget {
  const HomeFilterSegmentItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedTextColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedTextColor;

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
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}
