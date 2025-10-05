import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/formatting/date_format_providers.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru');
    await initializeDateFormatting('en');
  });

  group('dateFormatProvider', () {
    test('возвращает один и тот же экземпляр для одинаковых параметров', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      const DateFormatRequest request = (
        locale: Locale('ru'),
        format: AppDateFormat.longMonthDay,
      );

      final DateFormat first = container.read(dateFormatProvider(request));
      final DateFormat second = container.read(dateFormatProvider(request));

      expect(identical(first, second), isTrue);
    });

    test('форматирует дату в соответствии с локалью', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      const DateFormatRequest request = (
        locale: Locale('en'),
        format: AppDateFormat.longMonthDay,
      );

      final DateFormat format = container.read(dateFormatProvider(request));
      final DateTime date = DateTime(2024, 9, 24);

      expect(format.format(date), 'September 24, 2024');
    });
  });
}
