import 'dart:async';

import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';

class OfflineAuthRepository implements AuthRepository {
  OfflineAuthRepository({LoggerService? loggerService})
    : _logger = loggerService ?? LoggerService(),
      _controller = StreamController<AuthUser?>.broadcast() {
    _currentUser = AuthUser.guest();
    _controller.add(_currentUser);
  }

  final LoggerService _logger;
  final StreamController<AuthUser?> _controller;
  AuthUser? _currentUser;

  void dispose() {
    _controller.close();
  }

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signIn(SignInRequest request) {
    return _unsupported('signIn');
  }

  @override
  Future<AuthUser> signUp(SignUpRequest request) {
    return _unsupported('signUp');
  }

  @override
  Future<AuthUser> reauthenticate(SignInRequest request) {
    return _unsupported('reauthenticate');
  }

  @override
  Future<AuthUser> signInAnonymously() async {
    _currentUser ??= AuthUser.guest();
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _unsupportedVoid('sendPasswordResetEmail');
  }

  Future<AuthUser> _unsupported(String action) {
    _logger.logError('Auth действие недоступно в офлайн-режиме: $action');
    throw const AuthFailure(
      code: 'firebase-unavailable',
      message: 'Облачная авторизация недоступна в браузере.',
    );
  }

  Future<void> _unsupportedVoid(String action) async {
    _logger.logError('Auth действие недоступно в офлайн-режиме: $action');
    throw const AuthFailure(
      code: 'firebase-unavailable',
      message: 'Облачная авторизация недоступна в браузере.',
    );
  }
}
