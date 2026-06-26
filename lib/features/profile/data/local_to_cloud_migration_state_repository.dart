import 'dart:convert';

import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/features/profile/domain/entities/local_to_cloud_migration_state.dart';

abstract class LocalToCloudMigrationStateRepository {
  Future<LocalToCloudMigrationState?> getStateForUid(String uid);
  Future<void> saveState(LocalToCloudMigrationState state);
  Future<void> clearStateForUid(String uid);
}

class SharedPrefsLocalToCloudMigrationStateRepository
    implements LocalToCloudMigrationStateRepository {
  SharedPrefsLocalToCloudMigrationStateRepository({
    Future<SharedPreferences>? preferences,
  }) : _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  static const String _keyPrefix = 'profile.local_to_cloud_migration_state.';

  final Future<SharedPreferences> _preferencesFuture;

  @override
  Future<LocalToCloudMigrationState?> getStateForUid(String uid) async {
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
      return LocalToCloudMigrationState.fromJson(
        decoded.cast<String, Object?>(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveState(LocalToCloudMigrationState state) async {
    final SharedPreferences prefs = await _preferencesFuture;
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

final Provider<LocalToCloudMigrationStateRepository>
localToCloudMigrationStateRepositoryProvider =
    Provider<LocalToCloudMigrationStateRepository>((Ref ref) {
      return SharedPrefsLocalToCloudMigrationStateRepository();
    });
