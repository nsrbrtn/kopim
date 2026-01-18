import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

Map<String, double> buildTransactionEffect({
  required TransactionEntity transaction,
  required String? creditAccountId,
}) {
  final TransactionType type = parseTransactionType(transaction.type);
  if (type.isTransfer) {
    final String? targetId = transaction.transferAccountId;
    if (targetId == null || targetId == transaction.accountId) {
      return <String, double>{};
    }
    return <String, double>{
      transaction.accountId: -transaction.amount,
      targetId: transaction.amount,
    };
  }

  if (creditAccountId != null) {
    final double repaymentDelta =
        type.isExpense ? transaction.amount : -transaction.amount;
    if (transaction.accountId != creditAccountId) {
      final double accountDelta =
          type.isIncome ? transaction.amount : -transaction.amount;
      return <String, double>{
        transaction.accountId: accountDelta,
        creditAccountId: repaymentDelta,
      };
    }
    return <String, double>{creditAccountId: repaymentDelta};
  }

  final double delta = type.isIncome
      ? transaction.amount
      : -transaction.amount;
  return <String, double>{transaction.accountId: delta};
}

void applyTransactionEffect(
  Map<String, double> deltas,
  Map<String, double> effect,
) {
  effect.forEach((String accountId, double delta) {
    deltas.update(
      accountId,
      (double value) => value + delta,
      ifAbsent: () => delta,
    );
  });
}
