import 'dart:async';

import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/data/local_profile_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository({
    required LocalProfileRepository localProfileRepository,
    LoggerService? loggerService,
  }) : _localProfileRepository = localProfileRepository,
       _logger = loggerService ?? LoggerService(),
       _controller = StreamController<AuthUser?>.broadcast() {
    unawaited(restoreLocalSession());
  }

  final LocalProfileRepository _localProfileRepository;
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

  Future<AuthUser> restoreLocalSession() async {
    try {
      final String profileId = await _localProfileRepository
          .restoreOrCreateProfileId();
      _currentUser = AuthUser.local(uid: profileId);
      _logger.logInfo(
        'LocalAuthRepository: restored local session for profileId=$profileId.',
      );
      if (!_controller.isClosed) {
        _controller.add(_currentUser);
      }
      return _currentUser!;
    } catch (error) {
      _logger.logError('Не удалось восстановить локальный профиль.', error);
      // В случае непредвиденной ошибки бросаем AuthFailure, а не guest fallback.
      throw const AuthFailure(
        code: 'local-profile-restore-failed',
        message: 'Не удалось запустить локальный профиль. Попробуйте еще раз.',
      );
    }
  }

  /// Compatibility alias for old UI/use cases.
  /// Does not use Firebase Anonymous Auth.
  /// Restores or creates a stable local profile.
  @override
  Future<AuthUser> signInAnonymously() {
    return restoreLocalSession();
  }

  @override
  Future<AuthUser> signInOffline() {
    return restoreLocalSession();
  }

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
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> deleteCurrentUser() {
    return _unsupportedVoid('deleteCurrentUser');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _unsupportedVoid('sendPasswordResetEmail');
  }

  @override
  Future<AuthUser> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) {
    return _unsupported('updateEmail');
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _unsupportedVoid('updatePassword');
  }

  Future<AuthUser> _unsupported(String action) {
    _logger.logError(
      'Действие авторизации недоступно в локальном режиме: $action',
    );
    throw const AuthFailure(
      code: 'local-mode-unsupported',
      message: 'Облачная авторизация недоступна в локальном режиме.',
    );
  }

  Future<void> _unsupportedVoid(String action) async {
    _logger.logError(
      'Действие авторизации недоступно в локальном режиме: $action',
    );
    throw const AuthFailure(
      code: 'local-mode-unsupported',
      message: 'Облачная авторизация недоступна в локальном режиме.',
    );
  }
}
