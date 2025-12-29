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

    // 3. Удаляем связанную категорию, если она есть
    if (credit.categoryId != null) {
      await _deleteCategoryUseCase(credit.categoryId!);
    }
  }
}
