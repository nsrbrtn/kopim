import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    required GoogleSignIn googleSignIn,
    required LoggerService loggerService,
    required AnalyticsService analyticsService,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn,
       _logger = loggerService,
       _analyticsService = analyticsService;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final LoggerService _logger;
  final AnalyticsService _analyticsService;

  AuthUser? _localFallbackUser;
  bool _googleInitialized = false;

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
    final String label = switch (request) {
      EmailSignInRequest() => 'email',
      GoogleSignInRequest() => 'google',
    };

    final AuthUser user = await _guard<AuthUser>('signIn:$label', () async {
      return switch (request) {
        EmailSignInRequest(:final String email, :final String password) =>
          _signInWithEmail(email, password),
        GoogleSignInRequest() => _signInWithGoogle(),
      };
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
      try {
        await _ensureGoogleInitialized();
        await _googleSignIn.signOut();
      } catch (error, stack) {
        _logger.logError('Google sign-out failed', error);
        _analyticsService.reportError(error, stack);
      }
      _localFallbackUser = null;
    });
  }

  @override
  Future<AuthUser> reauthenticate(SignInRequest request) {
    final String label = switch (request) {
      EmailSignInRequest() => 'email',
      GoogleSignInRequest() => 'google',
    };

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

  Future<AuthUser> _signInWithEmail(String email, String password) async {
    final UserCredential credential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return _mapCredential(credential);
  }

  Future<AuthUser> _signInWithGoogle() async {
    await _ensureGoogleInitialized();
    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final String? idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthFailure(
          code: 'missing-id-token',
          message: 'Google authentication did not return an ID token.',
        );
      }
      final UserCredential result = await _firebaseAuth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      return _mapCredential(result);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure(
          code: 'sign-in-cancelled',
          message: 'Google sign-in flow was cancelled by the user.',
        );
      }
      throw AuthFailure(
        code: error.code.name,
        message: error.description ?? 'Google sign-in failed.',
      );
    }
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
    return switch (request) {
      EmailSignInRequest(:final String email, :final String password) =>
        EmailAuthProvider.credential(email: email, password: password),
      GoogleSignInRequest() => _buildGoogleCredential(),
    };
  }

  Future<AuthCredential> _buildGoogleCredential() async {
    await _ensureGoogleInitialized();
    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final String? idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthFailure(
          code: 'missing-id-token',
          message: 'Google reauthentication did not return an ID token.',
        );
      }
      return GoogleAuthProvider.credential(idToken: idToken);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure(
          code: 'sign-in-cancelled',
          message: 'Google reauthentication was cancelled by the user.',
        );
      }
      throw AuthFailure(
        code: error.code.name,
        message: error.description ?? 'Google reauthentication failed.',
      );
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) {
      return;
    }
    try {
      await _googleSignIn.initialize();
      _googleInitialized = true;
    } catch (error, stackTrace) {
      _logger.logError('Failed to initialize Google Sign-In', error);
      _analyticsService.reportError(error, stackTrace);
      throw const AuthFailure(
        code: 'google-initialization-failed',
        message: 'Failed to initialize Google Sign-In SDK.',
      );
    }
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
      _logger.logError(
        'FirebaseAuthException during $action: ${error.code}',
        error,
      );
      _analyticsService.reportError(error, stackTrace);
      throw AuthFailure(
        code: error.code,
        message:
            error.message ?? 'Firebase authentication error during $action.',
      );
    } catch (error, stackTrace) {
      _logger.logError('Unexpected auth error during $action', error);
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
