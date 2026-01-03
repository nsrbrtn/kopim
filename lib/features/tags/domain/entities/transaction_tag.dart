import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_tag.freezed.dart';
part 'transaction_tag.g.dart';

@freezed
abstract class TransactionTagEntity with _$TransactionTagEntity {
  const TransactionTagEntity._();

  const factory TransactionTagEntity({
    required String transactionId,
    required String tagId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _TransactionTagEntity;

  factory TransactionTagEntity.fromJson(Map<String, Object?> json) =>
      _$TransactionTagEntityFromJson(json);
}
