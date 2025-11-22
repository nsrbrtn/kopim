import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_providers.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_chart.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/widgets/category_chip.dart';
import 'package:kopim/l10n/app_localizations.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  static const String routeName = '/analytics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationTabContent content = buildAnalyticsTabContent(context, ref);
    return Scaffold(
      appBar: content.appBarBuilder?.call(context, ref),
      body: content.bodyBuilder(context, ref),
      floatingActionButton: content.floatingActionButtonBuilder?.call(
        context,
        ref,
      ),
    );
  }
}

NavigationTabContent buildAnalyticsTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  final AppLocalizations strings = AppLocalizations.of(context)!;
  return NavigationTabContent(
    appBarBuilder: (BuildContext context, WidgetRef ref) => AppBar(
      title: Text(strings.analyticsTitle),
      actions: <Widget>[
        IconButton(
          tooltip: strings.analyticsTitle,
          icon: const Icon(Icons.help_outline_outlined),
          onPressed: () => _showAnalyticsInfo(context),
        ),
      ],
    ),
    bodyBuilder: (BuildContext context, WidgetRef ref) {
      final AsyncValue<AnalyticsOverview> overviewAsync = ref.watch(
        analyticsFilteredStatsProvider(topCategoriesLimit: 5),
      );
      final AsyncValue<List<Category>> categoriesAsync = ref.watch(
        analyticsCategoriesProvider,
      );
      final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
        analyticsAccountsProvider,
      );
      final AnalyticsFilterState filterState = ref.watch(
        analyticsFilterControllerProvider,
      );

      final List<Category> categories =
          categoriesAsync.value ?? const <Category>[];
      final List<AccountEntity> accounts =
          accountsAsync.value ?? const <AccountEntity>[];
      final bool isLoading =
          overviewAsync.isLoading ||
          categoriesAsync.isLoading ||
          accountsAsync.isLoading;
      final Object? error =
          overviewAsync.error ?? categoriesAsync.error ?? accountsAsync.error;
      final AnalyticsOverview? overview = overviewAsync.value;

      final Size size = MediaQuery.of(context).size;
      final double horizontalPadding = size.width >= 960
          ? size.width * 0.15
          : 24;

      return SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: ValueKey<int>(
                    Object.hashAll(<Object?>[
                      filterState,
                      accounts.length,
                      categories.length,
                    ]),
                  ),
                  child: _AnalyticsFiltersCard(
                    filterState: filterState,
                    accounts: accounts,
                    strings: strings,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _AnalyticsQuickSelectors(
                  filterState: filterState,
                  accounts: accounts,
                  categories: categories,
                  strings: strings,
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _AnalyticsError(
                  message: error.toString(),
                  strings: strings,
                ),
              )
            else if (overview == null ||
                (overview.totalIncome == 0 && overview.totalExpense == 0))
              SliverFillRemaining(
                hasScrollBody: false,
                child: _AnalyticsEmpty(strings: strings),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  32,
                ),
                sliver: SliverToBoxAdapter(
                  child: _AnalyticsContent(
                    overview: overview,
                    categories: categories,
                    filterState: filterState,
                    strings: strings,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      );
    },
  );
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({
    required this.overview,
    required this.categories,
    required this.filterState,
    required this.strings,
  });

  final AnalyticsOverview overview;
  final List<Category> categories;
  final AnalyticsFilterState filterState;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );
    final Map<String, Category> categoriesById = <String, Category>{
      for (final Category category in categories) category.id: category,
    };
    final double totalExpense = overview.totalExpense;
    final double totalIncome = overview.totalIncome;
    final DateFormat dateRangeFormat = DateFormat.yMMMMd(strings.localeName);
    final String startLabel = dateRangeFormat.format(
      filterState.dateRange.start,
    );
    final String endLabel = dateRangeFormat.format(filterState.dateRange.end);
    final String rangeLabel = startLabel == endLabel
        ? startLabel
        : strings.analyticsFilterDateValue(startLabel, endLabel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.analyticsOverviewRangeTitle(rangeLabel),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        _AnalyticsSummaryFrame(
          overview: overview,
          currencyFormat: currencyFormat,
          strings: strings,
        ),
        const SizedBox(height: 24),
        Text(
          strings.analyticsTopCategoriesTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if ((overview.topExpenseCategories.isEmpty || totalExpense == 0) &&
            (overview.topIncomeCategories.isEmpty || totalIncome == 0))
          Text(
            strings.analyticsTopCategoriesEmpty,
            style: theme.textTheme.bodyMedium,
          )
        else
          _TopCategoriesPager(
            expenseBreakdowns: overview.topExpenseCategories,
            incomeBreakdowns: overview.topIncomeCategories,
            categoriesById: categoriesById,
            totalExpense: totalExpense,
            totalIncome: totalIncome,
            currencyFormat: currencyFormat,
            strings: strings,
          ),
      ],
    );
  }
}

