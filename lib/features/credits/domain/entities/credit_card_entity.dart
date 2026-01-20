import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'credit_card_entity.freezed.dart';
part 'credit_card_entity.g.dart';

@freezed
abstract class CreditCardEntity with _$CreditCardEntity {
  const factory CreditCardEntity({
    required String id,
    required String accountId,
    @JsonKey(includeFromJson: false, includeToJson: false)
    BigInt? creditLimitMinor,
    @JsonKey(includeFromJson: false, includeToJson: false)
    int? creditLimitScale,
    required int statementDay,
    required int paymentDueDays,
    required double interestRateAnnual,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _CreditCardEntity;

  factory CreditCardEntity.fromJson(Map<String, Object?> json) =>
      _$CreditCardEntityFromJson(json);

  MoneyAmount get creditLimitValue => MoneyAmount(
    minor: creditLimitMinor ?? BigInt.zero,
    scale: creditLimitScale ?? 2,
  );
}
