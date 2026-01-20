import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

Map<String, MoneyAmount> buildTransactionEffect({
  required TransactionEntity transaction,
  required String? creditAccountId,
}) {
  final TransactionType type = parseTransactionType(transaction.type);
  final MoneyAmount amount = transaction.amountValue;
  if (type.isTransfer) {
    final String? targetId = transaction.transferAccountId;
    if (targetId == null || targetId == transaction.accountId) {
      return <String, MoneyAmount>{};
    }
    return <String, MoneyAmount>{
      transaction.accountId: MoneyAmount(
        minor: -amount.minor,
        scale: amount.scale,
      ),
      targetId: amount,
    };
  }

  if (creditAccountId != null) {
    final MoneyAmount repaymentDelta = type.isExpense
        ? amount
        : MoneyAmount(minor: -amount.minor, scale: amount.scale);
    if (transaction.accountId != creditAccountId) {
      final MoneyAmount accountDelta = type.isIncome
          ? amount
          : MoneyAmount(minor: -amount.minor, scale: amount.scale);
      return <String, MoneyAmount>{
        transaction.accountId: accountDelta,
        creditAccountId: repaymentDelta,
      };
    }
    return <String, MoneyAmount>{creditAccountId: repaymentDelta};
  }

  final MoneyAmount delta = type.isIncome
      ? amount
      : MoneyAmount(minor: -amount.minor, scale: amount.scale);
  return <String, MoneyAmount>{transaction.accountId: delta};
}

void applyTransactionEffect(
  Map<String, MoneyAmount> deltas,
  Map<String, MoneyAmount> effect,
) {
  effect.forEach((String accountId, MoneyAmount delta) {
    deltas.update(accountId, (MoneyAmount value) {
      final MoneyAmount normalized =
          rescaleMoneyAmount(delta, value.scale);
      return MoneyAmount(
        minor: value.minor + normalized.minor,
        scale: value.scale,
      );
    }, ifAbsent: () => delta);
  });
}
