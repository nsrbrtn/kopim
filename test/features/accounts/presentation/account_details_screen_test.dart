import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/widgets/web_responsive_wrapper.dart';
import 'package:kopim/features/accounts/presentation/account_details_screen.dart';

void main() {
  group('resolveResponsiveMaxWidthForLocation', () {
    test('uses default width for regular routes', () {
      expect(resolveResponsiveMaxWidthForLocation('/home'), 600);
      expect(resolveResponsiveMaxWidthForLocation(null), 600);
    });

    test('uses wide width for account details route', () {
      expect(
        resolveResponsiveMaxWidthForLocation('/accounts/details?accountId=42'),
        1120,
      );
    });
  });

  group('account details responsive helpers', () {
    test('keeps compact padding on narrow widths', () {
      expect(resolveAccountDetailsHorizontalPadding(480), 16);
      expect(resolveAccountDetailsHorizontalPadding(719), 16);
    });

    test('scales padding from available container width', () {
      expect(resolveAccountDetailsHorizontalPadding(720), 57.6);
      expect(resolveAccountDetailsHorizontalPadding(1120), 88);
      expect(resolveAccountDetailsHorizontalPadding(1600), 88);
    });

    test('switches summary to compact mode only on tight widths', () {
      expect(shouldUseCompactAccountSummary(480), isTrue);
      expect(shouldUseCompactAccountSummary(520), isFalse);
      expect(shouldUseCompactAccountSummary(760), isFalse);
    });
  });
}
