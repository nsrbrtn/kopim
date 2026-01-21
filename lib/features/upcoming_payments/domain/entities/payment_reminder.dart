import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'payment_reminder.freezed.dart';

@freezed
abstract class PaymentReminder with _$PaymentReminder {
  const PaymentReminder._();

  const factory PaymentReminder({
    required String id,
    required String title,
    @JsonKey(includeFromJson: false, includeToJson: false) BigInt? amountMinor,
    @JsonKey(includeFromJson: false, includeToJson: false) int? amountScale,
    required int whenAtMs,
    String? note,
    required bool isDone,
    int? lastNotifiedAtMs,
    required int createdAtMs,
    required int updatedAtMs,
  }) = _PaymentReminder;

  factory PaymentReminder.fromJson(Map<String, Object?> json) {
    final int scale = _readInt(json['amountScale']) ?? 2;
    final BigInt? minor = _readBigInt(json['amountMinor']);
    final double legacyAmount = (json['amount'] as num?)?.toDouble() ?? 0;
    final BigInt resolvedMinor =
        minor ??
        Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
    return PaymentReminder(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amountMinor: resolvedMinor,
      amountScale: scale,
      whenAtMs: (json['whenAtMs'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      isDone: json['isDone'] as bool? ?? false,
      lastNotifiedAtMs: (json['lastNotifiedAtMs'] as num?)?.toInt(),
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'amountMinor': amountMinor?.toString(),
      'amountScale': amountScale,
      'whenAtMs': whenAtMs,
      'note': note,
      'isDone': isDone,
      'lastNotifiedAtMs': lastNotifiedAtMs,
      'createdAtMs': createdAtMs,
      'updatedAtMs': updatedAtMs,
    }..removeWhere((String key, Object? value) => value == null);
  }

  MoneyAmount get amountValue =>
      MoneyAmount(minor: amountMinor ?? BigInt.zero, scale: amountScale ?? 2);
}

BigInt? _readBigInt(Object? value) {
  if (value == null) return null;
  if (value is BigInt) return value;
  if (value is int) return BigInt.from(value);
  if (value is num) return BigInt.from(value.toInt());
  return BigInt.tryParse(value.toString());
}

int? _readInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
