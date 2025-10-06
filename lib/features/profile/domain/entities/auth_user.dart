import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

@freezed
abstract class AuthUser with _$AuthUser {
  const AuthUser._();

  const factory AuthUser({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
    @Default(false) bool isAnonymous,
    @Default(false) bool emailVerified,
    DateTime? creationTime,
    DateTime? lastSignInTime,
  }) = _AuthUser;

  factory AuthUser.guest({DateTime? createdAt}) {
    final DateTime timestamp = createdAt ?? DateTime.now().toUtc();
    return AuthUser(
      uid: 'guest-${timestamp.millisecondsSinceEpoch}',
      isAnonymous: true,
      emailVerified: false,
      creationTime: timestamp,
      lastSignInTime: timestamp,
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  bool get isGuest => isAnonymous && uid.startsWith('guest-');
}
