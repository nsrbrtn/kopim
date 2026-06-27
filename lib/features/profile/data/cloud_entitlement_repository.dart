import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kopim/core/config/app_runtime.dart';

class CloudEntitlementResult {
  const CloudEntitlementResult({
    required this.success,
    this.errorMessage,
    required this.state,
  });

  final bool success;
  final String? errorMessage;
  final CloudEntitlementState state;
}

abstract class CloudEntitlementRepository {
  Future<CloudEntitlementResult> activateKey(String key);
  Future<CloudEntitlementState> getCachedState();
  Future<CloudEntitlementState> refreshFromCurrentToken();
  Future<void> clearEntitlement();
}

class CloudEntitlementRepositoryImpl implements CloudEntitlementRepository {
  CloudEntitlementRepositoryImpl({
    Future<SharedPreferences>? preferences,
    required FirebaseAuth firebaseAuth,
  }) : _preferencesFuture = preferences ?? SharedPreferences.getInstance(),
       _firebaseAuth = firebaseAuth;

  static const String _kEntitlementStateKey = 'profile.entitlement.state';
  static const String _kEntitlementKeyKey = 'profile.entitlement.key';

  final Future<SharedPreferences> _preferencesFuture;
  final FirebaseAuth _firebaseAuth;

  @override
  Future<CloudEntitlementResult> activateKey(String key) async {
    final String trimmedKey = key.trim();
    if (trimmedKey.isEmpty) {
      return const CloudEntitlementResult(
        success: false,
        errorMessage: 'Ключ не может быть пустым',
        state: CloudEntitlementState.invalid,
      );
    }

    // В будущем здесь будет реальная проверка на бэкенде.
    // Сейчас любые другие ключи считаем невалидными.
    return const CloudEntitlementResult(
      success: false,
      errorMessage: 'Неверный лицензионный ключ',
      state: CloudEntitlementState.invalid,
    );
  }

  @override
  Future<CloudEntitlementState> getCachedState() async {
    if (AppRuntimeConfig.isOfflineOnlyDistribution) {
      return CloudEntitlementState.unavailable;
    }
    final SharedPreferences prefs = await _preferencesFuture;
    final String? stateStr = prefs.getString(_kEntitlementStateKey);
    if (stateStr == null) {
      return CloudEntitlementState.notActivated;
    }
    return CloudEntitlementState.values.firstWhere(
      (CloudEntitlementState e) => e.name == stateStr,
      orElse: () => CloudEntitlementState.notActivated,
    );
  }

  @override
  Future<CloudEntitlementState> refreshFromCurrentToken() async {
    if (AppRuntimeConfig.isOfflineOnlyDistribution) {
      return CloudEntitlementState.unavailable;
    }

    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      await _saveState(CloudEntitlementState.notActivated, '');
      return CloudEntitlementState.notActivated;
    }

    // Получаем свежий результат токена (claims)
    final IdTokenResult tokenResult = await user.getIdTokenResult();
    final Map<dynamic, dynamic> claims =
        tokenResult.claims ?? const <dynamic, dynamic>{};

    final bool? cloudAccess = claims['cloudAccess'] as bool?;
    final String? cloudPlan = claims['cloudPlan'] as String?;
    final int? expiresAtSec = claims['cloudAccessExpiresAt'] as int?;

    if (cloudAccess == true &&
        (cloudPlan == 'testerCloud' || cloudPlan == 'paidCloud') &&
        expiresAtSec != null) {
      final DateTime expiresAt = DateTime.fromMillisecondsSinceEpoch(
        expiresAtSec * 1000,
      );
      final CloudEntitlementState state = expiresAt.isAfter(DateTime.now())
          ? CloudEntitlementState.active
          : CloudEntitlementState.expired;

      await _saveState(state, 'custom-claims');
      return state;
    } else {
      await _saveState(CloudEntitlementState.notActivated, '');
      return CloudEntitlementState.notActivated;
    }
  }

  @override
  Future<void> clearEntitlement() async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.remove(_kEntitlementStateKey);
    await prefs.remove(_kEntitlementKeyKey);
  }

  Future<void> _saveState(CloudEntitlementState state, String key) async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.setString(_kEntitlementStateKey, state.name);
    await prefs.setString(_kEntitlementKeyKey, key);
  }
}
