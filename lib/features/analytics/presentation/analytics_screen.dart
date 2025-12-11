import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/domain/models/monthly_balance_data.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_providers.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_chart.dart';
import 'package:kopim/features/analytics/presentation/widgets/total_money_chart_widget.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/l10n/app_localizations.dart';

const String _othersCategoryKey = '_others';

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

class _TopCategoriesSummary extends StatelessWidget {
  const _TopCategoriesSummary({
    required this.strings,
    required this.currencyFormat,
    required this.total,
    required this.isIncome,
    required this.focusedItem,
  });

  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final double total;
  final bool isIncome;
  final AnalyticsChartItem? focusedItem;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle labelStyle =
        theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: theme.colorScheme.onSurface,
        ) ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: theme.colorScheme.onSurface,
        );
    final TextStyle amountStyle =
        theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface,
        ) ??
        TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface,
        );

    if (focusedItem != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('${focusedItem!.title}:', style: labelStyle),
          const SizedBox(width: 8),
          Text(
            currencyFormat.format(focusedItem!.absoluteAmount),
            style: amountStyle,
          ),
        ],
      );
    }

    final String label = isIncome
        ? strings.analyticsSummaryIncomeLabel
        : strings.analyticsSummaryExpenseLabel;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(label, style: labelStyle),
        const SizedBox(width: 8),
        Text(currencyFormat.format(total), style: amountStyle),
      ],
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
      final DateTime activeAnchor =
          filterState.monthAnchor ?? filterState.dateRange.start;
      final DateTime currentMonthStart = DateTime(
        DateTime.now().year,
        DateTime.now().month,
      );
      final DateTime today = DateUtils.dateOnly(DateTime.now());
      final bool isMonthBased =
          filterState.period == AnalyticsPeriodPreset.thisMonth ||
          filterState.period == AnalyticsPeriodPreset.customMonth;
      final DateTime anchorForBounds = isMonthBased
          ? DateTime(activeAnchor.year, activeAnchor.month)
          : DateUtils.dateOnly(activeAnchor);
      final bool canGoNextRange = isMonthBased
          ? anchorForBounds.isBefore(currentMonthStart)
          : filterState.dateRange.end.isBefore(today);
      final bool canGoPreviousRange = anchorForBounds.isAfter(DateTime(2000));

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

      return SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
            else if (overview == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _AnalyticsEmpty(strings: strings),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                sliver: SliverToBoxAdapter(
                  child: _AnalyticsContent(
                    overview: overview,
                    categories: categories,
                    filterState: filterState,
                    strings: strings,
                    activeAnchor: activeAnchor,
                    canGoNextRange: canGoNextRange,
                    canGoPreviousRange: canGoPreviousRange,
                    onGoPreviousRange: () => ref
                        .read(analyticsFilterControllerProvider.notifier)
                        .goToPreviousRangeStep(),
                    onGoNextRange: () => ref
                        .read(analyticsFilterControllerProvider.notifier)
                        .goToNextRangeStep(),
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
    required this.activeAnchor,
    required this.canGoNextRange,
    required this.canGoPreviousRange,
    required this.onGoPreviousRange,
    required this.onGoNextRange,
  });

  final AnalyticsOverview overview;
  final List<Category> categories;
  final AnalyticsFilterState filterState;
  final AppLocalizations strings;
  final DateTime activeAnchor;
  final bool canGoNextRange;
  final bool canGoPreviousRange;
  final VoidCallback onGoPreviousRange;
  final VoidCallback onGoNextRange;

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );
    final Map<String, Category> categoriesById = <String, Category>{
      for (final Category category in categories) category.id: category,
    };
    final double totalExpense = overview.totalExpense;
    final double totalIncome = overview.totalIncome;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final AsyncValue<List<MonthlyBalanceData>> monthlyDataAsync = ref
                .watch(monthlyBalanceDataProvider);

            return monthlyDataAsync.when(
              data: (List<MonthlyBalanceData> data) {
                if (data.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TotalMoneyChartWidget(
                    data: data,
                    currencySymbol: currencyFormat.currencySymbol,
                    selectedMonth: activeAnchor,
                    localeName: strings.localeName,
                    onMonthSelected: (DateTime month) {
                      ref
                          .read(analyticsFilterControllerProvider.notifier)
                          .selectMonth(month);
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (Object error, StackTrace stack) =>
                  const SizedBox.shrink(),
            );
          },
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final Animation<Offset> slide =
                Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: _TopCategoriesPager(
            key: ValueKey<DateTime>(activeAnchor),
            expenseBreakdowns: overview.topExpenseCategories,
            incomeBreakdowns: overview.topIncomeCategories,
            categoriesById: categoriesById,
            totalExpense: totalExpense,
            totalIncome: totalIncome,
            currencyFormat: currencyFormat,
            strings: strings,
            activeAnchor: activeAnchor,
            canGoNextRange: canGoNextRange,
            canGoPreviousRange: canGoPreviousRange,
            onPreviousRange: onGoPreviousRange,
            onNextRange: onGoNextRange,
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
    super.key,
    required this.expenseBreakdowns,
    required this.incomeBreakdowns,
    required this.categoriesById,
    required this.totalExpense,
    required this.totalIncome,
    required this.currencyFormat,
    required this.strings,
    required this.activeAnchor,
    required this.canGoNextRange,
    required this.canGoPreviousRange,
    required this.onPreviousRange,
    required this.onNextRange,
  });

  final List<AnalyticsCategoryBreakdown> expenseBreakdowns;
  final List<AnalyticsCategoryBreakdown> incomeBreakdowns;
  final Map<String, Category> categoriesById;
  final double totalExpense;
  final double totalIncome;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;
  final DateTime activeAnchor;
  final bool canGoNextRange;
  final bool canGoPreviousRange;
  final VoidCallback onPreviousRange;
  final VoidCallback onNextRange;

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
        isIncome: false,
      ),
      _TopCategoriesPageData(
        label: widget.strings.analyticsTopCategoriesIncomeTab,
        items: incomeItems,
        total: widget.totalIncome,
        isIncome: true,
      ),
    ];
    final int pageCount = pages.length;
    final int safeIndex = pageCount == 0
        ? 0
        : _pageIndex.clamp(0, pageCount - 1);

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _TopCategoriesToggle(
            safeIndex: safeIndex,
            onChanged: (int index) => _setPage(index, pageCount: pageCount),
            strings: widget.strings,
          ),
          const SizedBox(height: 8),
          AnimatedSize(
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
                      activeAnchor: widget.activeAnchor,
                      canGoNextRange: widget.canGoNextRange,
                      canGoPreviousRange: widget.canGoPreviousRange,
                      onPreviousRange: widget.onPreviousRange,
                      onNextRange: widget.onNextRange,
                    ),
            ),
          ),
        ],
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

  List<AnalyticsChartItem> _mapBreakdowns(
    List<AnalyticsCategoryBreakdown> breakdowns,
    Map<String, Category> categoriesById,
    AppLocalizations strings,
    ThemeData theme,
  ) {
    AnalyticsChartItem mapBreakdown(AnalyticsCategoryBreakdown breakdown) {
      final bool isOthers = breakdown.categoryId == _othersCategoryKey;
      final Category? category = breakdown.categoryId == null || isOthers
          ? null
          : categoriesById[breakdown.categoryId!];
      final Color color = isOthers
          ? theme.colorScheme.outlineVariant
          : parseHexColor(category?.color) ?? theme.colorScheme.primary;
      final String title = isOthers
          ? strings.analyticsTopCategoriesOthers
          : category?.name ?? strings.analyticsCategoryUncategorized;
      final IconData? iconData = isOthers
          ? Icons.more_horiz
          : resolvePhosphorIconData(category?.icon);
      final String key = breakdown.categoryId ?? '_uncategorized';
      final List<AnalyticsChartItem> children = breakdown.children
          .map(mapBreakdown)
          .toList(growable: false);

      return AnalyticsChartItem(
        key: key,
        title: title,
        amount: breakdown.amount,
        color: color,
        icon: iconData,
        children: children,
      );
    }

    return breakdowns.map(mapBreakdown).toList(growable: false);
  }
}

