import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/domain/repositories/debt_repository.dart';

class UpdateDebtUseCase {
  UpdateDebtUseCase({
    required DebtRepository debtRepository,
    DateTime Function()? clock,
  }) : _debtRepository = debtRepository,
       _clock = clock ?? DateTime.now;

  final DebtRepository _debtRepository;
  final DateTime Function() _clock;

  Future<DebtEntity> call({
    required DebtEntity debt,
    required String accountId,
    required String name,
    required double amount,
    required DateTime dueDate,
    String? note,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name cannot be empty');
    }
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Amount must be greater than zero',
      );
    }

    final DateTime now = _clock();
    final DebtEntity updatedDebt = debt.copyWith(
      accountId: accountId,
      name: trimmedName,
      amount: amount,
      dueDate: dueDate,
      note: note?.trim().isNotEmpty ?? false ? note!.trim() : null,
      updatedAt: now,
    );
    await _debtRepository.updateDebt(updatedDebt);
    return updatedDebt;
  }
}
