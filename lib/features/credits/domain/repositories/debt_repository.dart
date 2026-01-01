import 'package:kopim/features/credits/domain/entities/debt_entity.dart';

abstract class DebtRepository {
  Future<List<DebtEntity>> getDebts();
  Stream<List<DebtEntity>> watchDebts();
  Future<void> addDebt(DebtEntity debt);
  Future<void> updateDebt(DebtEntity debt);
  Future<void> deleteDebt(String id);
}