class _TopCategoriesPageData {
  const _TopCategoriesPageData({
    required this.label,
    required this.items,
    required this.total,
    required this.isIncome,
  });

  final String label;
  final List<AnalyticsChartItem> items;
  final double total;
  final bool isIncome;
}

class _TopCategoriesPage extends StatefulWidget {
  const _TopCategoriesPage({
    super.key,
    required this.data,
    required this.currencyFormat,
    required this.strings,
    required this.activeAnchor,
    required this.canGoNextRange,
    required this.canGoPreviousRange,
    required this.onPreviousRange,
    required this.onNextRange,
  });

  final _TopCategoriesPageData data;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;
  final DateTime activeAnchor;
  final bool canGoNextRange;
  final bool canGoPreviousRange;
  final VoidCallback onPreviousRange;
  final VoidCallback onNextRange;

  @override
  State<_TopCategoriesPage> createState() => _TopCategoriesPageState();
}

class _TopCategoriesPageState extends State<_TopCategoriesPage> {
  String? _highlightKey;

  @override
  void didUpdateWidget(covariant _TopCategoriesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeAnchor != oldWidget.activeAnchor) {
      _highlightKey = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    final bool isEmptyData =
        widget.data.items.isEmpty || widget.data.total <= 0;
    if (isEmptyData) {
      final ThemeData theme = Theme.of(context);
      final Color placeholderColor = theme.colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.7);
      final List<AnalyticsChartItem> placeholderItems = <AnalyticsChartItem>[
        AnalyticsChartItem(
          key: '_placeholder',
          title: widget.strings.analyticsEmptyState,
          amount: 1,
          color: placeholderColor,
        ),
      ];
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TopCategoriesSummary(
            strings: widget.strings,
            currencyFormat: widget.currencyFormat,
            total: 0,
            isIncome: widget.data.isIncome,
            focusedItem: null,
          ),
          const SizedBox(height: 8),
          _EmptyMonthChart(items: placeholderItems, color: placeholderColor),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.strings.analyticsEmptyState,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else {
      final ThemeData theme = Theme.of(context);
      final Color backgroundColor = theme.colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.32);
      final double capturedTotal = widget.data.total;
      final List<AnalyticsChartItem> chartItems = widget.data.items;

      AnalyticsChartItem? focusedItem;
      if (_highlightKey != null) {
        focusedItem = chartItems.firstWhereOrNull(
          (AnalyticsChartItem item) => item.key == _highlightKey,
        );
      }

      int? selectedIndex;
      final String? focusKey = focusedItem?.key;
      if (focusKey != null) {
        final int candidateIndex = chartItems.indexWhere(
          (AnalyticsChartItem item) => item.key == focusKey,
        );
        if (candidateIndex >= 0) {
          selectedIndex = candidateIndex;
        }
      }
      final List<AnalyticsChartItem> displayItems = chartItems;

      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TopCategoriesSummary(
            strings: widget.strings,
            currencyFormat: widget.currencyFormat,
            total: capturedTotal,
            isIncome: widget.data.isIncome,
            focusedItem: focusedItem,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Size screenSize = MediaQuery.sizeOf(context);
              final double availableWidth =
                  constraints.hasBoundedWidth &&
                      constraints.maxWidth.isFinite &&
                      constraints.maxWidth > 0
                  ? constraints.maxWidth
                  : screenSize.width;
              final double baseExtent = availableWidth * 0.7;
              final double chartExtent = baseExtent
                  .clamp(220.0, 360.0)
                  .toDouble();
              final double targetWidth = availableWidth
                  .clamp(240.0, screenSize.width)
                  .toDouble();

              final Widget chart = RepaintBoundary(
                child: SizedBox(
                  height: chartExtent,
                  child: AnalyticsDonutChart(
                    items: displayItems,
                    backgroundColor: backgroundColor,
                    totalAmount: capturedTotal,
                    selectedIndex: selectedIndex,
                    onSegmentSelected: (int index) {
                      if (index >= 0 && index < displayItems.length) {
                        setState(() {
                          final String key = displayItems[index].key;
                          _highlightKey = _highlightKey == key ? null : key;
                        });
                      }
                    },
                  ),
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
          const SizedBox(height: 40),
          _TopCategoriesLegend(
            items: chartItems,
            currencyFormat: widget.currencyFormat,
            total: capturedTotal,
            highlightedKey: _highlightKey,
            onToggle: _handleToggle,
          ),
        ],
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _handleChartHorizontalDragEnd,
      child: content,
    );
  }

  void _handleChartHorizontalDragEnd(DragEndDetails details) {
    const double threshold = 150;
    final double velocityX = details.velocity.pixelsPerSecond.dx;
    if (velocityX.abs() < threshold) {
      return;
    }
    if (velocityX > 0 && widget.canGoPreviousRange) {
      widget.onPreviousRange();
    } else if (velocityX < 0 && widget.canGoNextRange) {
      widget.onNextRange();
    }
  }

  void _handleToggle(AnalyticsChartItem item) {
    setState(() {
      _highlightKey = _highlightKey == item.key ? null : item.key;
    });
  }
}

class _EmptyMonthChart extends StatelessWidget {
  const _EmptyMonthChart({required this.items, required this.color});

