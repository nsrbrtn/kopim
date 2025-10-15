import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/outbox/outbox_payload_normalizer.dart';

void main() {
  group('OutboxPayloadNormalizer', () {
    const OutboxPayloadNormalizer normalizer = OutboxPayloadNormalizer();

    test('конвертирует строковый icon в дескриптор', () {
      final Map<String, dynamic> result = normalizer.normalize(
        'category',
        <String, dynamic>{'id': '1', 'name': 'Food', 'icon': 'pizza'},
      );

      expect(result['icon'], equals(<String, dynamic>{'name': 'pizza'}));
    });

    test('использует iconName/iconStyle как запасные поля', () {
      final Map<String, dynamic> result = normalizer.normalize(
        'category',
        <String, dynamic>{
          'id': '2',
          'name': 'Travel',
          'iconName': 'airplane ',
          'iconStyle': ' Bold ',
        },
      );

      expect(
        result['icon'],
        equals(<String, dynamic>{'name': 'airplane', 'style': 'bold'}),
      );
    });

    test('удаляет icon, если данные отсутствуют', () {
      final Map<String, dynamic> result = normalizer.normalize(
        'category',
        <String, dynamic>{
          'id': '3',
          'name': 'No icon',
          'icon': <String, dynamic>{},
        },
      );

      expect(result.containsKey('icon'), isFalse);
    });

    test('возвращает копию payload для других сущностей', () {
      final Map<String, dynamic> payload = <String, dynamic>{'foo': 'bar'};
      final Map<String, dynamic> result = normalizer.normalize(
        'transaction',
        payload,
      );

      expect(result, equals(payload));
      expect(identical(result, payload), isFalse);
    });
  });
}
