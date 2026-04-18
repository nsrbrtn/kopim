import 'dart:async';

import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class OfflineAuthRepository implements AuthRepository {
  OfflineAuthRepository({
    LoggerService? loggerService,
    Future<SharedPreferences>? preferences,
    Uuid? uuid,
  }) : _logger = loggerService ?? LoggerService(),
       _preferencesFuture = preferences ?? SharedPreferences.getInstance(),
       _uuid = uuid ?? const Uuid(),
       _controller = StreamController<AuthUser?>.broadcast() {
    unawaited(_restoreUser());
  }

  static const String _kOfflineUserIdKey = 'profile.offline_user.id';
  static const String _kOfflineUserCreatedAtKey =
      'profile.offline_user.created_at';

  final LoggerService _logger;
  final Future<SharedPreferences> _preferencesFuture;
  final Uuid _uuid;
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
    _currentUser ??= await _restoreOrCreateUser();
    _controller.add(_currentUser);
    return _currentUser!;
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

  Future<void> _restoreUser() async {
    try {
      _currentUser = await _restoreOrCreateUser();
      if (!_controller.isClosed) {
        _controller.add(_currentUser);
      }
    } catch (error) {
      _logger.logError(
        'Не удалось восстановить локального офлайн-пользователя. Используем временный guest.',
        error,
      );
      _currentUser = AuthUser.guest();
      if (!_controller.isClosed) {
        _controller.add(_currentUser);
      }
    }
  }

  Future<AuthUser> _restoreOrCreateUser() async {
    final SharedPreferences prefs = await _preferencesFuture;
    final String? existingId = prefs.getString(_kOfflineUserIdKey);
    final String? storedCreatedAt = prefs.getString(_kOfflineUserCreatedAtKey);
    final DateTime? createdAt = storedCreatedAt == null
        ? null
        : DateTime.tryParse(storedCreatedAt)?.toUtc();

    if (existingId != null && existingId.isNotEmpty) {
      return AuthUser.local(uid: existingId, createdAt: createdAt);
    }

    final DateTime now = DateTime.now().toUtc();
    final String localId = '${AuthUser.localUidPrefix}${_uuid.v4()}';
    await prefs.setString(_kOfflineUserIdKey, localId);
    await prefs.setString(_kOfflineUserCreatedAtKey, now.toIso8601String());
    return AuthUser.local(uid: localId, createdAt: now);
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