  final List<AnalyticsChartItem> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size screenSize = MediaQuery.sizeOf(context);
        final double availableWidth =
            constraints.hasBoundedWidth &&
                constraints.maxWidth.isFinite &&
                constraints.maxWidth > 0
            ? constraints.maxWidth
            : screenSize.width;
        final double baseExtent = availableWidth * 0.7;
        final double chartExtent = baseExtent.clamp(220.0, 360.0).toDouble();
        final double targetWidth = availableWidth
            .clamp(240.0, screenSize.width)
            .toDouble();

        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: targetWidth),
            child: RepaintBoundary(
              child: SizedBox(
                height: chartExtent,
                child: AnalyticsDonutChart(
                  items: items,
                  backgroundColor: color.withValues(alpha: 0.2),
                  totalAmount: 1,
                  selectedIndex: null,
                  onSegmentSelected: null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopCategoriesLegend extends StatelessWidget {
  const _TopCategoriesLegend({
    required this.items,
    required this.currencyFormat,
    required this.total,
    required this.highlightedKey,
    required this.onToggle,
  });

  final List<AnalyticsChartItem> items;
  final NumberFormat currencyFormat;
  final double total;
  final String? highlightedKey;
  final ValueChanged<AnalyticsChartItem> onToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty || total <= 0) {
      return const SizedBox.shrink();
    }
    final AnalyticsChartItem? othersItem = items.firstWhereOrNull(
      (AnalyticsChartItem item) => item.key == _othersCategoryKey,
    );
    final bool showOthersChildren =
        highlightedKey == othersItem?.key &&
        (othersItem?.children.isNotEmpty ?? false);
    final List<Widget> legendItems = List<Widget>.generate(items.length, (
      int index,
    ) {
      final AnalyticsChartItem item = items[index];
      final String amountText = currencyFormat.format(item.absoluteAmount);
      final bool isSelected = highlightedKey == item.key;
      return _TopCategoryLegendItem(
        item: item,
        amountText: amountText,
        isSelected: isSelected,
        onTap: () => onToggle(item),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(spacing: 8, runSpacing: 8, children: legendItems),
        if (showOthersChildren) ...<Widget>[
          const SizedBox(height: 8),
          _OthersBreakdownList(
            items: othersItem!.children,
            currencyFormat: currencyFormat,
          ),
        ],
      ],
    );
  }
}

class _TopCategoryLegendItem extends StatelessWidget {
  const _TopCategoryLegendItem({
    required this.item,
    required this.amountText,
    required this.isSelected,
    this.onTap,
    this.compact = false,
  });

  final AnalyticsChartItem item;
  final String amountText;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;
    final double height = compact ? 48 : 56;

    final TextStyle titleStyle =
        theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: colors.onSurfaceVariant,
        ) ??
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: colors.onSurfaceVariant,
        );
    final TextStyle amountStyle =
        theme.textTheme.labelLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.1,
          color: colors.onSurfaceVariant,
        ) ??
        TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.1,
          color: colors.onSurfaceVariant,
        );

    return Tooltip(
      message: amountText,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: height,
            padding: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? colors.primary : Colors.transparent,
                width: isSelected ? 1.1 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 36,
                  height: 56,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    item.icon ?? Icons.pie_chart_outline,
                    size: layout.iconSizes.sm,
                    color: colors.surface,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      maxWidth: 200,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          amountText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: amountStyle,
                        ),
                      ],
                    ),
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

