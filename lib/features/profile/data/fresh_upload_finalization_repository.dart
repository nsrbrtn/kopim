import 'dart:convert';

import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/features/profile/domain/entities/fresh_upload_finalization_marker.dart';

abstract class FreshUploadFinalizationRepository {
  Future<FreshUploadFinalizationMarker?> getMarkerForUid(String uid);
  Future<void> saveCompleted({
    required String uid,
    required String uploadSessionId,
    required DateTime remoteStateConfirmedAt,
    required DateTime localFinalizationCompletedAt,
  });
  Future<void> clearMarkerForUid(String uid);
}

class SharedPrefsFreshUploadFinalizationRepository
    implements FreshUploadFinalizationRepository {
  SharedPrefsFreshUploadFinalizationRepository({
    Future<SharedPreferences>? preferences,
  }) : _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  static const String _keyPrefix = 'profile.fresh_upload_finalization.';
  static const int _version = 1;

  final Future<SharedPreferences> _preferencesFuture;

  @override
  Future<FreshUploadFinalizationMarker?> getMarkerForUid(String uid) async {
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
      return FreshUploadFinalizationMarker.fromJson(
        decoded.cast<String, Object?>(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCompleted({
    required String uid,
    required String uploadSessionId,
    required DateTime remoteStateConfirmedAt,
    required DateTime localFinalizationCompletedAt,
  }) async {
    final FreshUploadFinalizationMarker marker = FreshUploadFinalizationMarker(
      uid: uid.trim(),
      uploadSessionId: uploadSessionId.trim(),
      remoteStateConfirmedAt: remoteStateConfirmedAt.toUtc(),
      localFinalizationCompletedAt: localFinalizationCompletedAt.toUtc(),
      version: _version,
    );
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.setString(_key(marker.uid), jsonEncode(marker.toJson()));
  }

  @override
  Future<void> clearMarkerForUid(String uid) async {
    final String normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) {
      return;
    }
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.remove(_key(normalizedUid));
  }

  String _key(String uid) => '$_keyPrefix$uid';
}

final Provider<FreshUploadFinalizationRepository>
freshUploadFinalizationRepositoryProvider =
    Provider<FreshUploadFinalizationRepository>((Ref ref) {
      return SharedPrefsFreshUploadFinalizationRepository();
    });
