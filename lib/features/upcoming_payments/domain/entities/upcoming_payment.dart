import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'upcoming_payment.freezed.dart';

@freezed
abstract class UpcomingPayment with _$UpcomingPayment {
  const UpcomingPayment._();

  const factory UpcomingPayment({
    required String id,
    required String title,
    required String accountId,
    required String categoryId,
    @JsonKey(includeFromJson: false, includeToJson: false) BigInt? amountMinor,
    @JsonKey(includeFromJson: false, includeToJson: false) int? amountScale,
    required int dayOfMonth,
    required int notifyDaysBefore,
    required String notifyTimeHhmm,
    String? note,
    required bool autoPost,
    required bool isActive,
    int? nextRunAtMs,
    int? nextNotifyAtMs,
    String? lastGeneratedPeriod,
    required int createdAtMs,
    required int updatedAtMs,
  }) = _UpcomingPayment;

  factory UpcomingPayment.fromJson(Map<String, Object?> json) {
    final int scale = _readInt(json['amountScale']) ?? 2;
    final BigInt? minor = _readBigInt(json['amountMinor']);
    final double legacyAmount = (json['amount'] as num?)?.toDouble() ?? 0;
    final BigInt resolvedMinor =
        minor ??
        Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
    return UpcomingPayment(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      accountId: json['accountId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      amountMinor: resolvedMinor,
      amountScale: scale,
      dayOfMonth: (json['dayOfMonth'] as num?)?.toInt() ?? 1,
      notifyDaysBefore: (json['notifyDaysBefore'] as num?)?.toInt() ?? 0,
      notifyTimeHhmm: json['notifyTimeHhmm'] as String? ?? '12:00',
      note: json['note'] as String?,
      autoPost: json['autoPost'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      nextRunAtMs: (json['nextRunAtMs'] as num?)?.toInt(),
      nextNotifyAtMs: (json['nextNotifyAtMs'] as num?)?.toInt(),
      lastGeneratedPeriod: json['lastGeneratedPeriod'] as String?,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'accountId': accountId,
      'categoryId': categoryId,
      'amountMinor': amountMinor?.toString(),
      'amountScale': amountScale,
      'dayOfMonth': dayOfMonth,
      'notifyDaysBefore': notifyDaysBefore,
      'notifyTimeHhmm': notifyTimeHhmm,
      'note': note,
      'autoPost': autoPost,
      'isActive': isActive,
      'nextRunAtMs': nextRunAtMs,
      'nextNotifyAtMs': nextNotifyAtMs,
      'lastGeneratedPeriod': lastGeneratedPeriod,
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