class _AnalyticsSummaryFrame extends StatelessWidget {
  const _AnalyticsSummaryFrame({
    required this.overview,
    required this.currencyFormat,
    required this.strings,
  });

  final AnalyticsOverview overview;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_SummaryEntry> entries = <_SummaryEntry>[
      _SummaryEntry(
        label: strings.analyticsSummaryIncomeLabel,
        value: overview.totalIncome,
        color: theme.colorScheme.primary,
      ),
      _SummaryEntry(
        label: strings.analyticsSummaryExpenseLabel,
        value: overview.totalExpense,
        color: theme.colorScheme.error,
      ),
      _SummaryEntry(
        label: strings.analyticsSummaryNetLabel,
        value: overview.netBalance,
        color: overview.netBalance >= 0
            ? theme.colorScheme.primary
            : theme.colorScheme.error,
      ),
    ];

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final TextStyle baseValueStyle =
                theme.textTheme.headlineSmall ??
                theme.textTheme.titleLarge ??
                const TextStyle(fontSize: 24);
            final double? baseFontSize = baseValueStyle.fontSize;
            final TextStyle valueStyle = baseValueStyle.copyWith(
              fontSize: baseFontSize != null
                  ? baseFontSize * 0.8
                  : baseFontSize,
              height: 1.1,
            );

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (
                  int index = 0;
                  index < entries.length;
                  index++
                ) ...<Widget>[
                  Expanded(
                    child: _SummaryValue(
                      entry: entries[index],
                      currencyFormat: currencyFormat,
                      textAlign: TextAlign.center,
                      valueStyle: valueStyle,
                    ),
                  ),
                  if (index < entries.length - 1) const SizedBox(width: 16),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryEntry {
  const _SummaryEntry({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.entry,
    required this.currencyFormat,
    required this.textAlign,
    required this.valueStyle,
  });

  final _SummaryEntry entry;
  final NumberFormat currencyFormat;
  final TextAlign textAlign;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(entry.label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
          currencyFormat.format(entry.value),
          textAlign: textAlign,
          style: valueStyle.copyWith(
            color: entry.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsFiltersCard extends ConsumerWidget {
  const _AnalyticsFiltersCard({
    required this.filterState,
    required this.accounts,
    required this.strings,
  });

  final AnalyticsFilterState filterState;
  final List<AccountEntity> accounts;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final DateFormat dateFormat = DateFormat.yMMMd(strings.localeName);
    final String startText = dateFormat.format(filterState.dateRange.start);
    final String endText = dateFormat.format(filterState.dateRange.end);
    final String dateValue = startText == endText
        ? startText
        : strings.analyticsFilterDateValue(startText, endText);
    final int activeCount = _resolveActiveFiltersCount(filterState);

    return KopimExpandableSectionPlayful(
      initiallyExpanded: false,
      title: strings.analyticsFiltersButtonLabel,
      leading: Icon(Icons.filter_list, color: colors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _FilterPill(
                label: 'Этот месяц',
                selected: filterState.period == AnalyticsPeriodPreset.thisMonth,
                onTap: () => ref
                    .read(analyticsFilterControllerProvider.notifier)
                    .applyThisMonth(),
              ),
              _FilterPill(
                label: 'Последние 30 дней',
                selected:
                    filterState.period == AnalyticsPeriodPreset.last30Days,
                onTap: () => ref
                    .read(analyticsFilterControllerProvider.notifier)
                    .applyLast30Days(),
              ),
              _FilterPill(
                label: 'Выбрать дату',
                selected:
                    filterState.period == AnalyticsPeriodPreset.customRange,
                onTap: () async {
                  final DateTimeRange? result = await showDateRangePicker(
                    context: context,
                    initialDateRange: filterState.dateRange,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(DateTime.now().year + 10, 12, 31),
                    locale: Locale(strings.localeName),
                  );
                  if (result == null) {
                    return;
                  }
                  ref
                      .read(analyticsFilterControllerProvider.notifier)
                      .updateDateRange(result);
                },
              ),
              _FilterPill(
                label: 'Бюджеты',
                selected: false,
                onTap: () => _showBudgetStub(context),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              _FilterBadge(
                count: activeCount,
                semanticsLabel: strings.analyticsFiltersBadgeSemantics(
                  activeCount,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateValue,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

int _resolveActiveFiltersCount(AnalyticsFilterState state) {
  final AnalyticsFilterState initial = AnalyticsFilterState.initial();
  int count = 0;
  if (state.accountIds.isNotEmpty) {
    count++;
  }
  if (state.categoryId != null) {
    count++;
  }
  if (state.dateRange != initial.dateRange || state.period != initial.period) {
    count++;
  }
  return count;
}

class _FilterBadge extends StatelessWidget {
  const _FilterBadge({required this.count, this.semanticsLabel});

  final int count;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasActive = count > 0;
    final Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasActive
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count.toString(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: hasActive
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (semanticsLabel == null) {
      return badge;
    }
    return Semantics(label: semanticsLabel, child: badge);
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color background = selected
        ? colors.primary
        : colors.surfaceContainerHigh;
    final Color foreground = selected ? colors.onPrimary : colors.onSurface;

    return ActionChip(
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? Colors.transparent : colors.outlineVariant,
        ),
      ),
      backgroundColor: background,
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onTap,
    );
  }
}

class _ActionChipTile extends StatelessWidget {
  const _ActionChipTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextStyle? labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: colors.onPrimary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size(90, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 20, color: colors.onPrimary),
        ],
      ),
    );
  }
}

class _AnalyticsQuickSelectors extends ConsumerWidget {
  const _AnalyticsQuickSelectors({
    required this.filterState,
    required this.accounts,
    required this.categories,
    required this.strings,
  });

  final AnalyticsFilterState filterState;
  final List<AccountEntity> accounts;
  final List<Category> categories;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String categoryLabel = _resolveCategoryLabel(
      categories: categories,
      selectedId: filterState.categoryId,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: <Widget>[
          _ActionChipTile(
            icon: Icons.calendar_month_outlined,
            label: _formatMonthShort(
              filterState.monthAnchor ?? filterState.dateRange.start,
              strings.localeName,
            ),
            onTap: () => _openMonthPicker(
              context: context,
              ref: ref,
              current: filterState.monthAnchor ?? filterState.dateRange.start,
            ),
          ),
          _ActionChipTile(
            icon: Icons.account_balance_wallet_outlined,
            label: _resolveAccountsLabel(
              accounts: accounts,
              selectedIds: filterState.accountIds,
            ),
            onTap: () => _openAccountsPicker(
              context: context,
              ref: ref,
              accounts: accounts,
              selected: filterState.accountIds,
            ),
          ),
          _ActionChipTile(
            icon: Icons.category_outlined,
            label: categoryLabel,
            onTap: () => _openCategoryPicker(
              context: context,
              ref: ref,
              categories: categories,
              selectedId: filterState.categoryId,
            ),
          ),
        ],
      ),
    );
  }
}

void _showBudgetStub(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) {
      final ThemeData theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Бюджеты в разработке', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Фильтр по бюджетам появится позже. Сейчас чип служит заглушкой.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Понятно'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _openMonthPicker({
  required BuildContext context,
  required WidgetRef ref,
  required DateTime current,
}) async {
  final ThemeData theme = Theme.of(context);
  final DateTime now = DateTime.now();
  final List<DateTime> months = List<DateTime>.generate(12, (int index) {
    final DateTime date = DateTime(now.year, now.month - index);
    return DateTime(date.year, date.month);
  });

  final DateTime? picked = await showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    backgroundColor: theme.colorScheme.surface,
    builder: (BuildContext context) {
      return SafeArea(
        top: false,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: months.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            final DateTime month = months[index];
            final bool isSelected =
                month.year == current.year && month.month == current.month;
            return ListTile(
              title: Text(
                _formatMonthShort(
                  month,
                  AppLocalizations.of(context)!.localeName,
                ),
              ),
              subtitle: Text('${month.year} год'),
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(month),
            );
          },
        ),
      );
    },
  );

  if (picked != null) {
    ref.read(analyticsFilterControllerProvider.notifier).selectMonth(picked);
  }
}

Future<void> _openAccountsPicker({
  required BuildContext context,
  required WidgetRef ref,
  required List<AccountEntity> accounts,
  required Set<String> selected,
}) async {
  final Set<String> tempSelection = <String>{...selected};
  final ThemeData theme = Theme.of(context);
  final ColorScheme colors = theme.colorScheme;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: colors.surface,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Счета для аналитики',
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() => tempSelection.clear());
                        },
                        child: const Text('Сбросить'),
                      ),
                    ],
                  ),
                  ...accounts.map((AccountEntity account) {
                    final bool checked = tempSelection.contains(account.id);
                    return CheckboxListTile(
                      value: checked,
                      dense: true,
                      onChanged: (_) {
                        setState(() {
                          if (checked) {
                            tempSelection.remove(account.id);
                          } else {
                            tempSelection.add(account.id);
                          }
                        });
                      },
                      title: Text(account.name),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ref
                            .read(analyticsFilterControllerProvider.notifier)
                            .setAccounts(tempSelection);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Применить'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

String _formatMonthShort(DateTime date, String locale) {
  final String raw = DateFormat.MMM(locale).format(date);
  return raw.replaceAll('.', '').toLowerCase();
}

String _resolveAccountsLabel({
  required List<AccountEntity> accounts,
  required Set<String> selectedIds,
}) {
  if (selectedIds.isEmpty) {
    return 'Все счета';
  }
  if (selectedIds.length == 1) {
    final AccountEntity? account = accounts.firstWhereOrNull(
      (AccountEntity item) => item.id == selectedIds.first,
    );
    return account?.name ?? 'Выбран 1 счёт';
  }
  return 'Выбрано ${selectedIds.length} счетов';
}

String _resolveCategoryLabel({
  required List<Category> categories,
  required String? selectedId,
}) {
  if (selectedId == null) {
    return 'Все категории';
  }
  final Category? category = categories.firstWhereOrNull(
    (Category item) => item.id == selectedId,
  );
  return category?.name ?? 'Категория выбрана';
}

Future<void> _openCategoryPicker({
  required BuildContext context,
  required WidgetRef ref,
  required List<Category> categories,
  required String? selectedId,
}) async {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colors = theme.colorScheme;
  final String? picked = await showModalBottomSheet<String?>(
    context: context,
    showDragHandle: true,
    backgroundColor: colors.surface,
    builder: (BuildContext context) {
      return SafeArea(
        top: false,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: categories.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              final bool isSelected = selectedId == null;
              return ListTile(
                title: const Text('Все категории'),
                trailing: isSelected
                    ? Icon(Icons.check, color: colors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(null),
              );
            }
            final Category category = categories[index - 1];
            final bool isSelected = category.id == selectedId;
            return ListTile(
              leading: Icon(
                resolvePhosphorIconData(category.icon) ??
                    Icons.category_outlined,
              ),
              title: Text(category.name),
              trailing: isSelected
                  ? Icon(Icons.check, color: colors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(category.id),
            );
          },
        ),
      );
    },
  );

  final AnalyticsFilterController notifier = ref.read(
    analyticsFilterControllerProvider.notifier,
  );
  if (picked == null) {
    notifier.clearCategory();
  } else {
    notifier.updateCategory(picked);
  }
}

void _showAnalyticsInfo(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colors = theme.colorScheme;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: colors.surface,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Что показывает аналитика',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Круговая диаграмма и список категорий отражают распределение трат или доходов за выбранный период. Выберите период, месяц или счета, чтобы сфокусироваться на нужных данных.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Понятно'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _TopCategoriesPager extends StatefulWidget {
  const _TopCategoriesPager({
    required this.expenseBreakdowns,
    required this.incomeBreakdowns,
    required this.categoriesById,
    required this.totalExpense,
    required this.totalIncome,
    required this.currencyFormat,
    required this.strings,
  });

  final List<AnalyticsCategoryBreakdown> expenseBreakdowns;
  final List<AnalyticsCategoryBreakdown> incomeBreakdowns;
  final Map<String, Category> categoriesById;
  final double totalExpense;
  final double totalIncome;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  State<_TopCategoriesPager> createState() => _TopCategoriesPagerState();
}

class _TopCategoriesPagerState extends State<_TopCategoriesPager> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<AnalyticsChartItem> expenseItems = _mapBreakdowns(
      widget.expenseBreakdowns,
      widget.categoriesById,
      widget.strings,
      theme,
    );
    final List<AnalyticsChartItem> incomeItems = _mapBreakdowns(
      widget.incomeBreakdowns,
      widget.categoriesById,
      widget.strings,
      theme,
    );

    final List<_TopCategoriesPageData> pages = <_TopCategoriesPageData>[
      _TopCategoriesPageData(
        label: widget.strings.analyticsTopCategoriesExpensesTab,
        items: expenseItems,
        total: widget.totalExpense,
      ),
      _TopCategoriesPageData(
        label: widget.strings.analyticsTopCategoriesIncomeTab,
        items: incomeItems,
        total: widget.totalIncome,
      ),
    ];
    final int pageCount = pages.length;
    final int safeIndex = pageCount == 0
        ? 0
        : _pageIndex.clamp(0, pageCount - 1);

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SegmentedButton<int>(
              segments: <ButtonSegment<int>>[
                ButtonSegment<int>(
                  value: 0,
                  label: Text(widget.strings.analyticsTopCategoriesExpensesTab),
                ),
                ButtonSegment<int>(
                  value: 1,
                  label: Text(widget.strings.analyticsTopCategoriesIncomeTab),
                ),
              ],
              selected: <int>{safeIndex},
              onSelectionChanged: (Set<int> selected) {
                if (selected.isEmpty) {
                  return;
                }
                _setPage(selected.first, pageCount: pageCount);
              },
              style: const ButtonStyle(
                side: WidgetStatePropertyAll<BorderSide>(
                  BorderSide(style: BorderStyle.none),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (DragEndDetails details) {
                _handleHorizontalDragEnd(details, pageCount);
              },
              child: AnimatedSize(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: pageCount == 0
                      ? const SizedBox.shrink()
                      : _TopCategoriesPage(
                          key: ValueKey<int>(safeIndex),
                          data: pages[safeIndex],
                          currencyFormat: widget.currencyFormat,
                          strings: widget.strings,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setPage(int index, {required int pageCount}) {
    if (pageCount <= 0) {
      return;
    }
    final int clamped = index.clamp(0, pageCount - 1);
    if (clamped == _pageIndex) {
      return;
    }
    setState(() {
      _pageIndex = clamped;
    });
  }

  void _handleHorizontalDragEnd(DragEndDetails details, int pageCount) {
    if (pageCount <= 1) {
      return;
    }
    final double velocityX = details.velocity.pixelsPerSecond.dx;
    if (velocityX.abs() < 150) {
      return;
    }
    if (velocityX < 0 && _pageIndex < pageCount - 1) {
      _setPage(_pageIndex + 1, pageCount: pageCount);
    } else if (velocityX > 0 && _pageIndex > 0) {
      _setPage(_pageIndex - 1, pageCount: pageCount);
    }
  }

  List<AnalyticsChartItem> _mapBreakdowns(
    List<AnalyticsCategoryBreakdown> breakdowns,
    Map<String, Category> categoriesById,
    AppLocalizations strings,
    ThemeData theme,
  ) {
    return breakdowns
        .map((AnalyticsCategoryBreakdown breakdown) {
          final Category? category = breakdown.categoryId == null
              ? null
              : categoriesById[breakdown.categoryId!];
          final Color color =
              parseHexColor(category?.color) ?? theme.colorScheme.primary;
          final String title =
              category?.name ?? strings.analyticsCategoryUncategorized;
          final IconData? iconData = resolvePhosphorIconData(category?.icon);
          final String key = breakdown.categoryId ?? '_uncategorized';
          return AnalyticsChartItem(
            key: key,
            title: title,
            amount: breakdown.amount,
            color: color,
            icon: iconData,
          );
        })
        .toList(growable: false);
  }
}

class _TopCategoriesPageData {
  const _TopCategoriesPageData({
    required this.label,
    required this.items,
    required this.total,
  });

  final String label;
  final List<AnalyticsChartItem> items;
  final double total;
}

class _TopCategoriesPage extends StatefulWidget {
  const _TopCategoriesPage({
    super.key,
    required this.data,
    required this.currencyFormat,
    required this.strings,
  });

  final _TopCategoriesPageData data;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  State<_TopCategoriesPage> createState() => _TopCategoriesPageState();
}

class _TopCategoriesPageState extends State<_TopCategoriesPage> {
  final Set<String> _selectedKeys = <String>{};
  String? _focusedKey;

  @override
  Widget build(BuildContext context) {
    if (widget.data.items.isEmpty || widget.data.total <= 0) {
      return Center(
        child: Text(
          widget.strings.analyticsTopCategoriesEmpty,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = theme.colorScheme.surfaceContainerHighest
        .withValues(alpha: 0.32);
    final double capturedTotal = widget.data.total;
    final List<AnalyticsChartItem> chartItems = <AnalyticsChartItem>[
      ...widget.data.items,
    ];
    final double sumOfItems = chartItems.fold<double>(
      0,
      (double previous, AnalyticsChartItem item) =>
          previous + item.absoluteAmount,
    );
    final double remainder = (capturedTotal - sumOfItems).clamp(
      0,
      double.infinity,
    );
    if (remainder > 0.01) {
      chartItems.add(
        AnalyticsChartItem(
          key: '_others',
          title: widget.strings.analyticsTopCategoriesOthers,
          amount: remainder,
          color: theme.colorScheme.outlineVariant,
        ),
      );
    }

    _reconcileSelection(chartItems);

    final List<AnalyticsChartItem> activeItems = chartItems
        .where((AnalyticsChartItem item) => _selectedKeys.contains(item.key))
        .toList(growable: false);

    AnalyticsChartItem? focusedItem;
    if (_focusedKey != null) {
      focusedItem = activeItems.firstWhereOrNull(
        (AnalyticsChartItem item) => item.key == _focusedKey,
      );
    }

    int? selectedIndex;
    final String? focusKey = focusedItem?.key;
    if (focusKey != null) {
      final int candidateIndex = activeItems.indexWhere(
        (AnalyticsChartItem item) => item.key == focusKey,
      );
      if (candidateIndex >= 0) {
        selectedIndex = candidateIndex;
      }
    }
    final double selectedShare = focusedItem == null || capturedTotal <= 0
        ? 0
        : focusedItem.absoluteAmount / capturedTotal;
    final String selectedAmount = focusedItem == null
        ? widget.currencyFormat.format(capturedTotal)
        : widget.currencyFormat.format(focusedItem.absoluteAmount);
    final String selectedPercent = focusedItem == null
        ? '100%'
        : selectedShare >= 1
        ? '${(selectedShare * 100).round()}%'
        : '${(selectedShare * 100).toStringAsFixed(1)}%';

    final List<AnalyticsChartItem> displayItems = activeItems.isEmpty
        ? chartItems
        : activeItems;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.data.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size screenSize = MediaQuery.of(context).size;
            final double availableWidth =
                constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : screenSize.width;
            final double baseExtent = availableWidth * 0.7;
            final double chartExtent = baseExtent
                .clamp(220.0, 360.0)
                .toDouble();
            final double targetWidth = availableWidth
                .clamp(240.0, screenSize.width)
                .toDouble();

            final Widget chart = SizedBox(
              height: chartExtent,
              child: AnalyticsDonutChart(
                items: displayItems,
                backgroundColor: backgroundColor,
                totalAmount: capturedTotal,
                selectedIndex: selectedIndex,
                onSegmentSelected: (int index) {
                  if (index >= 0 && index < displayItems.length) {
                    setState(() {
                      _focusedKey = displayItems[index].key;
                    });
                  }
                },
              ),
            );

            return Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: targetWidth),
                child: chart,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          focusedItem == null
              ? widget.strings.analyticsTopCategoriesTapHint(selectedAmount)
              : '${focusedItem.title}: $selectedAmount · $selectedPercent',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        _TopCategoriesLegend(
          items: chartItems,
          currencyFormat: widget.currencyFormat,
          total: capturedTotal,
          selectedKeys: _selectedKeys,
          focusedKey: _focusedKey,
          onToggle: _handleToggle,
        ),
      ],
    );
  }

  void _reconcileSelection(List<AnalyticsChartItem> items) {
    if (items.isEmpty) {
      _selectedKeys.clear();
      _focusedKey = null;
      return;
    }

    final Set<String> availableKeys = items
        .map((AnalyticsChartItem item) => item.key)
        .toSet();
    if (_selectedKeys.isEmpty) {
      _selectedKeys.addAll(availableKeys);
    } else {
      final Set<String> valid = _selectedKeys
          .intersection(availableKeys)
          .toSet();
      if (valid.isEmpty) {
        _selectedKeys
          ..clear()
          ..addAll(availableKeys);
      } else if (valid.length != _selectedKeys.length) {
        _selectedKeys
          ..clear()
          ..addAll(valid);
      }
    }

    if (_focusedKey != null && !availableKeys.contains(_focusedKey)) {
      _focusedKey = availableKeys.first;
    }
  }

  void _handleToggle(AnalyticsChartItem item) {
    setState(() {
      if (_selectedKeys.contains(item.key)) {
        if (_selectedKeys.length > 1) {
          _selectedKeys.remove(item.key);
        }
      } else {
        _selectedKeys.add(item.key);
      }
      _focusedKey = item.key;
    });
  }
}

class _TopCategoriesLegend extends StatelessWidget {
  const _TopCategoriesLegend({
    required this.items,
    required this.currencyFormat,
    required this.total,
    required this.selectedKeys,
    required this.focusedKey,
    required this.onToggle,
  });

  final List<AnalyticsChartItem> items;
  final NumberFormat currencyFormat;
  final double total;
  final Set<String> selectedKeys;
  final String? focusedKey;
  final ValueChanged<AnalyticsChartItem> onToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty || total <= 0) {
      return const SizedBox.shrink();
    }
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final NumberFormat percentFormat = NumberFormat.decimalPattern(
      strings.localeName,
    );
    final NumberFormat smallPercentFormat = NumberFormat(
      '0.0',
      strings.localeName,
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List<Widget>.generate(items.length, (int index) {
        final AnalyticsChartItem item = items[index];
        final double percentage = item.absoluteAmount / total * 100;
        final String percentText = percentage >= 1
            ? '${percentFormat.format(percentage.round())}%'
            : '${smallPercentFormat.format(percentage)}%';
        final bool isSelected = selectedKeys.contains(item.key);
        final bool isFocused = focusedKey == item.key;
        return Tooltip(
          message: currencyFormat.format(item.absoluteAmount),
          waitDuration: const Duration(milliseconds: 400),
          child: CategoryChip(
            label: item.title,
            backgroundColor: item.color,
            selected: isSelected,
            onTap: () => onToggle(item),
            leading: Icon(item.icon ?? Icons.pie_chart_outline, size: 16),
            trailing: Text(
              percentText,
              style: isFocused
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

class _AnalyticsEmpty extends StatelessWidget {
  const _AnalyticsEmpty({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(strings.analyticsEmptyState, textAlign: TextAlign.center),
      ),
    );
  }
}

class _AnalyticsError extends StatelessWidget {
  const _AnalyticsError({required this.message, required this.strings});

  final String message;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          strings.analyticsLoadError(message),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
