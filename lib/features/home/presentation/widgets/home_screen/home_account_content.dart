import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/presentation/controllers/credit_providers.dart';
import 'package:kopim/features/credits/domain/utils/credit_card_calculations.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'home_account_icon_badge.dart';
import 'home_account_balance_text.dart';
import 'home_account_card_palette.dart';

final StreamProvider<List<CreditEntity>> _homeCreditsProvider =
    StreamProvider.autoDispose<List<CreditEntity>>((Ref ref) {
      return ref.watch(watchCreditsUseCaseProvider).call();
    });

final StreamProvider<List<CreditCardEntity>> _homeCreditCardsProvider =
    StreamProvider.autoDispose<List<CreditCardEntity>>((Ref ref) {
      return ref.watch(watchCreditCardsUseCaseProvider).call();
    });

PhosphorIconData? resolveAccountIconData(AccountEntity account) {
  final String? iconName = account.iconName;
  if (iconName == null || iconName.isEmpty) {
    return null;
  }
  final PhosphorIconDescriptor descriptor = PhosphorIconDescriptor(
    name: iconName,
    style: PhosphorIconStyleX.fromName(account.iconStyle),
  );
  return resolvePhosphorIconData(descriptor);
}

String localizedAccountTypeLabel({
  required AppLocalizations strings,
  required String rawType,
}) {
  switch (normalizeAccountType(rawType)) {
    case kAccountTypeCash:
      return strings.addAccountTypeCash;
    case kAccountTypeBank:
      return strings.addAccountTypeBank;
    case kAccountTypeCreditCard:
      return strings.addAccountTypeCreditCard;
    case kAccountTypeInvestment:
      return strings.addAccountTypeInvestment;
    case kAccountTypeSavings:
      return strings.accountTypeOther;
    case kAccountTypeCredit:
      return strings.addAccountTypeCredit;
    case kAccountTypeDebt:
    case kAccountTypeLegacyUnknown:
    case '':
    default:
      return strings.accountTypeOther;
  }
}

class HomeStandardAccountContent extends StatelessWidget {
  const HomeStandardAccountContent({
    super.key,
    required this.account,
    required this.strings,
    required this.currencyFormat,
    required this.summary,
    required this.savingGoal,
    required this.labelStyle,
    required this.balanceStyle,
    required this.summaryTextStyle,
    required this.summaryHeaderStyle,
    required this.accountIcon,
    required this.contentColor,
    required this.palette,
  });

  final AccountEntity account;
  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final HomeAccountMonthlySummary summary;
  final SavingGoal? savingGoal;
  final TextStyle labelStyle;
  final TextStyle balanceStyle;
  final TextStyle summaryTextStyle;
  final TextStyle summaryHeaderStyle;
  final PhosphorIconData? accountIcon;
  final Color contentColor;
  final HomeAccountCardPalette palette;

  @override
  Widget build(BuildContext context) {
    final String accountTypeLabel = localizedAccountTypeLabel(
      strings: strings,
      rawType: account.type,
    );
    final bool isSavings =
        isLegacySavingsAccountType(account.type) && savingGoal != null;
    final double savingsProgress = isSavings
        ? (savingGoal!.targetAmount <= 0
                  ? 0
                  : (savingGoal!.currentAmount / savingGoal!.targetAmount))
              .clamp(0.0, 1.0)
              .toDouble()
        : 0.0;
    final String savingsProgressLabel = isSavings
        ? '${(savingsProgress * 100).toStringAsFixed(0)}%'
        : '';
    final String savingsTargetLabel = isSavings
        ? currencyFormat.format(savingGoal!.targetAmount / 100)
        : '';
    final String monthlyIncomeLabel = strings.homeOverviewIncomeValue(
      currencyFormat.format(summary.income.toDouble()),
    );
    final String monthlyExpenseLabel = strings.homeOverviewExpenseValue(
      currencyFormat.format(summary.expense.toDouble()),
    );
    final TextStyle accountNameStyle = labelStyle.copyWith(
      color: contentColor,
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0.1,
    );
    final TextStyle supportLabelStyle = summaryHeaderStyle.copyWith(
      color: summaryHeaderStyle.color,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (accountIcon != null)
              HomeAccountIconBadge(icon: accountIcon!, color: contentColor),
            if (accountIcon != null) const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    account.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: accountNameStyle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    accountTypeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: supportLabelStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        HomeAccountBalanceText(
          text: currencyFormat.format(account.balanceAmount.toDouble()),
          style: balanceStyle,
        ),
        if (!isSavings) ...<Widget>[
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.homeAccountMonthlySummaryLabel,
                style: supportLabelStyle,
              ),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    monthlyIncomeLabel,
                    style: summaryTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monthlyExpenseLabel,
                    style: summaryTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ],
        if (isSavings) ...<Widget>[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: savingsProgress,
              backgroundColor: contentColor.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation<Color>(contentColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text('Прогресс: $savingsProgressLabel', style: summaryTextStyle),
          const SizedBox(height: 4),
          Text('Цель: $savingsTargetLabel', style: supportLabelStyle),
        ],
      ],
    );
  }
}

