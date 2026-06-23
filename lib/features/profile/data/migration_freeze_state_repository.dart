import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/features/profile/domain/entities/migration_freeze_state.dart';

abstract class MigrationFreezeStateRepository {
  Future<MigrationFreezeState?> getState();
  Future<void> saveState(MigrationFreezeState state);
  Future<void> clearState();
}

class SharedPrefsMigrationFreezeStateRepository
    implements MigrationFreezeStateRepository {
  SharedPrefsMigrationFreezeStateRepository({
    Future<SharedPreferences>? preferences,
  }) : _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  static const String _key = 'profile.migration_freeze_state';
  final Future<SharedPreferences> _preferencesFuture;

  @override
  Future<MigrationFreezeState?> getState() async {
    final SharedPreferences prefs = await _preferencesFuture;
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return MigrationFreezeState.fromJson(decoded.cast<String, Object?>());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveState(MigrationFreezeState state) async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  @override
  Future<void> clearState() async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.remove(_key);
  }
}
