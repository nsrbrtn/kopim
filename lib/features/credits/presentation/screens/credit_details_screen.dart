import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/kopim_segmented_control.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_details_providers.dart';
import 'package:kopim/features/accounts/presentation/widgets/account_transaction_list_tile.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/presentation/controllers/credit_providers.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/credits/presentation/widgets/pay_credit_sheet.dart';
import 'package:kopim/features/transactions/domain/models/feed_item.dart';
import 'package:kopim/features/home/domain/use_cases/group_transactions_by_day_use_case.dart';
import 'package:kopim/features/credits/presentation/widgets/grouped_credit_payment_tile.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/credits/domain/utils/credit_calculations.dart';
import 'package:kopim/l10n/app_localizations.dart';

enum _CreditHistoryFilter { all, payments, interest }

class CreditDetailsScreen extends ConsumerStatefulWidget {
  const CreditDetailsScreen({required this.credit, super.key});

  static const String routeName = '/credits/details';

  final CreditEntity credit;

  @override
  ConsumerState<CreditDetailsScreen> createState() =>
      _CreditDetailsScreenState();
}

class _CreditDetailsScreenState extends ConsumerState<CreditDetailsScreen> {
  _CreditHistoryFilter _selectedFilter = _CreditHistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = context.loc;
    final AsyncValue<AccountEntity?> accountAsync = ref.watch(
      accountDetailsProvider(widget.credit.accountId),
    );
    final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
      accountTransactionsProvider(widget.credit.accountId),
    );
    final AsyncValue<List<CreditPaymentScheduleEntity>> scheduleAsync = ref
        .watch(creditScheduleProvider(widget.credit.id));
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      accountCategoriesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: accountAsync.maybeWhen(
          data: (AccountEntity? account) =>
              Text(account?.name ?? strings.creditsTitle),
          orElse: () => Text(strings.creditsTitle),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: strings.creditsEditTitle,
            onPressed: () =>
                context.push('/credits/edit', extra: widget.credit),
          ),
        ],
      ),
      body: SafeArea(
        child: accountAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => Center(
            child: Text(
              strings.accountDetailsError(error.toString()),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          data: (AccountEntity? account) {
            if (account == null) {
              return Center(
                child: Text(
                  strings.accountDetailsMissing,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              );
            }

            final int decimalDigits =
                widget.credit.totalAmountScale ?? account.currencyScale ?? 2;
            final NumberFormat moneyFormat = NumberFormat.currency(
              locale: strings.localeName,
              symbol: getCurrencySymbol(account.currency),
              decimalDigits: decimalDigits,
            );
            final NumberFormat shortMoneyFormat = NumberFormat.currency(
              locale: strings.localeName,
              symbol: resolveCurrencySymbol(
                account.currency,
                locale: strings.localeName,
              ),
              decimalDigits: decimalDigits,
            );

            final double totalDebtValue = widget.credit.totalAmountValue
                .abs()
                .toDouble();
            final double remainingDebtValue = account.balanceAmount
                .abs()
                .toDouble();
            final double repaidAmount = (totalDebtValue - remainingDebtValue)
                .clamp(0.0, totalDebtValue);
            final double progress = totalDebtValue > 0
                ? (repaidAmount / totalDebtValue)
                : 0.0;
            final List<CreditPaymentScheduleEntity> schedule =
                scheduleAsync.asData?.value ??
                const <CreditPaymentScheduleEntity>[];
            final DateTime nextPaymentDate = _calculateNextPaymentDate(
              widget.credit,
              schedule,
            );
            final int daysUntilPayment = math.max(
              0,
              nextPaymentDate.difference(DateTime.now()).inDays,
            );
            final double monthlyPayment = calculateAnnuityMonthlyPayment(
              principal: totalDebtValue,
              annualInterestRate: widget.credit.interestRate,
              termMonths: widget.credit.termMonths,
            );

            final List<Category> categories =
                categoriesAsync.asData?.value ?? const <Category>[];
            final Map<String, Category> categoriesById = <String, Category>{
              for (final Category category in categories) category.id: category,
            };
            final int paidPayments = _countPaidScheduleItems(schedule);
            final int remainingPayments = _calculateRemainingPayments(
              credit: widget.credit,
              schedule: schedule,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: <Widget>[
                _InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        strings.creditsRemainingAmount,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        moneyFormat.format(remainingDebtValue),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _SummaryColumn(
                            title: strings.creditsAmountLabel,
                            value: moneyFormat.format(totalDebtValue),
                          ),
                          _SummaryColumn(
                            title: strings.creditsRemainingPaymentsLabel,
                            value: '$remainingPayments',
                            valueColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            strings.creditsNextPaymentLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          _Badge(
                            label: strings.creditDetailsNextPaymentInDays(
                              daysUntilPayment,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                shortMoneyFormat.format(monthlyPayment),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                strings.creditDetailsDueDate(
                                  DateFormat.yMMMMd(
                                    strings.localeName,
                                  ).format(nextPaymentDate),
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          _UpcomingPaymentActionButton(credit: widget.credit),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  strings.creditDetailsScheduleTitle,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  strings.creditDetailsScheduleRemaining(
                                    remainingPayments,
                                    widget.credit.termMonths,
                                  ),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _PaymentProgress(
                              progress: widget.credit.termMonths == 0
                                  ? 0.0
                                  : paidPayments / widget.credit.termMonths,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            strings.creditDetailsHistoryTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/transactions/all'),
                            child: Text(strings.homeTransactionsFilterAll),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      KopimSegmentedControl<_CreditHistoryFilter>(
                        options: <KopimSegmentedOption<_CreditHistoryFilter>>[
                          KopimSegmentedOption<_CreditHistoryFilter>(
                            value: _CreditHistoryFilter.all,
                            label: strings.homeTransactionsFilterAll,
                          ),
                          KopimSegmentedOption<_CreditHistoryFilter>(
                            value: _CreditHistoryFilter.payments,
                            label:
                                strings.homeUpcomingPaymentsBadgePaymentsLabel,
                          ),
                          KopimSegmentedOption<_CreditHistoryFilter>(
                            value: _CreditHistoryFilter.interest,
                            label: strings.creditDetailsInterestLabel,
                          ),
                        ],
                        selectedValue: _selectedFilter,
                        onChanged: (_CreditHistoryFilter value) {
                          setState(() => _selectedFilter = value);
                        },
                        height: 44,
                      ),
                      const SizedBox(height: 16),
                      transactionsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (Object error, _) => Text(
                          strings.accountDetailsError(error.toString()),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        data: (List<TransactionEntity> transactions) {
                          final List<TransactionEntity> filtered =
                              _applyHistoryFilter(transactions, categoriesById);
                          if (filtered.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                strings.accountDetailsTransactionsEmpty,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }

                          final GroupTransactionsByDayUseCase groupUseCase = ref
                              .watch(groupTransactionsByDayUseCaseProvider);
                          final List<DaySection> sections = groupUseCase(
                            transactions: filtered,
                          );

                          return Column(
                            children: sections
                                .map(
                                  (DaySection section) => _DaySectionView(
                                    section: section,
                                    currencySymbol: resolveCurrencySymbol(
                                      account.currency,
                                      locale: strings.localeName,
                                    ),
                                    categoriesById: categoriesById,
                                    strings: strings,
                                  ),
                                )
                                .toList(growable: false),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  DateTime _calculateNextPaymentDate(
    CreditEntity credit,
    List<CreditPaymentScheduleEntity> schedule,
  ) {
    final List<CreditPaymentScheduleEntity> upcoming = schedule
        .where(
          (CreditPaymentScheduleEntity item) =>
              item.status == CreditPaymentStatus.planned ||
              item.status == CreditPaymentStatus.partiallyPaid,
        )
        .toList(growable: false);
    if (upcoming.isNotEmpty) {
      upcoming.sort(
        (CreditPaymentScheduleEntity a, CreditPaymentScheduleEntity b) =>
            a.dueDate.compareTo(b.dueDate),
      );
      return DateUtils.dateOnly(upcoming.first.dueDate);
    }

    final DateTime now = DateUtils.dateOnly(DateTime.now());
    final int paymentDay = credit.paymentDay;

    final int currentMaxDay = DateUtils.getDaysInMonth(now.year, now.month);
    final int currentDay = paymentDay.clamp(1, currentMaxDay);
    final DateTime currentCandidate = DateTime(now.year, now.month, currentDay);
    if (!currentCandidate.isBefore(now)) {
      return currentCandidate;
    }

    final DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    final int nextMaxDay = DateUtils.getDaysInMonth(
      nextMonth.year,
      nextMonth.month,
    );
    final int nextDay = paymentDay.clamp(1, nextMaxDay);
    return DateTime(nextMonth.year, nextMonth.month, nextDay);
  }

  int _calculateRemainingPayments({
    required CreditEntity credit,
    required List<CreditPaymentScheduleEntity> schedule,
  }) {
    if (schedule.isNotEmpty) {
      return schedule
          .where((CreditPaymentScheduleEntity item) => !item.status.isPaid)
          .length;
    }
    final int paidPayments = _countPaidScheduleItems(schedule);
    final int remaining = credit.termMonths - paidPayments;
    return remaining > 0 ? remaining : 0;
  }

  int _countPaidScheduleItems(List<CreditPaymentScheduleEntity> schedule) {
    return schedule
        .where((CreditPaymentScheduleEntity item) => item.status.isPaid)
        .length;
  }

  List<TransactionEntity> _applyHistoryFilter(
    List<TransactionEntity> transactions,
    Map<String, Category> categoriesById,
  ) {
    if (_selectedFilter == _CreditHistoryFilter.all) {
      return transactions;
    }
    return transactions
        .where((TransactionEntity transaction) {
          final String categoryName =
              categoriesById[transaction.categoryId]?.name ?? '';
          final String note = transaction.note ?? '';
          final String haystack = '$categoryName $note'.toLowerCase();
          final bool isInterest =
              haystack.contains('процент') || haystack.contains('interest');

          if (_selectedFilter == _CreditHistoryFilter.interest) {
            return isInterest;
          }
          if (_selectedFilter == _CreditHistoryFilter.payments) {
            return transaction.type == TransactionType.expense.storageValue &&
                !isInterest;
          }
          return true;
        })
        .toList(growable: false);
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.title,
    required this.value,
    this.valueColor,
  });

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PaymentProgress extends StatelessWidget {
  const _PaymentProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
      ),
    );
  }
}

class _UpcomingPaymentActionButton extends ConsumerWidget {
  const _UpcomingPaymentActionButton({required this.credit});
  final CreditEntity credit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CreditPaymentScheduleEntity?> nextAsync = ref.watch(
      nextUpcomingPaymentProvider(credit.id),
    );
    final AppLocalizations strings = context.loc;

    return nextAsync.when(
      data: (CreditPaymentScheduleEntity? item) => FilledButton(
        onPressed: () =>
            PayCreditSheet.show(context, credit: credit, scheduleItem: item),
        child: Text(strings.creditDetailsPayAction),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object _, StackTrace _) => FilledButton(
        onPressed: () => PayCreditSheet.show(context, credit: credit),
        child: Text(strings.creditDetailsPayAction),
      ),
    );
  }
}

class _DaySectionView extends StatelessWidget {
  const _DaySectionView({
    required this.section,
    required this.currencySymbol,
    required this.categoriesById,
    required this.strings,
  });

  final DaySection section;
  final String currencySymbol;
  final Map<String, Category> categoriesById;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    String label;
    if (DateUtils.isSameDay(section.date, today)) {
      label = strings.homeTransactionsTodayLabel;
    } else if (DateUtils.isSameDay(section.date, yesterday)) {
      label = strings.homeTransactionsYesterdayLabel;
    } else {
      label = DateFormat.yMMMMd(strings.localeName).format(section.date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        for (final FeedItem item in section.items)
          item.when(
            transaction: (TransactionEntity transaction) =>
                AccountTransactionListTile(
                  transaction: transaction,
                  category: categoriesById[transaction.categoryId],
                  currencySymbol: currencySymbol,
                  strings: strings,
                ),
            groupedCreditPayment:
                (
                  String groupId,
                  String creditId,
                  List<TransactionEntity> transactions,
                  Money totalOutflow,
                  DateTime date,
                  String? note,
                ) => GroupedCreditPaymentTile(
                  group: GroupedCreditPaymentFeedItem(
                    groupId: groupId,
                    creditId: creditId,
                    transactions: transactions,
                    totalOutflow: totalOutflow,
                    date: date,
                    note: note,
                  ),
                  currencySymbol: currencySymbol,
                  strings: strings,
                ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
