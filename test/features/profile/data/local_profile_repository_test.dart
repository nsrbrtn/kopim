import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/data/local_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('LocalProfileRepository Tests', () {
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    test(
      'should generate and save a stable localProfileId on first restoreOrCreate',
      () async {
        final LocalProfileRepository repository = LocalProfileRepository(
          preferences: Future<SharedPreferences>.value(sharedPreferences),
          uuid: const Uuid(),
        );

        final String firstId = await repository.restoreOrCreateProfileId();
        expect(firstId, startsWith('local-'));

        final String secondId = await repository.restoreOrCreateProfileId();
        expect(secondId, equals(firstId));

        final String? savedId = await repository.getProfileId();
        expect(savedId, equals(firstId));
      },
    );

    test(
      'should restore existing profile ID if present in SharedPreferences',
      () async {
        const String expectedId = 'local-custom-profile-id';
        await sharedPreferences.setString(
          'profile.local_profile.id',
          expectedId,
        );

        final LocalProfileRepository repository = LocalProfileRepository(
          preferences: Future<SharedPreferences>.value(sharedPreferences),
        );

        final String id = await repository.restoreOrCreateProfileId();
        expect(id, equals(expectedId));
      },
    );
  });
}
