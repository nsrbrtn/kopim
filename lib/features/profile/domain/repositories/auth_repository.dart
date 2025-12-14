import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';

abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  Future<AuthUser> signIn(SignInRequest request);

  Future<AuthUser> signUp(SignUpRequest request);

  Future<void> signOut();

  Future<AuthUser> reauthenticate(SignInRequest request);

  Future<AuthUser> signInAnonymously();

  Future<void> sendPasswordResetEmail(String email);
}
