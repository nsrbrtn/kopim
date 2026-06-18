import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/data/local_auth_repository.dart';
import 'package:kopim/features/profile/data/local_profile_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('LocalAuthRepository Tests', () {
    late SharedPreferences sharedPreferences;
    late LocalProfileRepository localProfileRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      sharedPreferences = await SharedPreferences.getInstance();
      localProfileRepository = LocalProfileRepository(
        preferences: Future<SharedPreferences>.value(sharedPreferences),
        uuid: const Uuid(),
      );
    });

    test('should return AuthUser.local with stable local uid', () async {
      final LocalAuthRepository repository = LocalAuthRepository(
        localProfileRepository: localProfileRepository,
      );

      final AuthUser user = await repository.signInAnonymously();
      expect(user.uid, startsWith('local-'));
      expect(user.isLocalOnly, isTrue);
      expect(user.isAnonymous, isTrue);

      final LocalAuthRepository repository2 = LocalAuthRepository(
        localProfileRepository: localProfileRepository,
      );
      final AuthUser user2 = await repository2.signInAnonymously();
      expect(user2.uid, equals(user.uid));

      repository.dispose();
      repository2.dispose();
    });

    test('unsupported actions should throw AuthFailure', () async {
      final LocalAuthRepository repository = LocalAuthRepository(
        localProfileRepository: localProfileRepository,
      );

      expect(
        () => repository.deleteCurrentUser(),
        throwsA(
          isA<AuthFailure>().having(
            (AuthFailure e) => e.code,
            'code',
            'local-mode-unsupported',
          ),
        ),
      );

      repository.dispose();
    });
  });
}
