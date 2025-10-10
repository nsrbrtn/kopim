import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_reminder.freezed.dart';

@freezed
abstract class PaymentReminder with _$PaymentReminder {
  const PaymentReminder._();

  const factory PaymentReminder({
    required String id,
    required String title,
    required double amount,
    required int whenAtMs,
    String? note,
    required bool isDone,
    required int createdAtMs,
    required int updatedAtMs,
  }) = _PaymentReminder;
}
