import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalProfileRepository {
  LocalProfileRepository({Future<SharedPreferences>? preferences, Uuid? uuid})
    : _preferencesFuture = preferences ?? SharedPreferences.getInstance(),
      _uuid = uuid ?? const Uuid();

  static const String _kLocalProfileIdKey = 'profile.local_profile.id';
  static const String _kLocalProfileCreatedAtKey =
      'profile.local_profile.created_at';

  final Future<SharedPreferences> _preferencesFuture;
  final Uuid _uuid;

  Future<String> restoreOrCreateProfileId() async {
    final SharedPreferences prefs = await _preferencesFuture;
    final String? existingId = prefs.getString(_kLocalProfileIdKey);
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final String newId = 'local-${_uuid.v4()}';
    await prefs.setString(_kLocalProfileIdKey, newId);
    await prefs.setString(
      _kLocalProfileCreatedAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );
    return newId;
  }

  Future<String?> getProfileId() async {
    final SharedPreferences prefs = await _preferencesFuture;
    return prefs.getString(_kLocalProfileIdKey);
  }
}
