import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:uuid/uuid.dart';

class AddCreditUseCase {
  AddCreditUseCase({
    required CreditRepository creditRepository,
    required AccountRepository accountRepository,
    required SaveCategoryUseCase saveCategoryUseCase,
    required Uuid uuid,
  }) : _creditRepository = creditRepository,
       _accountRepository = accountRepository,
       _saveCategoryUseCase = saveCategoryUseCase,
       _uuid = uuid;

  final CreditRepository _creditRepository;
  final AccountRepository _accountRepository;
  final SaveCategoryUseCase _saveCategoryUseCase;
  final Uuid _uuid;

  Future<CreditEntity> call({
    required String name,
    required double totalAmount,
    required String currency,
    required double interestRate,
    required int termMonths,
    required DateTime startDate,
    String? color,
    String? iconName,
    String? iconStyle,
    int paymentDay = 1,
    bool isHidden = false,
  }) async {
    final String creditId = _uuid.v4();
    final String accountId = _uuid.v4();
    final String categoryId = _uuid.v4();
    final DateTime now = DateTime.now();

    // 1. Создаем уникальную категорию для кредита
    final Category category = Category(
      id: categoryId,
      name: 'Кредит: $name',
      type: 'expense',
      icon: iconName != null
          ? PhosphorIconDescriptor(
              name: iconName,
              style: PhosphorIconStyle.values.firstWhere(
                (PhosphorIconStyle style) => style.name == iconStyle,
                orElse: () => PhosphorIconStyle.fill,
              ),
            )
          : null,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
    await _saveCategoryUseCase.call(category);

    final AccountEntity account = AccountEntity(
      id: accountId,
      name: name,
      balance: -totalAmount, // Баланс кредита отрицательный
      currency: currency,
      type: 'credit',
      color: color,
      iconName: iconName,
      iconStyle: iconStyle,
      isHidden: isHidden,
      createdAt: now,
      updatedAt: now,
    );

    final CreditEntity credit = CreditEntity(
      id: creditId,
      accountId: accountId,
      categoryId: categoryId,
      totalAmount: totalAmount,
      interestRate: interestRate,
      termMonths: termMonths,
      startDate: startDate,
      paymentDay: paymentDay,
      createdAt: now,
      updatedAt: now,
    );

    await _accountRepository.upsert(account);
    await _creditRepository.addCredit(credit);

    return credit;
  }
}