class _OthersBreakdownList extends StatelessWidget {
  const _OthersBreakdownList({
    required this.items,
    required this.currencyFormat,
  });

  final List<AnalyticsChartItem> items;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((AnalyticsChartItem item) {
            return _TopCategoryLegendItem(
              item: item,
              amountText: currencyFormat.format(item.absoluteAmount),
              isSelected: false,
              onTap: null,
              compact: true,
            );
          })
          .toList(growable: false),
    );
  }
}

class _TopCategoriesToggle extends StatelessWidget {
  const _TopCategoriesToggle({
    required this.safeIndex,
    required this.onChanged,
    required this.strings,
  });

  final int safeIndex;
  final ValueChanged<int> onChanged;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;
    const Duration duration = Duration(milliseconds: 260);
    final int clampedIndex = safeIndex.clamp(0, 1).toInt();

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(layout.radius.xxl),
      ),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double segmentWidth = constraints.maxWidth / 2;

          return SizedBox(
            height: 48,
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
                  left: clampedIndex * segmentWidth,
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
                  children: <Widget>[
                    Expanded(
                      child: _AnalyticsSegmentItem(
                        label: strings.analyticsTopCategoriesExpensesTab,
                        selected: clampedIndex == 0,
                        onTap: () => onChanged(0),
                        selectedTextColor: colors.onPrimary,
                      ),
                    ),
                    Expanded(
                      child: _AnalyticsSegmentItem(
                        label: strings.analyticsTopCategoriesIncomeTab,
                        selected: clampedIndex == 1,
                        onTap: () => onChanged(1),
                        selectedTextColor: colors.onPrimary,
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

class _AnalyticsSegmentItem extends StatelessWidget {
  const _AnalyticsSegmentItem({
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
