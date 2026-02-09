import 'package:kopim/features/accounts/domain/use_cases/delete_account_use_case.dart';
import 'package:kopim/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';

class DeleteCreditUseCase {
  const DeleteCreditUseCase(
    this._creditRepository,
    this._deleteAccountUseCase,
    this._deleteCategoryUseCase,
  );

  final CreditRepository _creditRepository;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  Future<void> call(CreditEntity credit) async {
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
      await _deleteCategoryUseCase(categoryId);
    }
  }
}
