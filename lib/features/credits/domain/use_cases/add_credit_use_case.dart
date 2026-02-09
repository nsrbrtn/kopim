import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/utils/annuity_calculator.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class AddCreditUseCase {
  AddCreditUseCase({
    required CreditRepository creditRepository,
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
    required SaveCategoryUseCase saveCategoryUseCase,
    required Uuid uuid,
  }) : _creditRepository = creditRepository,
       _accountRepository = accountRepository,
       _transactionRepository = transactionRepository,
       _saveCategoryUseCase = saveCategoryUseCase,
       _uuid = uuid;

  final CreditRepository _creditRepository;
  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;
  final SaveCategoryUseCase _saveCategoryUseCase;
  final Uuid _uuid;

  Future<CreditEntity> call({
    required String name,
    required MoneyAmount totalAmount, // Principal debt
    required String currency,
    required double interestRate,
    required int termMonths,
    required DateTime startDate,
    required DateTime firstPaymentDate,
    String? targetAccountId, // Where the money goes
    bool isAlreadyIssued = false,
    String? color,
    String? gradientId,
    String? iconName,
    String? iconStyle,
    int paymentDay = 1,
    bool isHidden = false,
  }) async {
    final String creditId = _uuid.v4();
    final String accountId = _uuid.v4();
    final String categoryId = _uuid.v4();
    final String interestCategoryId = _uuid.v4();
    final String feesCategoryId = _uuid.v4();
    final DateTime now = DateTime.now();
    final int scale = resolveCurrencyScale(currency);
    final MoneyAmount resolvedAmount = rescaleMoneyAmount(totalAmount, scale);

    // 1. Создаем основные категории (Main, Interest, Fees)
    final List<Category> categoriesToCreate = <Category>[
      Category(
        id: categoryId,
        name: name,
        type: 'expense',
        color: color,
        isSystem: true,
        isHidden: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: interestCategoryId,
        name: '$name (Interest)',
        type: 'expense',
        color: color,
        isSystem: true,
        isHidden: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: feesCategoryId,
        name: '$name (Fees)',
        type: 'expense',
        color: color,
        isSystem: true,
        isHidden: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final Category cat in categoriesToCreate) {
      await _saveCategoryUseCase.call(cat);
    }

    // 2. Создаем кредитный счет (Баланс 0 на старте согласно Zero Basis)
    final bool issueWithoutAccount =
        isAlreadyIssued && targetAccountId == null;
    final BigInt openingMinor = issueWithoutAccount
        ? -resolvedAmount.minor
        : BigInt.zero;
    final AccountEntity creditAccount = AccountEntity(
      id: accountId,
      name: name,
      balanceMinor: openingMinor,
      openingBalanceMinor: openingMinor,
      currency: currency,
      currencyScale: scale,
      type: 'credit',
      color: color,
      gradientId: gradientId,
      iconName: iconName,
      iconStyle: iconStyle,
      isHidden: isHidden,
      createdAt: now,
      updatedAt: now,
    );
    await _accountRepository.upsert(creditAccount);

    // 3. Создаем запись о кредите
    final CreditEntity credit = CreditEntity(
      id: creditId,
      accountId: accountId,
      categoryId: categoryId,
      interestCategoryId: interestCategoryId,
      feesCategoryId: feesCategoryId,
      totalAmountMinor: resolvedAmount.minor,
      totalAmountScale: resolvedAmount.scale,
      interestRate: interestRate,
      termMonths: termMonths,
      startDate: startDate,
      firstPaymentDate: firstPaymentDate,
      paymentDay: paymentDay,
      createdAt: now,
      updatedAt: now,
    );
    await _creditRepository.addCredit(credit);

    // 4. Генерируем график платежей
    final List<AnnuityPaymentItem> scheduleItems =
        AnnuityCalculator.generateSchedule(
          principal: Money.fromMinor(
            resolvedAmount.minor,
            currency: currency,
            scale: scale,
          ),
          annualInterestRatePercent: interestRate,
          termMonths: termMonths,
          firstPaymentDate: firstPaymentDate,
        );

    final List<CreditPaymentScheduleEntity> scheduleEntities =
        scheduleItems.map((AnnuityPaymentItem item) {
      return CreditPaymentScheduleEntity(
        id: _uuid.v4(),
        creditId: creditId,
        periodKey:
            '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}',
        dueDate: item.date,
        status: CreditPaymentStatus.planned,
        principalAmount: item.principalAmount,
        interestAmount: item.interestAmount,
        totalAmount: item.totalAmount,
        principalPaid: Money.fromMinor(
          BigInt.zero,
          currency: currency,
          scale: scale,
        ),
        interestPaid: Money.fromMinor(
          BigInt.zero,
          currency: currency,
          scale: scale,
        ),
      );
    }).toList(growable: false);

    await _creditRepository.addSchedule(scheduleEntities);

    // 5. Регистрируем выдачу кредита (Перевод с кредитного счета на целевой)
    if (targetAccountId != null) {
      final String txId = _uuid.v4();
      final TransactionEntity disbursementTx = TransactionEntity(
        id: txId,
        accountId: accountId, // Откуда (с минусом в баланс кредитного счета)
        transferAccountId:
            targetAccountId, // Куда (плюс в баланс целевого счета)
        categoryId: categoryId,
        amountMinor: resolvedAmount.minor,
        amountScale: scale,
        date: startDate,
        type: TransactionType.transfer.storageValue,
        note: 'Выдача кредита: $name',
        createdAt: now,
        updatedAt: now,
      );
      await _transactionRepository.upsert(disbursementTx);
    }

    return credit;
  }
}
