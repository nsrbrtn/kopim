import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_entity.freezed.dart';
part 'credit_entity.g.dart';

@freezed
abstract class CreditEntity with _$CreditEntity {
  const factory CreditEntity({
    required String id,
    required String accountId,
    String? categoryId,
    required double totalAmount,
    @JsonKey(includeFromJson: false, includeToJson: false)
    BigInt? totalAmountMinor,
    @JsonKey(includeFromJson: false, includeToJson: false)
    int? totalAmountScale,
    required double interestRate,
    required int termMonths,
    required DateTime startDate,
    @Default(1) int paymentDay,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _CreditEntity;

  factory CreditEntity.fromJson(Map<String, Object?> json) =>
      _$CreditEntityFromJson(json);
}
