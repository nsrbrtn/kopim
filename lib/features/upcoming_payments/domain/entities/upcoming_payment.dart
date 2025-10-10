import 'package:freezed_annotation/freezed_annotation.dart';

part 'upcoming_payment.freezed.dart';

@freezed
abstract class UpcomingPayment with _$UpcomingPayment {
  const UpcomingPayment._();

  const factory UpcomingPayment({
    required String id,
    required String title,
    required String accountId,
    required String categoryId,
    required double amount,
    required int dayOfMonth,
    required int notifyDaysBefore,
    required String notifyTimeHhmm,
    String? note,
    required bool autoPost,
    required bool isActive,
    int? nextRunAtMs,
    int? nextNotifyAtMs,
    required int createdAtMs,
    required int updatedAtMs,
  }) = _UpcomingPayment;
}
