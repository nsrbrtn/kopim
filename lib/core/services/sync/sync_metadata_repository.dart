// lib/core/services/sync/sync_metadata_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kopim/core/services/sync/sync_contract.dart';

class SyncMetadataRepository {
  SyncMetadataRepository({Future<SharedPreferences>? preferences})
    : _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferencesFuture;

  String _key(String userId, String entityType) =>
      'sync.last_pulled_ms.$userId.$entityType';

  Future<DateTime?> getLastPulledAt(String userId, String entityType) async {
    final SharedPreferences prefs = await _preferencesFuture;
    final int? ms = prefs.getInt(_key(userId, entityType));
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  Future<void> setLastPulledAt(
    String userId,
    String entityType,
    DateTime time,
  ) async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.setInt(_key(userId, entityType), time.millisecondsSinceEpoch);
  }

  Future<void> clear(String userId) async {
    final SharedPreferences prefs = await _preferencesFuture;
    for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
      if (entry.outboxEntityType != null) {
        await prefs.remove(_key(userId, entry.outboxEntityType!));
      }
    }
  }
}
