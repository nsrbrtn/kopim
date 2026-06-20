import 'dart:convert';

import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/features/profile/domain/entities/cloud_activation_state.dart';

abstract class CloudActivationStateRepository {
  Future<CloudActivationState?> getStateForUid(String uid);
  Future<void> saveEnabledState({
    required String uid,
    required String scenario,
    required String? localFingerprint,
    required String? remoteFingerprint,
  });
  Future<void> clearStateForUid(String uid);
}

class SharedPrefsCloudActivationStateRepository
    implements CloudActivationStateRepository {
  SharedPrefsCloudActivationStateRepository({
    Future<SharedPreferences>? preferences,
  }) : _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  static const String _keyPrefix = 'profile.cloud_activation_state.';
  static const int _stateVersion = 1;

  final Future<SharedPreferences> _preferencesFuture;

  @override
  Future<CloudActivationState?> getStateForUid(String uid) async {
    final String normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) {
      return null;
    }

    final SharedPreferences prefs = await _preferencesFuture;
    final String? raw = prefs.getString(_key(normalizedUid));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return CloudActivationState.fromJson(decoded.cast<String, Object?>());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveEnabledState({
    required String uid,
    required String scenario,
    required String? localFingerprint,
    required String? remoteFingerprint,
  }) async {
    final SharedPreferences prefs = await _preferencesFuture;
    final CloudActivationState state = CloudActivationState(
      uid: uid.trim(),
      scenario: scenario,
      activatedAt: DateTime.now().toUtc(),
      localFingerprint: localFingerprint,
      remoteFingerprint: remoteFingerprint,
      version: _stateVersion,
    );
    await prefs.setString(_key(state.uid), jsonEncode(state.toJson()));
  }

  @override
  Future<void> clearStateForUid(String uid) async {
    final String normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) {
      return;
    }
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.remove(_key(normalizedUid));
  }

  String _key(String uid) => '$_keyPrefix$uid';
}

final Provider<CloudActivationStateRepository>
cloudActivationStateRepositoryProvider =
    Provider<CloudActivationStateRepository>((Ref ref) {
      return SharedPrefsCloudActivationStateRepository();
    });
