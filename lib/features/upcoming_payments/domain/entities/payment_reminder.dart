import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_reminder.freezed.dart';

@freezed
abstract class PaymentReminder with _$PaymentReminder {
  const PaymentReminder._();

  const factory PaymentReminder({
    required String id,
    required String title,
    required double amount,
    @JsonKey(includeFromJson: false, includeToJson: false)
    BigInt? amountMinor,
    @JsonKey(includeFromJson: false, includeToJson: false)
    int? amountScale,
    required int whenAtMs,
    String? note,
    required bool isDone,
    int? lastNotifiedAtMs,
    required int createdAtMs,
    required int updatedAtMs,
  }) = _PaymentReminder;

  factory PaymentReminder.fromJson(Map<String, Object?> json) {
    return PaymentReminder(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      amountMinor: null,
      amountScale: null,
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
      'amount': amount,
      'whenAtMs': whenAtMs,
      'note': note,
      'isDone': isDone,
      'lastNotifiedAtMs': lastNotifiedAtMs,
      'createdAtMs': createdAtMs,
      'updatedAtMs': updatedAtMs,
    }..removeWhere((String key, Object? value) => value == null);
  }
}
