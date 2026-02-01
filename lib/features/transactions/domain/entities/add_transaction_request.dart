import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class AddTransactionRequest {
  const AddTransactionRequest({
    required this.accountId,
    this.transferAccountId,
    this.categoryId,
    this.savingGoalId,
    this.idempotencyKey,
    required this.amount,
    required this.date,
    this.note,
    this.type = TransactionType.expense,
  });

  final String accountId;
  final String? transferAccountId;
  final String? categoryId;
  final String? savingGoalId;
  final String? idempotencyKey;
  final MoneyAmount amount;
  final DateTime date;
  final String? note;
  final TransactionType type;

  MoneyAmount get normalizedAmount => amount.abs();
}
