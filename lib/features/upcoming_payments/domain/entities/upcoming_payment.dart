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
    @JsonKey(includeFromJson: false, includeToJson: false)
    BigInt? amountMinor,
    @JsonKey(includeFromJson: false, includeToJson: false)
    int? amountScale,
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

  factory UpcomingPayment.fromJson(Map<String, Object?> json) {
    return UpcomingPayment(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      accountId: json['accountId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      amountMinor: null,
      amountScale: null,
      dayOfMonth: (json['dayOfMonth'] as num?)?.toInt() ?? 1,
      notifyDaysBefore: (json['notifyDaysBefore'] as num?)?.toInt() ?? 0,
      notifyTimeHhmm: json['notifyTimeHhmm'] as String? ?? '12:00',
      note: json['note'] as String?,
      autoPost: json['autoPost'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      nextRunAtMs: (json['nextRunAtMs'] as num?)?.toInt(),
      nextNotifyAtMs: (json['nextNotifyAtMs'] as num?)?.toInt(),
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
      'amount': amount,
      'dayOfMonth': dayOfMonth,
      'notifyDaysBefore': notifyDaysBefore,
      'notifyTimeHhmm': notifyTimeHhmm,
      'note': note,
      'autoPost': autoPost,
      'isActive': isActive,
      'nextRunAtMs': nextRunAtMs,
      'nextNotifyAtMs': nextNotifyAtMs,
      'createdAtMs': createdAtMs,
      'updatedAtMs': updatedAtMs,
    }..removeWhere((String key, Object? value) => value == null);
  }
}
