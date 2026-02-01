import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/mark_reminder_done_uc.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeUpcomingItemsCard extends ConsumerStatefulWidget {
  const HomeUpcomingItemsCard({
    super.key,
    required this.items,
    required this.strings,
    required this.timeService,
    required this.onMore,
  });

  final List<UpcomingItem> items;
  final AppLocalizations strings;
  final TimeService timeService;
  final VoidCallback onMore;

  @override
  ConsumerState<HomeUpcomingItemsCard> createState() =>
      _HomeUpcomingItemsCardState();
}

class _HomeUpcomingItemsCardState
    extends ConsumerState<HomeUpcomingItemsCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double cardRadius = context.kopimLayout.radius.xxl;
    final BorderRadius borderRadius = BorderRadius.circular(cardRadius);
    final bool hasItems = widget.items.isNotEmpty;
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      homeCategoriesProvider,
    );
    final Map<String, Category> categories = <String, Category>{
      for (final Category category in categoriesAsync.value ?? const <Category>[])
        category.id: category,
    };
    final int paymentCount = widget.items
        .where((UpcomingItem item) => item.type == UpcomingItemType.paymentRule)
        .length;
    final int reminderCount = widget.items
        .where((UpcomingItem item) => item.type == UpcomingItemType.reminder)
        .length;

    Widget content;
    if (!hasItems) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          widget.strings.homeUpcomingPaymentsEmpty,
          style: theme.textTheme.bodyMedium,
        ),
      );
    } else if (_isExpanded) {
      content = Column(
        children: <Widget>[
          for (final UpcomingItem item in widget.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _UpcomingCompactCard(
                item: item,
                strings: widget.strings,
                timeService: widget.timeService,
                category: categories[item.categoryId],
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onMore,
              child: Text(widget.strings.homeUpcomingPaymentsMore),
            ),
          ),
        ],
      );
    } else {
      content = SizedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _UpcomingSummaryBadges(
            paymentCount: paymentCount,
            reminderCount: reminderCount,
            strings: widget.strings,
            theme: theme,
          ),
        ),
      );
    }

    final TextStyle? headerStyle = theme.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.strings.homeUpcomingPaymentsTitle,
                    style: headerStyle,
                  ),
                ),
                IconButton(
                  onPressed: hasItems ? _toggleExpanded : null,
                  tooltip: _isExpanded
                      ? widget.strings.homeUpcomingPaymentsCollapse
                      : widget.strings.homeUpcomingPaymentsExpand,
                  icon: AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: _isExpanded ? 0.5 : 0,
                    child: const Icon(Icons.expand_more),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            content,
          ],
        ),
      ),
    );
  }
}

class _UpcomingSummaryBadges extends StatelessWidget {
  const _UpcomingSummaryBadges({
    required this.paymentCount,
    required this.reminderCount,
    required this.strings,
    required this.theme,
  });

  final int paymentCount;
  final int reminderCount;
  final AppLocalizations strings;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final List<Widget> badges = <Widget>[];
    if (paymentCount > 0) {
      badges.add(
        _UpcomingBadge(
          count: paymentCount,
          icon: Icons.event_repeat,
          color: theme.colorScheme.primary,
          label: strings.homeUpcomingPaymentsBadgePaymentsLabel,
          semanticsLabel: strings.homeUpcomingPaymentsBadgePaymentsSemantics(
            paymentCount,
          ),
        ),
      );
    }
    if (reminderCount > 0) {
      badges.add(
        _UpcomingBadge(
          count: reminderCount,
          icon: Icons.alarm,
          color: theme.colorScheme.secondary,
          label: strings.homeUpcomingPaymentsBadgeRemindersLabel,
          semanticsLabel: strings.homeUpcomingPaymentsBadgeRemindersSemantics(
            reminderCount,
          ),
        ),
      );
    }

    if (badges.isEmpty) {
      return Text(
        strings.homeUpcomingPaymentsEmpty,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Wrap(spacing: 12, runSpacing: 8, children: badges);
  }
}

class _UpcomingBadge extends StatelessWidget {
  const _UpcomingBadge({
    required this.count,
    required this.icon,
    required this.color,
    required this.label,
    required this.semanticsLabel,
  });

  final int count;
  final IconData icon;
  final Color color;
  final String label;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color badgeTextColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Badge.count(
              count: count,
              backgroundColor: color,
              textColor: badgeTextColor,
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingCompactCard extends ConsumerWidget {
  const _UpcomingCompactCard({
    required this.item,
    required this.strings,
    required this.timeService,
    required this.category,
  });

  final UpcomingItem item;
  final AppLocalizations strings;
  final TimeService timeService;
  final Category? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final DateTime whenLocal = timeService.toLocal(item.whenMs);
    final DateFormat dateFormat = DateFormat('d MMM', strings.localeName);
    final NumberFormat amountFormat = NumberFormat.currency(
      locale: strings.localeName,
      symbol: '',
      decimalDigits: item.amount.scale,
    );
    final String amountText = amountFormat
        .format(item.amount.abs().toDouble())
        .trim();
    final bool isReminder = item.type == UpcomingItemType.reminder;
    final MarkReminderDoneUC markDone = ref.read(markReminderDoneUCProvider);

    Future<void> markReminderDone() async {
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      try {
        await markDone(MarkReminderDoneInput(id: item.id, isDone: true));
        if (!context.mounted) {
          return;
        }
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(strings.upcomingPaymentsReminderMarkPaidSuccess),
          ),
        );
      } catch (error) {
        if (!context.mounted) {
          return;
        }
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(
              strings.upcomingPaymentsReminderMarkPaidError(error.toString()),
            ),
          ),
        );
      }
    }

    final CategoryColorStyle categoryStyle = resolveCategoryColorStyle(
      category?.color,
    );
    final PhosphorIconData? iconData = resolvePhosphorIconData(category?.icon);
    final IconData fallbackIcon = isReminder ? Icons.alarm : Icons.category;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CategoryIcon(
            iconData: iconData,
            fallbackIcon: fallbackIcon,
            backgroundColor: categoryStyle.color,
            backgroundGradient: categoryStyle.backgroundGradient,
            sampleColor: categoryStyle.sampleColor,
            size: 34,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  dateFormat.format(whenLocal),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                amountText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isReminder)
                IconButton(
                  onPressed: markReminderDone,
                  icon: const Icon(Icons.check_circle_outline),
                  color: theme.colorScheme.onSurfaceVariant,
                  tooltip: strings.upcomingPaymentsReminderMarkPaidTooltip,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    this.iconData,
    required this.fallbackIcon,
    this.backgroundColor,
    this.backgroundGradient,
    this.sampleColor,
    required this.size,
    required this.borderRadius,
  });

  final IconData? iconData;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color? sampleColor;
  final double size;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color avatarBackground =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final Color resolvedSample =
        sampleColor ??
        backgroundColor ??
        theme.colorScheme.surfaceContainerHigh;
    final Color avatarForeground =
        (sampleColor != null || backgroundColor != null)
        ? (ThemeData.estimateBrightnessForColor(resolvedSample) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : theme.colorScheme.onSurface;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        color: backgroundGradient == null ? avatarBackground : null,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(iconData ?? fallbackIcon, color: avatarForeground, size: 20),
    );
  }
}
