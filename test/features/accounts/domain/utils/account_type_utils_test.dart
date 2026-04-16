import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';

void main() {
  group('normalizeAccountType', () {
    test('maps legacy card to canonical bank', () {
      expect(normalizeAccountType('card'), kAccountTypeBank);
    });

    test('keeps supported canonical types', () {
      expect(normalizeAccountType('cash'), kAccountTypeCash);
      expect(normalizeAccountType('bank'), kAccountTypeBank);
      expect(normalizeAccountType('credit_card'), kAccountTypeCreditCard);
      expect(normalizeAccountType('investment'), kAccountTypeInvestment);
    });

    test('preserves internal legacy account types', () {
      expect(normalizeAccountType('credit'), kAccountTypeCredit);
      expect(normalizeAccountType('debt'), kAccountTypeDebt);
      expect(normalizeAccountType('savings'), kAccountTypeSavings);
    });

    test('falls back to legacy unknown for unsupported values', () {
      expect(normalizeAccountType('custom:broker'), kAccountTypeLegacyUnknown);
      expect(normalizeAccountType('checking'), kAccountTypeLegacyUnknown);
    });
  });

  group('backfill helpers', () {
    test(
      'resolveBackfillAccountType returns canonical stored type only for whitelist values',
      () {
        expect(resolveBackfillAccountType('card'), kAccountTypeBank);
        expect(resolveBackfillAccountType('bank'), kAccountTypeBank);
        expect(resolveBackfillAccountType('credit'), kAccountTypeCredit);
        expect(resolveBackfillAccountType('custom:broker'), isNull);
      },
    );

    test('shouldBackfillAccountType checks marker and mapping', () {
      expect(shouldBackfillAccountType('card', typeVersion: 0), isTrue);
      expect(shouldBackfillAccountType('bank', typeVersion: 0), isTrue);
      expect(shouldBackfillAccountType('bank', typeVersion: 1), isFalse);
      expect(
        shouldBackfillAccountType('custom:broker', typeVersion: 0),
        isFalse,
      );
    });

    test(
      'resolveStoredAccountTypeVersion promotes only deterministic stored types',
      () {
        expect(resolveStoredAccountTypeVersion('bank'), 1);
        expect(resolveStoredAccountTypeVersion('card'), 1);
        expect(resolveStoredAccountTypeVersion('custom:broker'), 0);
        expect(
          resolveStoredAccountTypeVersion('bank', currentTypeVersion: 3),
          3,
        );
      },
    );
  });

  group('account type classifiers', () {
    test('user-creatable types exclude legacy fallback', () {
      expect(isCanonicalUserCreatableAccountType('bank'), isTrue);
      expect(isCanonicalUserCreatableAccountType('investment'), isTrue);
      expect(isCanonicalUserCreatableAccountType('credit'), isFalse);
      expect(isCanonicalUserCreatableAccountType('custom:broker'), isFalse);
    });

    test('liability classification is strict', () {
      expect(isLiabilityAccountType('credit'), isTrue);
      expect(isLiabilityAccountType('credit_card'), isTrue);
      expect(isLiabilityAccountType('debt'), isTrue);
      expect(isLiabilityAccountType('card'), isFalse);
      expect(isLiabilityAccountType('custom:credit'), isFalse);
    });

    test('cash classification keeps only liquid account buckets', () {
      expect(isCashAccountType('cash'), isTrue);
      expect(isCashAccountType('bank'), isTrue);
      expect(isCashAccountType('savings'), isTrue);
      expect(isCashAccountType('investment'), isFalse);
      expect(isCashAccountType('credit_card'), isFalse);
    });
  });
}
