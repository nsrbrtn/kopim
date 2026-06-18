import 'dart:async';
import 'package:flutter/foundation.dart';
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
  Future<void> clearEntitlement();
}

class CloudEntitlementRepositoryImpl implements CloudEntitlementRepository {
  CloudEntitlementRepositoryImpl({Future<SharedPreferences>? preferences})
    : _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  static const String demoCloudKey = 'DEMO-CLOUD-KEY';
  static const String _kEntitlementStateKey = 'profile.entitlement.state';
  static const String _kEntitlementKeyKey = 'profile.entitlement.key';

  final Future<SharedPreferences> _preferencesFuture;

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

    // Тестовый ключ доступен только для внутренних cloud-flavor сборок.
    if (trimmedKey == demoCloudKey) {
      final bool isInternalCloudBuild =
          kDebugMode ||
          AppRuntimeConfig.flavor == AppRuntimeFlavor.firebaseDev ||
          AppRuntimeConfig.flavor == AppRuntimeFlavor.firebaseProd;
      if (!isInternalCloudBuild) {
        return const CloudEntitlementResult(
          success: false,
          errorMessage: 'Недействительный ключ доступа',
          state: CloudEntitlementState.invalid,
        );
      }

      await _saveState(CloudEntitlementState.active, trimmedKey);
      return const CloudEntitlementResult(
        success: true,
        state: CloudEntitlementState.active,
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
