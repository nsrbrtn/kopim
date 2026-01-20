import 'package:kopim/core/money/money_utils.dart';
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
    required MoneyAmount amount,
    required DateTime dueDate,
    String? note,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name cannot be empty');
    }
    if (amount.minor <= BigInt.zero) {
      throw ArgumentError.value(
        amount.toDouble(),
        'amount',
        'Amount must be greater than zero',
      );
    }

    final DateTime now = _clock();
    final DebtEntity updatedDebt = debt.copyWith(
      accountId: accountId,
      name: trimmedName,
      amountMinor: amount.minor,
      amountScale: amount.scale,
      dueDate: dueDate,
      note: note?.trim().isNotEmpty ?? false ? note!.trim() : null,
      updatedAt: now,
    );
    await _debtRepository.updateDebt(updatedDebt);
    return updatedDebt;
  }
}
