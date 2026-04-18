import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/features/getting_started/domain/entities/getting_started_preferences.dart';
import 'package:kopim/features/getting_started/domain/repositories/getting_started_preferences_repository.dart';

const String _kPreferencesKey = 'getting_started.preferences';

class GettingStartedPreferencesRepositoryImpl
    implements GettingStartedPreferencesRepository {
  GettingStartedPreferencesRepositoryImpl({
    Future<SharedPreferences>? preferences,
  }) : _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferencesFuture;

  @override
  Future<GettingStartedPreferences> load() async {
    final SharedPreferences prefs = await _preferencesFuture;
    final String? raw = prefs.getString(_kPreferencesKey);
    if (raw == null) {
      return const GettingStartedPreferences();
    }
    try {
      return GettingStartedPreferences.fromRawJson(raw);
    } catch (_) {
      return const GettingStartedPreferences();
    }
  }

  @override
  Future<void> save(GettingStartedPreferences preferences) async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.setString(_kPreferencesKey, preferences.toRawJson());
  }
}
