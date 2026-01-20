import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';

class UpcomingPaymentValidator {
  const UpcomingPaymentValidator({required TimeService timeService})
    : _timeService = timeService;

  final TimeService _timeService;

  void validate({
    required String title,
    required MoneyAmount amount,
    required int dayOfMonth,
    required int notifyDaysBefore,
    required String notifyTimeHhmm,
    required String accountId,
    required String categoryId,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'Название не может быть пустым',
      );
    }
    if (amount.minor <= BigInt.zero) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Сумма должна быть больше нуля',
      );
    }
    if (dayOfMonth < 1 || dayOfMonth > 31) {
      throw ArgumentError.value(
        dayOfMonth,
        'dayOfMonth',
        'День месяца должен быть в диапазоне 1..31',
      );
    }
    if (notifyDaysBefore < 0) {
      throw ArgumentError.value(
        notifyDaysBefore,
        'notifyDaysBefore',
        'Количество дней до уведомления не может быть отрицательным',
      );
    }
    try {
      _timeService.parseHhmmToMinutes(notifyTimeHhmm);
    } on FormatException catch (error) {
      throw ArgumentError.value(
        notifyTimeHhmm,
        'notifyTimeHhmm',
        'Некорректное время уведомления: ${error.message}',
      );
    }
    if (accountId.trim().isEmpty) {
      throw ArgumentError.value(accountId, 'accountId', 'Счёт обязателен');
    }
    if (categoryId.trim().isEmpty) {
      throw ArgumentError.value(
        categoryId,
        'categoryId',
        'Категория обязательна',
      );
    }
  }
}
