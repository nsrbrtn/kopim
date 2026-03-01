import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/utils/annuity_calculator.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:uuid/uuid.dart';

class UpdateCreditUseCase {
  UpdateCreditUseCase({
    required CreditRepository creditRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required SaveCategoryUseCase saveCategoryUseCase,
    DateTime Function()? clock,
    String Function()? idGenerator,
  }) : _creditRepository = creditRepository,
       _accountRepository = accountRepository,
       _categoryRepository = categoryRepository,
       _saveCategoryUseCase = saveCategoryUseCase,
       _clock = clock ?? DateTime.now,
       _idGenerator = idGenerator ?? _defaultIdGenerator;

  final CreditRepository _creditRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  final SaveCategoryUseCase _saveCategoryUseCase;
  final DateTime Function() _clock;
  final String Function() _idGenerator;

  static String _defaultIdGenerator() => const Uuid().v4();

  Future<CreditEntity> call({
    required CreditEntity credit,
    required String name,
    required MoneyAmount totalAmount,
    required double interestRate,
    required int termMonths,
    required int paymentDay,
    String? color,
    String? gradientId,
    String? iconName,
    String? iconStyle,
    bool isHidden = false,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name cannot be empty');
    }
    if (totalAmount.minor <= BigInt.zero) {
      throw ArgumentError.value(
        totalAmount.toDouble(),
        'totalAmount',
        'Total amount must be greater than zero',
      );
    }
    if (interestRate < 0) {
      throw ArgumentError.value(
        interestRate,
        'interestRate',
        'Interest rate cannot be negative',
      );
    }
    if (termMonths <= 0) {
      throw ArgumentError.value(
        termMonths,
        'termMonths',
        'Term must be greater than zero',
      );
    }
    if (paymentDay < 1 || paymentDay > 31) {
      throw ArgumentError.value(
        paymentDay,
        'paymentDay',
        'Payment day must be between 1 and 31',
      );
    }

    final AccountEntity? account = await _accountRepository.findById(
      credit.accountId,
    );
    if (account == null) {
      throw StateError('Account not found for credit ${credit.id}');
    }

    final DateTime now = _clock();
    final int scale =
        account.currencyScale ?? resolveCurrencyScale(account.currency);
    final MoneyAmount resolvedAmount = rescaleMoneyAmount(totalAmount, scale);
    final AccountEntity updatedAccount = account.copyWith(
      name: trimmedName,
      currencyScale: scale,
      color: color,
      gradientId: gradientId,
      iconName: iconName,
      iconStyle: iconStyle,
      isHidden: isHidden,
      updatedAt: now,
    );
    await _accountRepository.upsert(updatedAccount);

    final PhosphorIconDescriptor? resolvedIcon = iconName == null
        ? null
        : PhosphorIconDescriptor(
            name: iconName,
            style: PhosphorIconStyle.values.firstWhere(
              (PhosphorIconStyle style) => style.name == iconStyle,
              orElse: () => PhosphorIconStyle.fill,
            ),
          );
    await _updateCategoryIfExists(
      categoryId: credit.categoryId,
      name: trimmedName,
      color: color,
      now: now,
      icon: resolvedIcon,
      preserveIconWhenNull: false,
    );
    await _updateCategoryIfExists(
      categoryId: credit.interestCategoryId,
      name: '$trimmedName (Проценты)',
      color: color,
      now: now,
    );
    await _updateCategoryIfExists(
      categoryId: credit.feesCategoryId,
      name: '$trimmedName (Комиссии)',
      color: color,
      now: now,
    );

    final CreditEntity updatedCredit = credit.copyWith(
      totalAmountMinor: resolvedAmount.minor,
      totalAmountScale: resolvedAmount.scale,
      interestRate: interestRate,
      termMonths: termMonths,
      paymentDay: paymentDay,
      updatedAt: now,
    );
    await _creditRepository.updateCredit(updatedCredit);
    await _recalculateScheduleIfNeeded(
      previous: credit,
      updated: updatedCredit,
      currency: account.currency,
      scale: scale,
      now: now,
    );

    return updatedCredit;
  }

