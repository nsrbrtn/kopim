import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required LoggerService loggerService,
    required AnalyticsService analyticsService,
  }) : _firebaseAuth = firebaseAuth,
       _logger = loggerService,
       _analyticsService = analyticsService;

  final FirebaseAuth _firebaseAuth;
  final LoggerService _logger;
  final AnalyticsService _analyticsService;

  AuthUser? _localFallbackUser;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth
        .authStateChanges()
        .map(_mapFirebaseUser)
        .map(_mergeWithFallback);
  }

  @override
  AuthUser? get currentUser =>
      _mergeWithFallback(_mapFirebaseUser(_firebaseAuth.currentUser));

  @override
  Future<AuthUser> signIn(SignInRequest request) async {
    const String label = 'email';

    final AuthUser user = await _guard<AuthUser>('signIn:$label', () async {
      return request.map(
        email: (EmailSignInRequest value) =>
            _signInWithEmail(value.email, value.password),
      );
    });

    _logger.logInfo('Authenticated user ${user.uid} via $label sign-in.');
    return user;
  }

  @override
  Future<AuthUser> signUp(SignUpRequest request) {
    return _guard<AuthUser>('signUp', () async {
      return switch (request) {
        EmailSignUpRequest(
          :final String email,
          :final String password,
          :final String? displayName,
        ) =>
          _signUpWithEmail(email, password, displayName),
      };
    });
  }

  @override
  Future<void> signOut() {
    return _guardVoid('signOut', () async {
      await _firebaseAuth.signOut();
      _localFallbackUser = null;
    });
  }

  @override
  Future<AuthUser> reauthenticate(SignInRequest request) {
    const String label = 'email';

    return _guard<AuthUser>('reauthenticate:$label', () async {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure(
          code: 'no-current-user',
          message: 'No active session available for reauthentication.',
        );
      }

      final AuthCredential credential = await _credentialForRequest(request);
      final UserCredential result = await user.reauthenticateWithCredential(
        credential,
      );
      return _mapCredential(result);
    });
  }

  @override
  Future<AuthUser> signInAnonymously() async {
    try {
      final User? current = _firebaseAuth.currentUser;
      if (current != null && current.isAnonymous) {
        final AuthUser? mapped = _mapFirebaseUser(current);
        if (mapped != null) {
          _localFallbackUser = null;
          _logger.logInfo('Using existing anonymous session ${mapped.uid}.');
          return mapped;
        }
      }

      final UserCredential credential = await _firebaseAuth.signInAnonymously();
      final AuthUser? user = _mapCredentialNullable(credential);
      if (user != null) {
        _localFallbackUser = null;
        _logger.logInfo(
          'Anonymous Firebase sign-in succeeded for ${user.uid}.',
        );
        return user;
      }

      final AuthUser fallback = AuthUser.guest();
      _localFallbackUser = fallback;
      _logger.logInfo(
        'Firebase anonymous sign-in returned null user. Using fallback ${fallback.uid}.',
      );
      return fallback;
    } on FirebaseAuthException catch (error, stackTrace) {
      _logger.logError(
        'FirebaseAuthException during signInAnonymously: ${error.code}',
        error,
      );
      _analyticsService.reportError(error, stackTrace);

      if (error.code == 'network-request-failed' ||
          error.code == 'network_error') {
        final AuthUser fallback = AuthUser.guest();
        _localFallbackUser = fallback;
        _logger.logInfo(
          'Using offline anonymous fallback ${fallback.uid} due to network error.',
        );
        return fallback;
      }

      throw AuthFailure(
        code: error.code,
        message: error.message ?? 'Failed to sign in anonymously.',
      );
    } catch (error, stackTrace) {
      _logger.logError('Unexpected error during signInAnonymously', error);
      _analyticsService.reportError(error, stackTrace);
      final AuthUser fallback = AuthUser.guest();
      _localFallbackUser = fallback;
      return fallback;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _guardVoid('sendPasswordResetEmail', () async {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    });
  }

  Future<AuthUser> _signInWithEmail(String email, String password) async {
    final UserCredential credential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return _mapCredential(credential);
  }

  Future<AuthUser> _signUpWithEmail(
    String email,
    String password,
    String? displayName,
  ) async {
    final UserCredential credential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    final User? user = credential.user;
    if (user == null) {
      throw AuthFailure.unknown(
        'Firebase returned an empty user credential during sign-up.',
      );
    }

    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }

    final User refreshedUser = _firebaseAuth.currentUser ?? user;
    return _mapFirebaseUser(refreshedUser) ??
        (throw AuthFailure.unknown(
          'Unable to map Firebase user after sign-up.',
        ));
  }

  Future<AuthCredential> _credentialForRequest(SignInRequest request) async {
    return request.map(
      email: (EmailSignInRequest value) => EmailAuthProvider.credential(
        email: value.email,
        password: value.password,
      ),
    );
  }

  AuthUser? _mapFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
      emailVerified: user.emailVerified,
      creationTime: user.metadata.creationTime?.toUtc(),
      lastSignInTime: user.metadata.lastSignInTime?.toUtc(),
    );
  }

  AuthUser _mapCredential(UserCredential credential) {
    final AuthUser? user = _mapCredentialNullable(credential);
    if (user == null) {
      throw AuthFailure.unknown('Firebase returned an empty user credential.');
    }
    _localFallbackUser = null;
    return user;
  }

  AuthUser? _mapCredentialNullable(UserCredential credential) {
    final User? user = credential.user;
    return _mapFirebaseUser(user);
  }

  AuthUser? _mergeWithFallback(AuthUser? user) {
    if (user != null) {
      _localFallbackUser = null;
      return user;
    }
    return _localFallbackUser;
  }

  Future<T> _guard<T>(String action, Future<T> Function() operation) async {
    try {
      final T result = await operation();
      _logger.logInfo('Auth action succeeded: $action');
      return result;
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (error, stackTrace) {
      try {
        _logger.logError(
          'FirebaseAuthException during $action: ${error.code}',
          error,
        );
      } catch (_) {}
      _analyticsService.reportError(error, stackTrace);
      throw AuthFailure(
        code: error.code,
        message:
            error.message ?? 'Firebase authentication error during $action.',
      );
    } catch (error, stackTrace) {
      try {
        _logger.logError('Unexpected auth error during $action', error);
      } catch (_) {}
      _analyticsService.reportError(error, stackTrace);
      throw AuthFailure.unknown('Unexpected error during $action.');
    }
  }

  Future<void> _guardVoid(
    String action,
    Future<void> Function() operation,
  ) async {
    await _guard<void>(action, () async {
      await operation();
    });
  }
}
