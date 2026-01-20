import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'account_entity.freezed.dart';
part 'account_entity.g.dart';

@freezed
abstract class AccountEntity with _$AccountEntity {
  const AccountEntity._();

  const factory AccountEntity({
    required String id,
    required String name,
    @JsonKey(includeFromJson: false, includeToJson: false) BigInt? balanceMinor,
    @JsonKey(includeFromJson: false, includeToJson: false)
    BigInt? openingBalanceMinor,
    required String currency,
    @JsonKey(includeFromJson: false, includeToJson: false)
    int? currencyScale,
    required String type,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? color,
    String? gradientId,
    String? iconName,
    String? iconStyle,
    @Default(false) bool isDeleted,
    @Default(false) bool isPrimary,
    @Default(false) bool isHidden,
  }) = _AccountEntity;

  MoneyAmount get balanceAmount => MoneyAmount(
    minor: balanceMinor ?? BigInt.zero,
    scale: currencyScale ?? 2,
  );

  MoneyAmount get openingBalanceAmount => MoneyAmount(
    minor: openingBalanceMinor ?? BigInt.zero,
    scale: currencyScale ?? 2,
  );

  factory AccountEntity.fromJson(Map<String, Object?> json) =>
      _$AccountEntityFromJson(json);
}