  Future<void> _recalculateScheduleIfNeeded({
    required CreditEntity previous,
    required CreditEntity updated,
    required String currency,
    required int scale,
    required DateTime now,
  }) async {
    final List<CreditPaymentScheduleEntity> existing = await _creditRepository
        .getSchedule(previous.id);
    if (existing.isEmpty) {
      return;
    }
    final DateTime firstPaymentDate =
        updated.firstPaymentDate ??
        _fallbackFirstPaymentDate(updated.startDate);
    final List<AnnuityPaymentItem> generated =
        AnnuityCalculator.generateSchedule(
          principal: Money.fromMinor(
            updated.totalAmountValue.minor,
            currency: currency,
            scale: scale,
          ),
          annualInterestRatePercent: updated.interestRate,
          termMonths: updated.termMonths,
          firstPaymentDate: firstPaymentDate,
        );
    final Map<String, CreditPaymentScheduleEntity> existingByPeriod =
        <String, CreditPaymentScheduleEntity>{
          for (final CreditPaymentScheduleEntity item in existing)
            item.periodKey: item,
        };

    final List<CreditPaymentScheduleEntity> toInsert =
        <CreditPaymentScheduleEntity>[];
    final Set<String> reusedIds = <String>{};
    final Set<String> usedPeriods = <String>{};
    for (final AnnuityPaymentItem item in generated) {
      final String periodKey = _periodKey(item.date);
      final CreditPaymentScheduleEntity? old = existingByPeriod[periodKey];
      final BigInt principalPaidMinor = old == null
          ? BigInt.zero
          : _clampPaid(old.principalPaid.minor, item.principalAmount.minor);
      final BigInt interestPaidMinor = old == null
          ? BigInt.zero
          : _clampPaid(old.interestPaid.minor, item.interestAmount.minor);
      final CreditPaymentStatus status = _resolveStatus(
        principalPaidMinor: principalPaidMinor,
        interestPaidMinor: interestPaidMinor,
        principalAmountMinor: item.principalAmount.minor,
        interestAmountMinor: item.interestAmount.minor,
      );
      final CreditPaymentScheduleEntity next = CreditPaymentScheduleEntity(
        id: old?.id ?? _idGenerator(),
        creditId: updated.id,
        periodKey: periodKey,
        dueDate: item.date,
        status: status,
        principalAmount: item.principalAmount,
        interestAmount: item.interestAmount,
        totalAmount: item.totalAmount,
        principalPaid: Money.fromMinor(
          principalPaidMinor,
          currency: item.principalAmount.currency,
          scale: item.principalAmount.scale,
        ),
        interestPaid: Money.fromMinor(
          interestPaidMinor,
          currency: item.interestAmount.currency,
          scale: item.interestAmount.scale,
        ),
        paidAt: _resolvePaidAt(
          status: status,
          existingPaidAt: old?.paidAt,
          now: now,
        ),
      );
      usedPeriods.add(periodKey);
      if (old != null) {
        reusedIds.add(old.id);
        await _creditRepository.updateScheduleItem(next);
      } else {
        toInsert.add(next);
      }
    }

    if (toInsert.isNotEmpty) {
      await _creditRepository.addSchedule(toInsert);
    }

    for (final CreditPaymentScheduleEntity item in existing) {
      if (reusedIds.contains(item.id) || usedPeriods.contains(item.periodKey)) {
        continue;
      }
      if (item.status == CreditPaymentStatus.planned) {
        await _creditRepository.updateScheduleItem(
          item.copyWith(status: CreditPaymentStatus.skipped, paidAt: null),
        );
      }
    }
  }

  DateTime _fallbackFirstPaymentDate(DateTime startDate) {
    final DateTime nextMonth = DateTime(startDate.year, startDate.month + 1, 1);
    return nextMonth;
  }

  String _periodKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  BigInt _clampPaid(BigInt paidMinor, BigInt plannedMinor) {
    if (paidMinor <= BigInt.zero) {
      return BigInt.zero;
    }
    if (paidMinor >= plannedMinor) {
      return plannedMinor;
    }
    return paidMinor;
  }

  CreditPaymentStatus _resolveStatus({
    required BigInt principalPaidMinor,
    required BigInt interestPaidMinor,
    required BigInt principalAmountMinor,
    required BigInt interestAmountMinor,
  }) {
    final bool fullyPaid =
        principalPaidMinor >= principalAmountMinor &&
        interestPaidMinor >= interestAmountMinor;
    if (fullyPaid) {
      return CreditPaymentStatus.paid;
    }
    if (principalPaidMinor > BigInt.zero || interestPaidMinor > BigInt.zero) {
      return CreditPaymentStatus.partiallyPaid;
    }
    return CreditPaymentStatus.planned;
  }

  DateTime? _resolvePaidAt({
    required CreditPaymentStatus status,
    required DateTime? existingPaidAt,
    required DateTime now,
  }) {
    switch (status) {
      case CreditPaymentStatus.paid:
        return existingPaidAt ?? now;
      case CreditPaymentStatus.partiallyPaid:
        return existingPaidAt;
      case CreditPaymentStatus.planned:
      case CreditPaymentStatus.skipped:
        return null;
    }
  }

  Future<void> _updateCategoryIfExists({
    required String? categoryId,
    required String name,
    required String? color,
    required DateTime now,
    PhosphorIconDescriptor? icon,
    bool preserveIconWhenNull = true,
  }) async {
    if (categoryId == null || categoryId.isEmpty) {
      return;
    }
    final Category? existingCategory = await _categoryRepository.findById(
      categoryId,
    );
    if (existingCategory == null) {
      return;
    }
    final Category updatedCategory = existingCategory.copyWith(
      name: name,
      color: color,
      icon: preserveIconWhenNull ? (icon ?? existingCategory.icon) : icon,
      updatedAt: now,
    );
    await _saveCategoryUseCase.call(updatedCategory);
  }
}
