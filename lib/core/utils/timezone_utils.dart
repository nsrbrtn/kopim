import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';

bool _timeZoneDatabaseInitialized = false;
String? _cachedTimeZoneId;
const String _timeZonePrefsKey = 'core.local_time_zone_id';

@visibleForTesting
void resetCachedTimeZoneIdForTests() {
  _cachedTimeZoneId = null;
  _timeZoneDatabaseInitialized = false;
}

Future<String> loadCurrentTimeZoneId() async {
  if (_cachedTimeZoneId != null) {
    return _cachedTimeZoneId!;
  }
  _ensureTimeZonesInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? persisted = prefs.getString(_timeZonePrefsKey);
  if (persisted != null && _isValidTimeZoneId(persisted)) {
    _cachedTimeZoneId = persisted;
    return persisted;
  }

  final String? platformTimeZoneId = await _tryResolvePlatformTimeZoneId();
  if (platformTimeZoneId != null && _isValidTimeZoneId(platformTimeZoneId)) {
    _cachedTimeZoneId = platformTimeZoneId;
    await prefs.setString(_timeZonePrefsKey, platformTimeZoneId);
    return platformTimeZoneId;
  }

  final String fallback = _resolveHeuristically();
  _cachedTimeZoneId = fallback;
  await prefs.setString(_timeZonePrefsKey, fallback);
  return fallback;
}

String resolveCurrentTimeZoneId() {
  if (_cachedTimeZoneId != null) {
    return _cachedTimeZoneId!;
  }
  _ensureTimeZonesInitialized();
  _cachedTimeZoneId = _resolveHeuristically();
  return _cachedTimeZoneId!;
}

void _ensureTimeZonesInitialized() {
  if (_timeZoneDatabaseInitialized) {
    return;
  }
  tzdata.initializeTimeZones();
  _timeZoneDatabaseInitialized = true;
}

bool _isValidTimeZoneId(String timeZoneId) {
  try {
    tz.getLocation(timeZoneId);
    return true;
  } catch (_) {
    return false;
  }
}

Future<String?> _tryResolvePlatformTimeZoneId() async {
  try {
    final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
    final String id = info.identifier.trim();
    if (id.isEmpty) {
      return null;
    }
    return id;
  } catch (_) {
    return null;
  }
}

String _resolveHeuristically() {
  final DateTime nowLocal = DateTime.now();
  final DateTime nowUtc = nowLocal.toUtc();
  final Duration offset = nowLocal.timeZoneOffset;
  final String abbreviation = nowLocal.timeZoneName;
  String? fallback;
  for (final MapEntry<String, tz.Location> entry
      in tz.timeZoneDatabase.locations.entries) {
    final tz.TZDateTime tzNow = tz.TZDateTime.from(nowUtc, entry.value);
    if (tzNow.timeZoneOffset == offset) {
      if (tzNow.timeZoneName == abbreviation) {
        return entry.key;
      }
      fallback ??= entry.key;
    }
  }
  return fallback ?? 'UTC';
}
