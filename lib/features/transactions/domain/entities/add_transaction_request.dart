import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class AddTransactionRequest {
  const AddTransactionRequest({
    required this.accountId,
    this.transferAccountId,
    this.categoryId,
    this.savingGoalId,
    required this.amount,
    this.amountMinor,
    this.amountScale,
    required this.date,
    this.note,
    this.type = TransactionType.expense,
  });

  final String accountId;
  final String? transferAccountId;
  final String? categoryId;
  final String? savingGoalId;
  final double amount;
  final BigInt? amountMinor;
  final int? amountScale;
  final DateTime date;
  final String? note;
  final TransactionType type;

  double get normalizedAmount => amount.abs();
}
