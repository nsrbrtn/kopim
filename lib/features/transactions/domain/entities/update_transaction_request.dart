import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class UpdateTransactionRequest {
  const UpdateTransactionRequest({
    required this.transactionId,
    required this.accountId,
    this.transferAccountId,
    this.categoryId,
    required this.amount,
    required this.date,
    this.note,
    required this.type,
  });

  final String transactionId;
  final String accountId;
  final String? transferAccountId;
  final String? categoryId;
  final MoneyAmount amount;
  final DateTime date;
  final String? note;
  final TransactionType type;

  MoneyAmount get normalizedAmount => amount.abs();
}
