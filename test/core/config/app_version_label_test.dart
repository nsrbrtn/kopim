import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_version_label.dart';

void main() {
  group('formatAppVersionLabel', () {
    test('добавляет prod suffix', () {
      expect(
        formatAppVersionLabel(
          version: '1.0.1',
          buildNumber: '3',
          flavor: 'prod',
        ),
        '1.0.1 (3) [prod]',
      );
    });

    test('добавляет dev suffix', () {
      expect(
        formatAppVersionLabel(
          version: '1.0.1',
          buildNumber: '3',
          flavor: 'dev',
        ),
        '1.0.1 (3) [dev]',
      );
    });

    test('добавляет stage suffix', () {
      expect(
        formatAppVersionLabel(
          version: '1.0.1',
          buildNumber: '3',
          flavor: 'stage',
        ),
        '1.0.1 (3) [stage]',
      );
    });

    test('не добавляет suffix для неизвестного flavor', () {
      expect(
        formatAppVersionLabel(
          version: '1.0.1',
          buildNumber: '3',
          flavor: 'offline',
        ),
        '1.0.1 (3)',
      );
    });
  });
}
