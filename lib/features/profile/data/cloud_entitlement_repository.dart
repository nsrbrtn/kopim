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

class CloudEntitlementSnapshot {
  const CloudEntitlementSnapshot({
    required this.state,
    this.plan,
    this.accessUntilMillis,
    this.source,
    this.updatedAtMillis,
  });

  final CloudEntitlementState state;
  final String? plan;
  final int? accessUntilMillis;
  final String? source;
  final int? updatedAtMillis;
}

abstract class CloudEntitlementRepository {
  Future<CloudEntitlementResult> activateKey(String key);
  Future<CloudEntitlementState> getCachedState();
  Future<CloudEntitlementSnapshot> getCachedSnapshot() async {
    return CloudEntitlementSnapshot(state: await getCachedState());
  }

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
  static const String _kEntitlementSourceKey = 'profile.entitlement.source';
  static const String _kEntitlementPlanKey = 'profile.entitlement.plan';
  static const String _kEntitlementAccessUntilKey =
      'profile.entitlement.access_until_millis';
  static const String _kEntitlementUpdatedAtKey =
      'profile.entitlement.updated_at_millis';
  static const String _kLegacyEntitlementKeyKey = 'profile.entitlement.key';
  static const Set<String> _kAllowedCloudPlans = <String>{
    'trial',
    'paid',
    'manual',
  };

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
    return (await getCachedSnapshot()).state;
  }

  @override
  Future<CloudEntitlementSnapshot> getCachedSnapshot() async {
    if (AppRuntimeConfig.isOfflineOnlyDistribution) {
      return const CloudEntitlementSnapshot(
        state: CloudEntitlementState.unavailable,
        source: 'build-offline',
      );
    }
    final SharedPreferences prefs = await _preferencesFuture;
    final String? stateStr = prefs.getString(_kEntitlementStateKey);
    final CloudEntitlementState state = stateStr == null
        ? CloudEntitlementState.notActivated
        : CloudEntitlementState.values.firstWhere(
            (CloudEntitlementState e) => e.name == stateStr,
            orElse: () => CloudEntitlementState.notActivated,
          );
    return CloudEntitlementSnapshot(
      state: state,
      plan: _readStringClaim(prefs.getString(_kEntitlementPlanKey)),
      accessUntilMillis: prefs.getInt(_kEntitlementAccessUntilKey),
      source: _readStringClaim(prefs.getString(_kEntitlementSourceKey)),
      updatedAtMillis: prefs.getInt(_kEntitlementUpdatedAtKey),
    );
  }

  @override
  Future<CloudEntitlementState> refreshFromCurrentToken() async {
    if (AppRuntimeConfig.isOfflineOnlyDistribution) {
      return CloudEntitlementState.unavailable;
    }

    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      await _saveSnapshot(
        const CloudEntitlementSnapshot(
          state: CloudEntitlementState.notActivated,
          source: 'signed-out',
        ),
      );
      return CloudEntitlementState.notActivated;
    }

    final IdTokenResult tokenResult = await user.getIdTokenResult();
    final Map<dynamic, dynamic> claims =
        tokenResult.claims ?? const <dynamic, dynamic>{};

    final bool? cloudAccess = claims['cloudAccess'] as bool?;
    final String? cloudPlan = _readStringClaim(claims['cloudPlan']);
    final int? accessUntilMillis = _readIntClaim(
      claims['cloudAccessUntilMillis'],
    );

    if (cloudAccess != true ||
        cloudPlan == null ||
        !_kAllowedCloudPlans.contains(cloudPlan) ||
        accessUntilMillis == null) {
      await _saveSnapshot(
        const CloudEntitlementSnapshot(
          state: CloudEntitlementState.notActivated,
          source: 'claims-invalid',
        ),
      );
      return CloudEntitlementState.notActivated;
    }

    final CloudEntitlementState state =
        accessUntilMillis > DateTime.now().millisecondsSinceEpoch
        ? CloudEntitlementState.active
        : CloudEntitlementState.expired;

    await _saveSnapshot(
      CloudEntitlementSnapshot(
        state: state,
        plan: cloudPlan,
        accessUntilMillis: accessUntilMillis,
        source: 'claims:$cloudPlan',
      ),
    );
    return state;
  }

  @override
  Future<void> clearEntitlement() async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.remove(_kEntitlementStateKey);
    await prefs.remove(_kEntitlementSourceKey);
    await prefs.remove(_kEntitlementPlanKey);
    await prefs.remove(_kEntitlementAccessUntilKey);
    await prefs.remove(_kEntitlementUpdatedAtKey);
    await prefs.remove(_kLegacyEntitlementKeyKey);
  }

  Future<void> _saveSnapshot(CloudEntitlementSnapshot snapshot) async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.setString(_kEntitlementStateKey, snapshot.state.name);
    if (snapshot.source != null && snapshot.source!.isNotEmpty) {
      await prefs.setString(_kEntitlementSourceKey, snapshot.source!);
    } else {
      await prefs.remove(_kEntitlementSourceKey);
    }
    if (snapshot.plan != null && snapshot.plan!.isNotEmpty) {
      await prefs.setString(_kEntitlementPlanKey, snapshot.plan!);
    } else {
      await prefs.remove(_kEntitlementPlanKey);
    }
    if (snapshot.accessUntilMillis != null) {
      await prefs.setInt(
        _kEntitlementAccessUntilKey,
        snapshot.accessUntilMillis!,
      );
    } else {
      await prefs.remove(_kEntitlementAccessUntilKey);
    }
    await prefs.setInt(
      _kEntitlementUpdatedAtKey,
      snapshot.updatedAtMillis ?? DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.remove(_kLegacyEntitlementKeyKey);
  }

  String? _readStringClaim(Object? value) {
    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  int? _readIntClaim(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }
}
