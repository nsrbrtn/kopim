import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ключевой формат даты, используемый в приложении.
enum AppDateFormat {
  /// Полное название месяца и день, например «24 сентября 2024 г.».
  longMonthDay,
}

/// Параметры для получения форматтера даты.
typedef DateFormatRequest = ({Locale locale, AppDateFormat format});

/// Провайдер, кэширующий [`DateFormat`] для заданной локали и паттерна.
final Provider<DateFormat> Function(DateFormatRequest request)
dateFormatProvider = Provider.family<DateFormat, DateFormatRequest>((
  Ref ref,
  DateFormatRequest request,
) {
  final String localeTag = request.locale.toLanguageTag();
  switch (request.format) {
    case AppDateFormat.longMonthDay:
      return DateFormat.yMMMMd(localeTag);
  }
});
