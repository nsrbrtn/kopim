import 'package:kopim/core/money/money.dart';

class UpdateCreditPaymentUseCase {
  UpdateCreditPaymentUseCase();

  Future<void> call({
    required String groupId,
    required Money principalPaid,
    required Money interestPaid,
    required Money feesPaid,
    required Money totalOutflow,
    String? note,
  }) async {
    // TODO(credits-audit): Либо реализовать, либо удалить мертвый код.
    // TODO(credits-audit): 1) Найти payment group по groupId.
    // TODO(credits-audit): 2) Провалидировать суммы:
    // - totalOutflow = principal + interest + fees
    // - суммы неотрицательные
    // - единый currency/scale
    // TODO(credits-audit): 3) В одной транзакции обновить:
    // - payment group
    // - связанные transaction rows (principal/interest/fees)
    // - schedule item (если есть связь с периодом).
    // TODO(credits-audit): 4) Добавить unit/integration тесты сценариев редактирования.
  }
}