class HomeCreditCardAccountContent extends ConsumerWidget {
  const HomeCreditCardAccountContent({
    super.key,
    required this.account,
    required this.strings,
    required this.currencyFormat,
    required this.labelStyle,
    required this.balanceStyle,
    required this.summaryTextStyle,
    required this.summaryHeaderStyle,
    required this.accountIcon,
    required this.contentColor,
    required this.palette,
    required this.fallback,
  });

  final AccountEntity account;
  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final TextStyle labelStyle;
  final TextStyle balanceStyle;
  final TextStyle summaryTextStyle;
  final TextStyle summaryHeaderStyle;
  final PhosphorIconData? accountIcon;
  final Color contentColor;
  final HomeAccountCardPalette palette;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CreditCardEntity? creditCard = ref
        .watch(_homeCreditCardsProvider)
        .asData
        ?.value
        .firstWhereOrNull(
          (CreditCardEntity item) => item.accountId == account.id,
        );
    if (creditCard == null) {
      return fallback;
    }

    final MoneyAmount availableLimit = calculateCreditCardAvailableLimit(
      creditLimit: creditCard.creditLimitValue,
      balance: account.balanceAmount,
    );
    final MoneyAmount debt = calculateCreditCardDebt(account.balanceAmount);
    final String accountTypeLabel = localizedAccountTypeLabel(
      strings: strings,
      rawType: account.type,
    );
    final TextStyle debtStyle = summaryTextStyle.copyWith(
      color: summaryTextStyle.color,
      fontWeight: FontWeight.w500,
    );
    final TextStyle limitLabelStyle = summaryHeaderStyle.copyWith(
      color: summaryHeaderStyle.color,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (accountIcon != null)
              HomeAccountIconBadge(icon: accountIcon!, color: contentColor),
            if (accountIcon != null) const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    account.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    accountTypeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: summaryHeaderStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(strings.creditCardAvailableLimitLabel, style: limitLabelStyle),
        const SizedBox(height: 4),
        HomeAccountBalanceText(
          text: currencyFormat.format(availableLimit.toDouble()),
          style: balanceStyle,
        ),
        const SizedBox(height: 10),
        Text(strings.creditCardSpentLabel, style: limitLabelStyle),
        const SizedBox(height: 4),
        Text(currencyFormat.format(debt.toDouble()), style: debtStyle),
      ],
    );
  }
}

class HomeCreditCardContent extends ConsumerWidget {
  const HomeCreditCardContent({
    super.key,
    required this.account,
    required this.strings,
    required this.currencyFormat,
    required this.palette,
    required this.labelStyle,
    required this.balanceStyle,
    required this.summaryTextStyle,
    required this.summaryHeaderStyle,
    required this.accountIcon,
    required this.contentColor,
    required this.fallback,
  });

  final AccountEntity account;
  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final HomeAccountCardPalette palette;
  final TextStyle labelStyle;
  final TextStyle balanceStyle;
  final TextStyle summaryTextStyle;
  final TextStyle summaryHeaderStyle;
  final PhosphorIconData? accountIcon;
  final Color contentColor;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CreditEntity? credit = ref
        .watch(_homeCreditsProvider)
        .asData
        ?.value
        .firstWhereOrNull((CreditEntity item) => item.accountId == account.id);

    if (credit == null) {
      return fallback;
    }

    final List<CreditPaymentScheduleEntity> schedule =
        ref.watch(creditScheduleProvider(credit.id)).asData?.value ??
        const <CreditPaymentScheduleEntity>[];
    final String accountTypeLabel = localizedAccountTypeLabel(
      strings: strings,
      rawType: account.type,
    );
    final DateTime nextPaymentDate = _calculateNextPaymentDate(
      credit,
      schedule,
    );
    final int remainingPayments = _calculateRemainingPayments(
      credit: credit,
      schedule: schedule,
    );
    final double progress =
        (credit.totalAmountValue.toDouble() + account.balanceAmount.toDouble())
            .abs() /
        credit.totalAmountValue.toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (accountIcon != null)
                    HomeAccountIconBadge(
                      icon: accountIcon!,
                      color: contentColor,
                    ),
                  if (accountIcon != null) const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          account.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          accountTypeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: summaryHeaderStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        HomeAccountBalanceText(
          text: currencyFormat.format(account.balanceAmount.toDouble().abs()),
          style: balanceStyle,
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: contentColor.withValues(alpha: 0.16),
            valueColor: AlwaysStoppedAnimation<Color>(contentColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.creditsNextPaymentLabel,
                  style: summaryHeaderStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMd(strings.localeName).format(nextPaymentDate),
                  style: summaryTextStyle,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  strings.creditsRemainingPaymentsLabel,
                  style: summaryHeaderStyle,
                ),
                const SizedBox(height: 4),
                Text('$remainingPayments', style: summaryTextStyle),
              ],
            ),
          ],
        ),
      ],
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
    final int paidPayments = schedule
        .where((CreditPaymentScheduleEntity item) => item.status.isPaid)
        .length;
    final int remaining = credit.termMonths - paidPayments;
    return remaining > 0 ? remaining : 0;
  }
}
