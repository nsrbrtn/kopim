import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  StreamSubscription<AuthUser?>? _authSubscription;
  bool _initialSyncTriggered = false;

  @override
  FutureOr<AuthUser?> build() async {
    final AuthRepository repository = ref.watch(authRepositoryProvider);
    final Connectivity connectivity = ref.watch(connectivityProvider);

    _authSubscription = repository.authStateChanges().listen(
      (AuthUser? user) {
        if (!ref.mounted) {
          return;
        }
        state = AsyncValue<AuthUser?>.data(user);
        if (user != null && !user.isAnonymous && !_initialSyncTriggered) {
          _initialSyncTriggered = true;
          unawaited(_syncSilently(user));
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        ref
            .read(loggerServiceProvider)
            .logError('AuthStateChanges stream error', error);
      },
    );

    ref.onDispose(() => _authSubscription?.cancel());

    final AuthUser? existingUser = repository.currentUser;
    if (existingUser != null) {
      if (!existingUser.isAnonymous && !_initialSyncTriggered) {
        _initialSyncTriggered = true;
        unawaited(_syncSilently(existingUser));
      }
      return existingUser;
    }

    final List<ConnectivityResult> connectivityResults = await connectivity
        .checkConnectivity();
    final bool isOffline = connectivityResults.every(
      (ConnectivityResult result) => result == ConnectivityResult.none,
    );

    if (isOffline) {
      final AuthUser fallbackUser = await repository.signInAnonymously();
      state = AsyncValue<AuthUser?>.data(fallbackUser);
      return fallbackUser;
    }

    return null;
  }

  Future<void> signIn(SignInRequest request) async {
    final AuthUser? previousUser = state.value;
    state = const AsyncValue<AuthUser?>.loading();
    try {
      final AuthUser user = await ref
          .read(authRepositoryProvider)
          .signIn(request);
      state = AsyncValue<AuthUser?>.data(user);
      await _syncOrThrow(user, previousUser);
    } on AuthFailure catch (failure) {
      state = AsyncValue<AuthUser?>.data(previousUser);
      ref
          .read(loggerServiceProvider)
          .logError('signIn failed: ${failure.message}', failure);
      rethrow;
    }
  }

  Future<void> continueWithOfflineMode() async {
    final AuthUser? previousUser = state.value;
    state = const AsyncValue<AuthUser?>.loading();
    try {
      final AuthUser user = await ref
          .read(authRepositoryProvider)
          .signInAnonymously();
      state = AsyncValue<AuthUser?>.data(user);
    } on AuthFailure catch (failure) {
      state = AsyncValue<AuthUser?>.data(previousUser);
      ref
          .read(loggerServiceProvider)
          .logError(
            'continueWithOfflineMode failed: ${failure.message}',
            failure,
          );
      rethrow;
    }
  }

  Future<void> signUp(SignUpRequest request) async {
    final AuthUser? previousUser = state.value;
    state = const AsyncValue<AuthUser?>.loading();
    try {
      final AuthUser user = await ref
          .read(authRepositoryProvider)
          .signUp(request);
      state = AsyncValue<AuthUser?>.data(user);
      await _syncOrThrow(user, previousUser);
    } on AuthFailure catch (failure, stackTrace) {
      state = AsyncValue<AuthUser?>.error(failure, stackTrace);
      rethrow;
    }
  }

  Future<void> reauthenticate(SignInRequest request) async {
    final AuthUser? previousUser = state.value;
    state = const AsyncValue<AuthUser?>.loading();
    try {
      final AuthUser user = await ref
          .read(authRepositoryProvider)
          .reauthenticate(request);
      state = AsyncValue<AuthUser?>.data(user);
      await _syncOrThrow(user, previousUser);
    } on AuthFailure catch (failure, stackTrace) {
      state = AsyncValue<AuthUser?>.error(failure, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue<AuthUser?>.loading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncValue<AuthUser?>.data(null);
      _initialSyncTriggered = false;
    } on AuthFailure catch (failure, stackTrace) {
      state = AsyncValue<AuthUser?>.error(failure, stackTrace);
      rethrow;
    }
  }

  Future<void> _syncOrThrow(AuthUser user, AuthUser? previousUser) async {
    if (user.isAnonymous) {
      return;
    }
    await ref
        .read(authSyncServiceProvider)
        .synchronizeOnLogin(user: user, previousUser: previousUser);
    await ref.read(recomputeUserProgressUseCaseProvider)();
    _initialSyncTriggered = true;
  }

  Future<void> _syncSilently(AuthUser user) async {
    try {
      await _syncOrThrow(user, null);
    } on AuthFailure catch (failure) {
      ref
          .read(loggerServiceProvider)
          .logError('Initial auth sync failed: ${failure.message}', failure);
    }
  }
}
