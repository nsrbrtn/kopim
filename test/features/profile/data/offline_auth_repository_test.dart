import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/data/offline_auth_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'signInAnonymously создает стабильный local uid и переиспользует его',
    () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final OfflineAuthRepository firstRepository = OfflineAuthRepository(
        preferences: Future<SharedPreferences>.value(prefs),
      );
      final AuthUser user1 = await firstRepository.signInAnonymously();

      expect(user1.isAnonymous, isTrue);
      expect(user1.uid, startsWith('local-'));

      final OfflineAuthRepository secondRepository = OfflineAuthRepository(
        preferences: Future<SharedPreferences>.value(prefs),
      );
      final AuthUser user2 = await secondRepository.signInAnonymously();

      expect(user2.uid, equals(user1.uid));
      expect(user2.isLocalOnly, isTrue);

      firstRepository.dispose();
      secondRepository.dispose();
    },
  );
}
