import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/domain/repositories/home_dashboard_preferences_repository.dart';

const String _kPreferencesKey = 'home.dashboard.preferences';

class HomeDashboardPreferencesRepositoryImpl
    implements HomeDashboardPreferencesRepository {
  HomeDashboardPreferencesRepositoryImpl({
    Future<SharedPreferences>? preferences,
  }) : _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferencesFuture;

  @override
  Future<HomeDashboardPreferences> load() async {
    final SharedPreferences prefs = await _preferencesFuture;
    final String? raw = prefs.getString(_kPreferencesKey);
    if (raw == null) {
      return const HomeDashboardPreferences();
    }
    try {
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return HomeDashboardPreferences.fromJson(json);
    } catch (_) {
      return const HomeDashboardPreferences();
    }
  }

  @override
  Future<void> save(HomeDashboardPreferences preferences) async {
    final SharedPreferences prefs = await _preferencesFuture;
    final String raw = jsonEncode(preferences.toJson());
    await prefs.setString(_kPreferencesKey, raw);
  }
}
