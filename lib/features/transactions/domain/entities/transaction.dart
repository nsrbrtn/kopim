import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
abstract class TransactionEntity with _$TransactionEntity {
  const TransactionEntity._();

  const factory TransactionEntity({
    required String id,
    required String accountId,
    String? transferAccountId,
    String? categoryId,
    String? savingGoalId,
    required double amount,
    required DateTime date,
    String? note,
    required String type,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _TransactionEntity;

  factory TransactionEntity.fromJson(Map<String, Object?> json) =>
      _$TransactionEntityFromJson(json);
}
