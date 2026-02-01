import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/widgets/animated_fab.dart';
import 'package:kopim/core/widgets/kopim_glass_fab.dart';
import 'package:kopim/core/widgets/kopim_segmented_control.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_details_providers.dart';
import 'package:kopim/features/accounts/presentation/edit_account_screen.dart';
import 'package:kopim/features/accounts/presentation/widgets/account_transaction_list_tile.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/home/domain/use_cases/group_transactions_by_day_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_draft_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AccountDetailsScreen extends ConsumerStatefulWidget {
  const AccountDetailsScreen({required this.accountId, super.key});

  static const String routeName = '/accounts/details';

  final String accountId;

  static Route<void> route({required String accountId}) {
    return MaterialPageRoute<void>(
      builder: (_) => AccountDetailsScreen(accountId: accountId),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  ConsumerState<AccountDetailsScreen> createState() =>
      _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends ConsumerState<AccountDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<AccountEntity?> accountAsync = ref.watch(
      accountDetailsProvider(widget.accountId),
    );
    final AsyncValue<AccountTransactionSummary> summaryAsync = ref.watch(
      accountTransactionSummaryProvider(widget.accountId),
    );
    final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
      filteredAccountTransactionsProvider(widget.accountId),
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      accountCategoriesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: accountAsync.maybeWhen(
          data: (AccountEntity? account) =>
              Text(account?.name ?? strings.accountDetailsTitle),
          orElse: () => Text(strings.accountDetailsTitle),
        ),
        actions: <Widget>[
          accountAsync.maybeWhen(
            data: (AccountEntity? account) => IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: strings.accountDetailsEditTooltip,
              onPressed: account == null
                  ? null
                  : () => _openEditScreen(context, account),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: _AddTransactionButton(accountId: widget.accountId),
      body: SafeArea(
        child: accountAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => _ErrorMessage(
            message: strings.accountDetailsError(error.toString()),
          ),
          data: (AccountEntity? account) {
            if (account == null) {
              return _ErrorMessage(message: strings.accountDetailsMissing);
            }

            final AccountDetailsPeriod period = ref.watch(
              accountDetailsPeriodControllerProvider(account.id),
            );
            final DateTimeRange periodRange = ref.watch(
              accountDetailsPeriodRangeProvider(account.id),
            );
            final AsyncValue<List<TransactionCategoryTotals>>
            topCategoriesAsync = ref.watch(
              accountTopCategoryTotalsProvider(
                accountId: account.id,
                start: periodRange.start,
                end: periodRange.end,
              ),
            );

            final NumberFormat currencyFormat = NumberFormat.currency(
              locale: strings.localeName,
              symbol: resolveCurrencySymbol(
                account.currency,
                locale: strings.localeName,
              ),
              decimalDigits: account.currencyScale ?? 2,
            );
            final bool isWideLayout = MediaQuery.of(context).size.width >= 720;
            final EdgeInsets padding = EdgeInsets.symmetric(
              horizontal: isWideLayout
                  ? MediaQuery.of(context).size.width * 0.15
                  : 16,
              vertical: 16,
            );

            final List<Category> categoriesList =
                categoriesAsync.asData?.value ?? const <Category>[];
            final Map<String, Category> categoriesById = <String, Category>{
              for (final Category category in categoriesList)
                category.id: category,
            };
            final AsyncValue<List<TransactionEntity>> accountTransactionsAsync =
                ref.watch(accountTransactionsProvider(account.id));

            final List<_BalanceChartPoint> balancePoints =
                _buildBalanceChartPoints(
                  account: account,
                  transactions:
                      accountTransactionsAsync.asData?.value ??
                      const <TransactionEntity>[],
                  period: period,
                  range: periodRange,
                  localeName: strings.localeName,
                );

            final Widget summarySection = summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => _ErrorMessage(
                message: strings.accountDetailsSummaryError(error.toString()),
              ),
              data: (AccountTransactionSummary summary) =>
                  _AccountPeriodSummaryCard(
                    summary: summary,
                    currencyFormat: currencyFormat,
                    strings: strings,
                  ),
            );

            final Widget transactionsSection = transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => _ErrorMessage(
                message: strings.accountDetailsError(error.toString()),
              ),
              data: (List<TransactionEntity> transactions) {
                if (transactions.isEmpty) {
                  return _EmptyMessage(
                    message: strings.accountDetailsTransactionsEmpty,
                  );
                }
                final GroupTransactionsByDayUseCase groupUseCase = ref.watch(
                  groupTransactionsByDayUseCaseProvider,
                );
                final List<DaySection> sections = groupUseCase(
                  transactions: transactions,
                );
                return _AccountTransactionsSection(
                  sections: sections,
                  strings: strings,
                  currency: account.currency,
                  currencyScale: account.currencyScale ?? 2,
                  categoriesById: categoriesById,
                  accountId: account.id,
                );
              },
            );

            return ListView(
              padding: padding,
              children: <Widget>[
                _AccountPeriodSelector(
                  selected: period,
                  onChanged: (AccountDetailsPeriod value) => ref
                      .read(
                        accountDetailsPeriodControllerProvider(
                          account.id,
                        ).notifier,
                      )
                      .set(value),
                  strings: strings,
                ),
                const SizedBox(height: 16),
                _AccountBalanceChartCard(
                  points: balancePoints,
                  currencyFormat: currencyFormat,
                  strings: strings,
                ),
                const SizedBox(height: 16),
                summarySection,
                const SizedBox(height: 24),
                _AccountTopCategoriesSection(
                  totalsAsync: topCategoriesAsync,
                  categoriesById: categoriesById,
                  currencyFormat: currencyFormat,
                  strings: strings,
                ),
                const SizedBox(height: 24),
                transactionsSection,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openEditScreen(
    BuildContext context,
    AccountEntity account,
  ) async {
    final EditAccountScreenArgs args = EditAccountScreenArgs(account: account);
    final Object? result = await context.push<Object?>(
      args.location,
      extra: args,
    );
    if (!context.mounted) {
      return;
    }
    if (result == AccountEditResult.deleted) {
      Navigator.of(context).pop();
    }
  }
}

class AccountDetailsScreenArgs {
  const AccountDetailsScreenArgs({required this.accountId});

  final String accountId;

  static AccountDetailsScreenArgs fromState(GoRouterState state) {
    final String? accountId = state.uri.queryParameters['accountId'];
    if (accountId == null || accountId.isEmpty) {
      throw GoException('accountId parameter is required');
    }
    return AccountDetailsScreenArgs(accountId: accountId);
  }

  String get location => Uri(
    path: AccountDetailsScreen.routeName,
    queryParameters: <String, String>{'accountId': accountId},
  ).toString();
}

class _AddTransactionButton extends StatelessWidget {
  const _AddTransactionButton({required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AnimatedFab(
      child: KopimGlassFab(
        icon: Icon(Icons.add, color: colorScheme.primary),
        foregroundColor: colorScheme.primary,
        onPressed: () => context.push(
          AddTransactionScreen.routeName,
          extra: TransactionFormArgs(defaultAccountId: accountId),
        ),
      ),
    );
  }
}

class _AccountPeriodSelector extends StatelessWidget {
  const _AccountPeriodSelector({
    required this.selected,
    required this.onChanged,
    required this.strings,
  });

  final AccountDetailsPeriod selected;
  final ValueChanged<AccountDetailsPeriod> onChanged;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return KopimSegmentedControl<AccountDetailsPeriod>(
      options: <KopimSegmentedOption<AccountDetailsPeriod>>[
        KopimSegmentedOption<AccountDetailsPeriod>(
          value: AccountDetailsPeriod.month,
          label: strings.accountDetailsPeriodMonth,
        ),
        KopimSegmentedOption<AccountDetailsPeriod>(
          value: AccountDetailsPeriod.quarter,
          label: strings.accountDetailsPeriodQuarter,
        ),
        KopimSegmentedOption<AccountDetailsPeriod>(
          value: AccountDetailsPeriod.year,
          label: strings.accountDetailsPeriodYear,
        ),
      ],
      selectedValue: selected,
      onChanged: onChanged,
      height: 44,
    );
  }
}

class _AccountBalanceChartCard extends StatelessWidget {
  const _AccountBalanceChartCard({
    required this.points,
    required this.currencyFormat,
    required this.strings,
  });

  final List<_BalanceChartPoint> points;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;
    final _BalanceChartPoint latest = points.last;

    final double minBalance = points
        .map((_BalanceChartPoint point) => point.balance.toDouble())
        .reduce((double a, double b) => a < b ? a : b);
    final double maxBalance = points
        .map((_BalanceChartPoint point) => point.balance.toDouble())
        .reduce((double a, double b) => a > b ? a : b);

    const double chartHeight = 160;
    const double topPadding = 24;
    const double bottomPadding = 12;
    const double availableHeight = chartHeight - topPadding - bottomPadding;

    final double range = maxBalance - minBalance;
    final double effectiveRange = range == 0
        ? (maxBalance == 0 ? 100 : maxBalance * 0.2)
        : range;
    final double axisRange = effectiveRange * chartHeight / availableHeight;
    final double yMax = maxBalance + (topPadding / chartHeight) * axisRange;
    final double yMin = yMax - axisRange;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(layout.radius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.accountDetailsTotalBalanceTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            currencyFormat.format(latest.balance.toDouble()),
            style: theme.textTheme.displaySmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: chartHeight,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
                interval: _resolveAxisInterval(points.length),
              ),
              primaryYAxis: NumericAxis(
                isVisible: false,
                minimum: yMin,
                maximum: yMax,
              ),
              series: <CartesianSeries<_BalanceChartPoint, String>>[
                SplineSeries<_BalanceChartPoint, String>(
                  dataSource: points,
                  xValueMapper: (_BalanceChartPoint point, _) => point.label,
                  yValueMapper: (_BalanceChartPoint point, _) =>
                      point.balance.toDouble(),
                  color: colors.primary,
                  width: 2,
                  animationDuration: 0,
                  markerSettings: const MarkerSettings(isVisible: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPeriodSummaryCard extends StatelessWidget {
  const _AccountPeriodSummaryCard({
    required this.summary,
    required this.currencyFormat,
    required this.strings,
  });

  final AccountTransactionSummary summary;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;

    final String incomeLabel = TransactionTileFormatters.formatAmount(
      formatter: currencyFormat,
      amount: summary.totalIncome,
    );
    final String expenseLabel = TransactionTileFormatters.formatAmount(
      formatter: currencyFormat,
      amount: summary.totalExpense,
    );
    final String netLabel = TransactionTileFormatters.formatAmount(
      formatter: currencyFormat,
      amount: summary.net,
      useAbs: true,
    );
    final bool isNegative = summary.net.minor.isNegative;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(layout.radius.xxl),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryColumn(
                  label: strings.accountDetailsIncomeLabel,
                  value: '+ $incomeLabel',
                  dotColor: colors.primary,
                ),
              ),
              Container(width: 1, height: 48, color: colors.outlineVariant),
              Expanded(
                child: _SummaryColumn(
                  label: strings.accountDetailsExpenseLabel,
                  value: '- $expenseLabel',
                  dotColor: colors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: colors.outlineVariant, height: 16),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${strings.accountDetailsPeriodTotalLabel}: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                '${isNegative ? '-' : '+'} $netLabel',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isNegative ? colors.error : colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.dotColor,
  });

  final String label;
  final String value;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AccountTopCategoriesSection extends StatelessWidget {
  const _AccountTopCategoriesSection({
    required this.totalsAsync,
    required this.categoriesById,
    required this.currencyFormat,
    required this.strings,
  });

  final AsyncValue<List<TransactionCategoryTotals>> totalsAsync;
  final Map<String, Category> categoriesById;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(strings.analyticsTopCategoriesTitle, style: titleStyle),
        const SizedBox(height: 12),
        totalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => _ErrorMessage(
            message: strings.accountDetailsError(error.toString()),
          ),
          data: (List<TransactionCategoryTotals> totals) {
            final List<_TopCategoryItem> items = _resolveTopCategories(
              totals: totals,
              categoriesById: categoriesById,
              strings: strings,
            );
            if (items.isEmpty) {
              return _EmptyMessage(
                message: strings.analyticsTopCategoriesEmpty,
              );
            }

            final MoneyAccumulator totalAccumulator = MoneyAccumulator();
            for (final _TopCategoryItem item in items) {
              totalAccumulator.add(item.amount);
            }
            final double totalAmount = totalAccumulator.toDouble();
            final NumberFormat percentFormat = NumberFormat.percentPattern(
              strings.localeName,
            )..maximumFractionDigits = 0;
            final List<_TopCategoryItem> visibleItems = items.length > 5
                ? items.sublist(0, 5)
                : items;

            return Column(
              children: visibleItems
                  .map((_TopCategoryItem item) {
                    final double share = totalAmount == 0
                        ? 0
                        : item.amount.toDouble() / totalAmount;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _TopCategoryRow(
                        item: item,
                        amountLabel: currencyFormat.format(
                          item.amount.toDouble(),
                        ),
                        percentLabel: percentFormat.format(share),
                        progress: share,
                      ),
                    );
                  })
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _TopCategoryRow extends StatelessWidget {
  const _TopCategoryRow({
    required this.item,
    required this.amountLabel,
    required this.percentLabel,
    required this.progress,
  });

  final _TopCategoryItem item;
  final String amountLabel;
  final String percentLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            _CategoryIconBadge(
              iconData: item.iconData,
              backgroundColor: item.colorStyle.color,
              backgroundGradient: item.colorStyle.backgroundGradient,
              sampleColor: item.colorStyle.sampleColor,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  amountLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  percentLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ProgressBar(progress: progress, colorStyle: item.colorStyle),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.colorStyle});

  final double progress;
  final CategoryColorStyle colorStyle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double clamped = progress.clamp(0, 1);

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clamped == 0 ? 0.02 : clamped,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorStyle.sampleColor ?? colors.primary,
            gradient: colorStyle.backgroundGradient,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _CategoryIconBadge extends StatelessWidget {
  const _CategoryIconBadge({
    this.iconData,
    this.backgroundColor,
    this.backgroundGradient,
    this.sampleColor,
    required this.size,
  });

  final IconData? iconData;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color? sampleColor;
  final double size;

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
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData ?? Icons.category_outlined,
        color: avatarForeground,
        size: 20,
      ),
    );
  }
}

class _AccountTransactionsSection extends StatelessWidget {
  const _AccountTransactionsSection({
    required this.sections,
    required this.strings,
    required this.currency,
    required this.currencyScale,
    required this.categoriesById,
    required this.accountId,
  });

  final List<DaySection> sections;
  final AppLocalizations strings;
  final String currency;
  final int currencyScale;
  final Map<String, Category> categoriesById;
  final String accountId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String currencySymbol = resolveCurrencySymbol(
      currency,
      locale: strings.localeName,
    );
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      strings.localeName,
      currencySymbol,
      decimalDigits: currencyScale,
    );
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime yesterday = DateUtils.dateOnly(
      today.subtract(const Duration(days: 1)),
    );
    final DateFormat headerFormat = TransactionTileFormatters.dayHeader(
      strings.localeName,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.homeTransactionsSection,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _AccountTransactionsFilterBar(accountId: accountId, strings: strings),
        const SizedBox(height: 12),
        for (int i = 0; i < sections.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 20),
          _DayHeader(
            title: _formatSectionTitle(
              date: sections[i].date,
              today: today,
              yesterday: yesterday,
              dateFormat: headerFormat,
              strings: strings,
            ),
            netAmount: _calculateDayNet(sections[i].transactions),
            moneyFormat: moneyFormat,
            currencyScale: currencyScale,
          ),
          const SizedBox(height: 8),
          for (final TransactionEntity transaction in sections[i].transactions)
            AccountTransactionListTile(
              transaction: transaction,
              category: categoriesById[transaction.categoryId],
              currencySymbol: currencySymbol,
              strings: strings,
            ),
        ],
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.title,
    required this.netAmount,
    required this.moneyFormat,
    required this.currencyScale,
  });

  final String title;
  final double netAmount;
  final NumberFormat moneyFormat;
  final int currencyScale;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MoneyAmount amount = resolveMoneyAmount(
      amount: netAmount,
      scale: currencyScale,
      useAbs: false,
    );
    final String formattedAmount = TransactionTileFormatters.formatAmount(
      formatter: moneyFormat,
      amount: amount,
    );
    final String amountLabel = amount.minor.isNegative
        ? '- $formattedAmount'
        : formattedAmount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: SizedBox(
        height: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              amountLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTransactionsFilterBar extends ConsumerWidget {
  const _AccountTransactionsFilterBar({
    required this.accountId,
    required this.strings,
  });

  final String accountId;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AccountTransactionsFilter selected = ref.watch(
      accountTransactionsFilterControllerProvider(accountId),
    );
    return KopimSegmentedControl<TransactionType?>(
      options: <KopimSegmentedOption<TransactionType?>>[
        KopimSegmentedOption<TransactionType?>(
          value: null,
          label: strings.homeTransactionsFilterAll,
        ),
        KopimSegmentedOption<TransactionType?>(
          value: TransactionType.income,
          label: strings.homeTransactionsFilterIncome,
        ),
        KopimSegmentedOption<TransactionType?>(
          value: TransactionType.expense,
          label: strings.homeTransactionsFilterExpense,
        ),
      ],
      selectedValue: selected.type,
      onChanged: (TransactionType? value) => ref
          .read(accountTransactionsFilterControllerProvider(accountId).notifier)
          .setType(value),
      height: 44,
    );
  }
}

String _formatSectionTitle({
  required DateTime date,
  required DateTime today,
  required DateTime yesterday,
  required DateFormat dateFormat,
  required AppLocalizations strings,
}) {
  if (date.isAtSameMomentAs(today)) {
    return strings.homeTransactionsTodayLabel;
  }
  if (date.isAtSameMomentAs(yesterday)) {
    return strings.homeTransactionsYesterdayLabel;
  }
  final String formatted = dateFormat.format(date);
  return toBeginningOfSentenceCase(formatted) ?? formatted;
}

class _BalanceChartPoint {
  const _BalanceChartPoint({
    required this.date,
    required this.balance,
    required this.label,
  });

  final DateTime date;
  final MoneyAmount balance;
  final String label;
}

class _TopCategoryItem {
  const _TopCategoryItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.iconData,
    required this.colorStyle,
  });

  final String id;
  final String title;
  final MoneyAmount amount;
  final IconData? iconData;
  final CategoryColorStyle colorStyle;
}

class _AccountTransactionDelta {
  const _AccountTransactionDelta({required this.date, required this.delta});

  final DateTime date;
  final MoneyAmount delta;
}

List<_BalanceChartPoint> _buildBalanceChartPoints({
  required AccountEntity account,
  required List<TransactionEntity> transactions,
  required AccountDetailsPeriod period,
  required DateTimeRange range,
  required String localeName,
}) {
  final List<DateTime> pointDates = _buildPointDates(period, range);
  if (pointDates.isEmpty) {
    return const <_BalanceChartPoint>[];
  }

  final List<TransactionEntity> sorted =
      List<TransactionEntity>.from(transactions)
        ..sort((TransactionEntity a, TransactionEntity b) {
          return a.date.compareTo(b.date);
        });

  final MoneyAccumulator base = MoneyAccumulator();
  base.add(account.openingBalanceAmount);

  final List<_AccountTransactionDelta> deltas = <_AccountTransactionDelta>[];
  final DateTime endExclusive = range.end.add(const Duration(days: 1));

  for (final TransactionEntity transaction in sorted) {
    final MoneyAmount delta = _resolveTransactionDelta(transaction, account.id);
    if (delta.minor == BigInt.zero) {
      continue;
    }
    if (transaction.date.isBefore(range.start)) {
      base.add(delta);
      continue;
    }
    if (transaction.date.isBefore(endExclusive)) {
      deltas.add(
        _AccountTransactionDelta(date: transaction.date, delta: delta),
      );
    }
  }

  final MoneyAccumulator running = MoneyAccumulator();
  running.add(MoneyAmount(minor: base.minor, scale: base.scale));

  int deltaIndex = 0;
  final List<_BalanceChartPoint> points = <_BalanceChartPoint>[];
  for (final DateTime pointDate in pointDates) {
    final DateTime pointEnd = pointDate.add(const Duration(days: 1));
    while (deltaIndex < deltas.length &&
        deltas[deltaIndex].date.isBefore(pointEnd)) {
      running.add(deltas[deltaIndex].delta);
      deltaIndex += 1;
    }
    points.add(
      _BalanceChartPoint(
        date: pointDate,
        balance: MoneyAmount(minor: running.minor, scale: running.scale),
        label: _formatBalancePointLabel(pointDate, period, localeName),
      ),
    );
  }

  return points;
}

List<DateTime> _buildPointDates(
  AccountDetailsPeriod period,
  DateTimeRange range,
) {
  switch (period) {
    case AccountDetailsPeriod.month:
      return _buildDailyPoints(range.start, range.end);
    case AccountDetailsPeriod.quarter:
    case AccountDetailsPeriod.year:
      return _buildMonthlyPoints(range.start, range.end);
  }
}

List<DateTime> _buildDailyPoints(DateTime start, DateTime end) {
  final List<DateTime> points = <DateTime>[];
  DateTime current = DateTime(start.year, start.month, start.day);
  final DateTime endDate = DateTime(end.year, end.month, end.day);
  while (!current.isAfter(endDate)) {
    points.add(current);
    current = current.add(const Duration(days: 1));
  }
  return points;
}

List<DateTime> _buildMonthlyPoints(DateTime start, DateTime end) {
  final List<DateTime> points = <DateTime>[];
  DateTime current = DateTime(start.year, start.month, 1);
  final DateTime endMonth = DateTime(end.year, end.month, 1);
  while (!current.isAfter(endMonth)) {
    final DateTime monthEnd = DateTime(current.year, current.month + 1, 0);
    points.add(monthEnd.isAfter(end) ? end : monthEnd);
    current = DateTime(current.year, current.month + 1, 1);
  }
  return points;
}

MoneyAmount _resolveTransactionDelta(
  TransactionEntity transaction,
  String accountId,
) {
  final MoneyAmount amount = transaction.amountValue.abs();
  if (transaction.type == TransactionType.income.storageValue) {
    return amount;
  }
  if (transaction.type == TransactionType.expense.storageValue) {
    return MoneyAmount(minor: -amount.minor, scale: amount.scale);
  }
  if (transaction.type == TransactionType.transfer.storageValue) {
    if (transaction.accountId == accountId &&
        transaction.transferAccountId != accountId) {
      return MoneyAmount(minor: -amount.minor, scale: amount.scale);
    }
    if (transaction.transferAccountId == accountId &&
        transaction.accountId != accountId) {
      return amount;
    }
  }
  return MoneyAmount(minor: BigInt.zero, scale: amount.scale);
}

String _formatBalancePointLabel(
  DateTime date,
  AccountDetailsPeriod period,
  String localeName,
) {
  switch (period) {
    case AccountDetailsPeriod.month:
      return DateFormat('d', localeName).format(date);
    case AccountDetailsPeriod.quarter:
    case AccountDetailsPeriod.year:
      return DateFormat('MMM', localeName).format(date);
  }
}

List<_TopCategoryItem> _resolveTopCategories({
  required List<TransactionCategoryTotals> totals,
  required Map<String, Category> categoriesById,
  required AppLocalizations strings,
}) {
  final Map<String, MoneyAccumulator> accumulators =
      <String, MoneyAccumulator>{};

  for (final TransactionCategoryTotals row in totals) {
    final String key = row.rootCategoryId ?? row.categoryId ?? 'uncategorized';
    final MoneyAccumulator acc = accumulators.putIfAbsent(
      key,
      MoneyAccumulator.new,
    );
    acc.add(row.expense);
  }

  final List<_TopCategoryItem> items = <_TopCategoryItem>[];
  for (final MapEntry<String, MoneyAccumulator> entry in accumulators.entries) {
    if (entry.value.minor <= BigInt.zero) {
      continue;
    }
    final String? categoryId = entry.key == 'uncategorized' ? null : entry.key;
    final Category? category = categoryId == null
        ? null
        : categoriesById[categoryId];
    final CategoryColorStyle colorStyle = resolveCategoryColorStyle(
      category?.color,
    );
    items.add(
      _TopCategoryItem(
        id: entry.key,
        title:
            category?.name ?? strings.accountDetailsTransactionsUncategorized,
        amount: MoneyAmount(minor: entry.value.minor, scale: entry.value.scale),
        iconData: resolvePhosphorIconData(category?.icon),
        colorStyle: colorStyle,
      ),
    );
  }

  items.sort(
    (_TopCategoryItem a, _TopCategoryItem b) =>
        b.amount.toDouble().compareTo(a.amount.toDouble()),
  );
  return items;
}

double _resolveAxisInterval(int pointsLength) {
  if (pointsLength <= 8) {
    return 1.0;
  }
  return (pointsLength / 6).ceilToDouble();
}

double _calculateDayNet(List<TransactionEntity> transactions) {
  double income = 0;
  double expense = 0;
  for (final TransactionEntity transaction in transactions) {
    if (transaction.type == TransactionType.income.storageValue) {
      income += transaction.amountValue.abs().toDouble();
    } else if (transaction.type == TransactionType.expense.storageValue) {
      expense += transaction.amountValue.abs().toDouble();
    }
  }
  return income - expense;
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.error,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(message, style: style, textAlign: TextAlign.center),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
