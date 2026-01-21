import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'debt_entity.freezed.dart';
part 'debt_entity.g.dart';

@freezed
abstract class DebtEntity with _$DebtEntity {
  const DebtEntity._();

  const factory DebtEntity({
    required String id,
    required String accountId,
    @Default('') String name,
    @JsonKey(includeFromJson: false, includeToJson: false) BigInt? amountMinor,
    @JsonKey(includeFromJson: false, includeToJson: false) int? amountScale,
    required DateTime dueDate,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _DebtEntity;

  factory DebtEntity.fromJson(Map<String, Object?> json) =>
      _$DebtEntityFromJson(json);

  MoneyAmount get amountValue =>
      MoneyAmount(minor: amountMinor ?? BigInt.zero, scale: amountScale ?? 2);
}
