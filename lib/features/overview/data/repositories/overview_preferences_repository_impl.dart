import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/features/overview/domain/entities/overview_preferences.dart';
import 'package:kopim/features/overview/domain/repositories/overview_preferences_repository.dart';

const String _kPreferencesKey = 'overview.preferences';

class OverviewPreferencesRepositoryImpl
    implements OverviewPreferencesRepository {
  OverviewPreferencesRepositoryImpl({Future<SharedPreferences>? preferences})
    : _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferencesFuture;

  @override
  Future<OverviewPreferences> load() async {
    final SharedPreferences prefs = await _preferencesFuture;
    final String? raw = prefs.getString(_kPreferencesKey);
    if (raw == null) {
      return const OverviewPreferences();
    }
    try {
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return OverviewPreferences.fromJson(json);
    } catch (_) {
      return const OverviewPreferences();
    }
  }

  @override
  Future<void> save(OverviewPreferences preferences) async {
    final SharedPreferences prefs = await _preferencesFuture;
    final String raw = jsonEncode(preferences.toJson());
    await prefs.setString(_kPreferencesKey, raw);
  }
}
