import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';

class PaymentReminderValidator {
  const PaymentReminderValidator({required TimeService timeService})
    : _timeService = timeService;

  final TimeService _timeService;

  void validate({
    required String title,
    required double amount,
    required DateTime whenLocal,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'Название не может быть пустым',
      );
    }
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Сумма должна быть больше нуля',
      );
    }
    final int whenMs = _timeService.toEpochMs(whenLocal);
    final int nowMs = _timeService.nowMs();
    if (whenMs < nowMs) {
      throw ArgumentError.value(
        whenLocal,
        'whenLocal',
        'Дата напоминания не может быть в прошлом',
      );
    }
  }
}
