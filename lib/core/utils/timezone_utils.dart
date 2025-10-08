import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

bool _timeZoneDatabaseInitialized = false;
String? _cachedTimeZoneId;

String resolveCurrentTimeZoneId() {
  if (_cachedTimeZoneId != null) {
    return _cachedTimeZoneId!;
  }
  if (!_timeZoneDatabaseInitialized) {
    tzdata.initializeTimeZones();
    _timeZoneDatabaseInitialized = true;
  }
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
        _cachedTimeZoneId = entry.key;
        return _cachedTimeZoneId!;
      }
      fallback ??= entry.key;
    }
  }
  _cachedTimeZoneId = fallback ?? 'UTC';
  return _cachedTimeZoneId!;
}
