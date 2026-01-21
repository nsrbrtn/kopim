import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/data/converters/big_int_converter.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'budget_category_allocation.freezed.dart';
part 'budget_category_allocation.g.dart';

@freezed
abstract class BudgetCategoryAllocation with _$BudgetCategoryAllocation {
  const BudgetCategoryAllocation._();

  const factory BudgetCategoryAllocation({
    required String categoryId,
    @JsonKey(readValue: _readLimitMinor, toJson: _writeLimitMinor)
    @BigIntJsonConverter()
    required BigInt limitMinor,
    @JsonKey(readValue: _readLimitScale, toJson: _writeLimitScale)
    required int limitScale,
  }) = _BudgetCategoryAllocation;

  factory BudgetCategoryAllocation.fromJson(Map<String, dynamic> json) =>
      _$BudgetCategoryAllocationFromJson(json);

  MoneyAmount get limitValue =>
      MoneyAmount(minor: limitMinor, scale: limitScale);
}

Object? _readLimitMinor(Map<dynamic, dynamic> json, String key) {
  final Object? raw = json['limitMinor'] ?? json['limit_minor'];
  if (raw != null) {
    return raw.toString();
  }
  final num? legacy = json['limit'] as num?;
  if (legacy == null) {
    return '0';
  }
  final int scale = _resolveLimitScale(json);
  final BigInt minor = Money.fromDouble(
    legacy.toDouble(),
    currency: 'XXX',
    scale: scale,
  ).minor;
  return minor.toString();
}

Object? _readLimitScale(Map<dynamic, dynamic> json, String key) {
  return _resolveLimitScale(json);
}

int _resolveLimitScale(Map<dynamic, dynamic> json) {
  final Object? raw = json['limitScale'] ?? json['limit_scale'];
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? 2;
  return 2;
}

Object _writeLimitMinor(Object? value) {
  if (value == null) return '0';
  return value.toString();
}

Object _writeLimitScale(Object? value) {
  if (value == null) return 2;
  return value;
}
