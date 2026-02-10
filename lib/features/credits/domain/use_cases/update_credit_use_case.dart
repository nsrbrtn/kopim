import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';

class UpdateCreditUseCase {
  UpdateCreditUseCase({
    required CreditRepository creditRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required SaveCategoryUseCase saveCategoryUseCase,
    DateTime Function()? clock,
  }) : _creditRepository = creditRepository,
       _accountRepository = accountRepository,
       _categoryRepository = categoryRepository,
       _saveCategoryUseCase = saveCategoryUseCase,
       _clock = clock ?? DateTime.now;

  final CreditRepository _creditRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  final SaveCategoryUseCase _saveCategoryUseCase;
  final DateTime Function() _clock;

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

    return updatedCredit;
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
