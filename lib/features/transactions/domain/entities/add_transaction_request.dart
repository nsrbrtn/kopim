import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class AddTransactionRequest {
  const AddTransactionRequest({
    required this.accountId,
    this.categoryId,
    this.savingGoalId,
    required this.amount,
    required this.date,
    this.note,
    this.type = TransactionType.expense,
  });

  final String accountId;
  final String? categoryId;
  final String? savingGoalId;
  final double amount;
  final DateTime date;
  final String? note;
  final TransactionType type;

  double get normalizedAmount => amount.abs();
}
