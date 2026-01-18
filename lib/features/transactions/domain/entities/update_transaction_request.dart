import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class UpdateTransactionRequest {
  const UpdateTransactionRequest({
    required this.transactionId,
    required this.accountId,
    this.transferAccountId,
    this.categoryId,
    required this.amount,
    this.amountMinor,
    this.amountScale,
    required this.date,
    this.note,
    required this.type,
  });

  final String transactionId;
  final String accountId;
  final String? transferAccountId;
  final String? categoryId;
  final double amount;
  final BigInt? amountMinor;
  final int? amountScale;
  final DateTime date;
  final String? note;
  final TransactionType type;

  double get normalizedAmount => amount.abs();
}
