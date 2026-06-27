import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';

void main() {
  test('local session exposes local session kind and null firebase uid', () {
    final AuthUser user = AuthUser.local(uid: 'device-user-1');

    expect(user.sessionKind, AuthSessionKind.local);
    expect(user.isLocalSession, isTrue);
    expect(user.isFirebaseSession, isFalse);
    expect(user.firebaseUid, isNull);
    expect(user.uid, startsWith(AuthUser.localUidPrefix));
  });

  test('firebase session exposes firebase uid', () {
    const AuthUser user = AuthUser(
      uid: 'firebase-user-1',
      email: 'user@example.com',
      isAnonymous: false,
      sessionKind: AuthSessionKind.firebase,
    );

    expect(user.sessionKind, AuthSessionKind.firebase);
    expect(user.isFirebaseSession, isTrue);
    expect(user.isLocalSession, isFalse);
    expect(user.firebaseUid, 'firebase-user-1');
  });

  test('local-prefixed uid is never exposed as firebase uid', () {
    const AuthUser user = AuthUser(
      uid: 'local-user-1',
      isAnonymous: true,
      sessionKind: AuthSessionKind.local,
    );

    expect(user.isLocalSession, isTrue);
    expect(user.firebaseUid, isNull);
  });
}
