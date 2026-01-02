import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
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
    required double totalAmount,
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
    if (totalAmount <= 0) {
      throw ArgumentError.value(
        totalAmount,
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
    final AccountEntity updatedAccount = account.copyWith(
      name: trimmedName,
      balance: -totalAmount,
      color: color,
      gradientId: gradientId,
      iconName: iconName,
      iconStyle: iconStyle,
      isHidden: isHidden,
      updatedAt: now,
    );
    await _accountRepository.upsert(updatedAccount);

    final String? categoryId = credit.categoryId;
    if (categoryId != null && categoryId.isNotEmpty) {
      final Category? existingCategory = await _categoryRepository.findById(
        categoryId,
      );
      if (existingCategory != null) {
        final Category updatedCategory = existingCategory.copyWith(
          name: 'Кредит: $trimmedName',
          color: color,
          icon:
              iconName == null
                  ? null
                  : PhosphorIconDescriptor(
                      name: iconName,
                      style: PhosphorIconStyle.values.firstWhere(
                        (PhosphorIconStyle style) => style.name == iconStyle,
                        orElse: () => PhosphorIconStyle.fill,
                      ),
                    ),
          updatedAt: now,
        );
        await _saveCategoryUseCase.call(updatedCategory);
      }
    }

    final CreditEntity updatedCredit = credit.copyWith(
      totalAmount: totalAmount,
      interestRate: interestRate,
      termMonths: termMonths,
      paymentDay: paymentDay,
      updatedAt: now,
    );
    await _creditRepository.updateCredit(updatedCredit);

    return updatedCredit;
  }
}
