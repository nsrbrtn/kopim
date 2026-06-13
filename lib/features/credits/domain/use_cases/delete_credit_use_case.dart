import 'package:kopim/features/accounts/domain/use_cases/delete_account_use_case.dart';
import 'package:kopim/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';

class DeleteCreditUseCase {
  const DeleteCreditUseCase(
    this._creditRepository,
    this._transactionRepository,
    this._deleteAccountUseCase,
    this._deleteCategoryUseCase,
    this._upcomingPaymentsRepository,
  );

  final CreditRepository _creditRepository;
  final TransactionRepository _transactionRepository;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;
  final UpcomingPaymentsRepository _upcomingPaymentsRepository;

  Future<void> call(CreditEntity credit) async {
    final List<CreditPaymentGroupEntity> paymentGroups = await _creditRepository
        .getPaymentGroups(credit.id);
    for (final CreditPaymentGroupEntity group in paymentGroups) {
      final List<TransactionEntity> transactions = await _transactionRepository
          .findByGroupId(group.id);
      for (final TransactionEntity transaction in transactions) {
        if (transaction.isDeleted) {
          continue;
        }
        await _transactionRepository.softDelete(transaction.id);
      }
    }

    // 1. Помечаем кредит как удаленный
    await _creditRepository.deleteCredit(credit.id);

    // 2. Удаляем связанный счет
    await _deleteAccountUseCase(credit.accountId);

    // 3. Удаляем связанные категории, если они есть
    final Set<String> categoryIds = <String>{
      if (credit.categoryId != null && credit.categoryId!.isNotEmpty)
        credit.categoryId!,
      if (credit.interestCategoryId != null &&
          credit.interestCategoryId!.isNotEmpty)
        credit.interestCategoryId!,
      if (credit.feesCategoryId != null && credit.feesCategoryId!.isNotEmpty)
        credit.feesCategoryId!,
    };
    for (final String categoryId in categoryIds) {
      final UpcomingPayment? upcomingRule = await _upcomingPaymentsRepository
          .getByCategoryId(categoryId);
      if (upcomingRule != null) {
        await _upcomingPaymentsRepository.delete(upcomingRule.id);
      }
      await _deleteCategoryUseCase(categoryId);
    }
  }
}
