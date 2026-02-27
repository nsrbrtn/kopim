import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:kopim/features/upcoming_payments/presentation/screens/edit_upcoming_payment_screen.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
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

class _HomeUpcomingItemsCardState extends ConsumerState<HomeUpcomingItemsCard> {
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
      for (final Category category
          in categoriesAsync.value ?? const <Category>[])
        category.id: category,
    };
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
      final DateFormat compactDateFormat = DateFormat(
        'd MMM',
        widget.strings.localeName,
      );
      final String currencySymbol =
          TransactionTileFormatters.fallbackCurrencySymbol(
            widget.strings.localeName,
          );
      final Map<int, NumberFormat> amountFormatsByScale = <int, NumberFormat>{};

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
                dateFormat: compactDateFormat,
                amountFormat: amountFormatsByScale.putIfAbsent(
                  item.amount.scale,
                  () => TransactionTileFormatters.currency(
                    widget.strings.localeName,
                    currencySymbol,
                    decimalDigits: item.amount.scale,
                  ),
                ),
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
          child: _UpcomingCollapsedItemsRow(
            items: widget.items,
            categories: categories,
            strings: widget.strings,
            timeService: widget.timeService,
          ),
        ),
      );
    }

    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: hasItems ? _toggleExpanded : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.strings.homeUpcomingPaymentsTitle,
                      style: theme.textTheme.titleLarge,
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
            ),
            const SizedBox(height: 4),
            content,
          ],
        ),
      ),
    );
  }
}

class _UpcomingCollapsedItemsRow extends StatelessWidget {
  const _UpcomingCollapsedItemsRow({
    required this.items,
    required this.categories,
    required this.strings,
    required this.timeService,
  });

  final List<UpcomingItem> items;
  final Map<String, Category> categories;
  final AppLocalizations strings;
  final TimeService timeService;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (items.isEmpty) {
      return Text(
        strings.homeUpcomingPaymentsEmpty,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    const int previewLimit = 6;
    final DateFormat dateFormat = DateFormat('d MMM', strings.localeName);
    final List<UpcomingItem> previewItems = items
        .take(previewLimit)
        .toList(growable: false);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final UpcomingItem item in previewItems)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _UpcomingCollapsedItemTile(
                item: item,
                category: categories[item.categoryId],
                strings: strings,
                timeService: timeService,
                dateFormat: dateFormat,
              ),
            ),
          if (items.length > previewLimit)
            _UpcomingCollapsedMoreBadge(
              count: items.length - previewLimit,
              strings: strings,
            ),
        ],
      ),
    );
  }
}

class _UpcomingCollapsedItemTile extends StatelessWidget {
  const _UpcomingCollapsedItemTile({
    required this.item,
    required this.category,
    required this.strings,
    required this.timeService,
    required this.dateFormat,
  });

  final UpcomingItem item;
  final Category? category;
  final AppLocalizations strings;
  final TimeService timeService;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime whenLocal = timeService.toLocal(item.whenMs);
    final bool isReminder = item.type == UpcomingItemType.reminder;
    final CategoryColorStyle categoryStyle = resolveCategoryColorStyle(
      category?.color,
    );
    final PhosphorIconData? iconData = resolvePhosphorIconData(category?.icon);
    final IconData fallbackIcon = isReminder ? Icons.alarm : Icons.event_repeat;
    final Color tileColor = theme.colorScheme.surfaceContainerHigh;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Center(
            child: _CategoryIcon(
              iconData: iconData,
              fallbackIcon: fallbackIcon,
              backgroundColor: categoryStyle.color,
              backgroundGradient: categoryStyle.backgroundGradient,
              sampleColor: categoryStyle.sampleColor,
              size: 34,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 56,
          child: Text(
            dateFormat.format(whenLocal),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _UpcomingCollapsedMoreBadge extends StatelessWidget {
  const _UpcomingCollapsedMoreBadge({
    required this.count,
    required this.strings,
  });

  final int count;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '+$count',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.homeUpcomingPaymentsOverflowIndicator,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
    required this.dateFormat,
    required this.amountFormat,
  });

  final UpcomingItem item;
  final AppLocalizations strings;
  final TimeService timeService;
  final Category? category;
  final DateFormat dateFormat;
  final NumberFormat amountFormat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final DateTime whenLocal = timeService.toLocal(item.whenMs);
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

    final bool canOpenPaymentEditor = item.type == UpcomingItemType.paymentRule;
    final EditUpcomingPaymentScreenArgs paymentArgs =
        EditUpcomingPaymentScreenArgs(paymentId: item.id);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: canOpenPaymentEditor
            ? () => context.push(paymentArgs.location, extra: paymentArgs)
            : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
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
              SizedBox(
                width: 104,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        tooltip:
                            strings.upcomingPaymentsReminderMarkPaidTooltip,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    final Color avatarForeground = theme.colorScheme.scrim;

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
