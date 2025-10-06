import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';

/// Offline-first repository that persists profile data to Drift and schedules
/// remote synchronization through the outbox queue.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required db.AppDatabase database,
    required ProfileDao profileDao,
    required ProfileRemoteDataSource remoteDataSource,
    required OutboxDao outboxDao,
  }) : _database = database,
       _profileDao = profileDao,
       _remoteDataSource = remoteDataSource,
       _outboxDao = outboxDao;

  static const String _entityType = 'profile';

  final db.AppDatabase _database;
  final ProfileDao _profileDao;
  final ProfileRemoteDataSource _remoteDataSource;
  final OutboxDao _outboxDao;

  @override
  Stream<Profile?> watchProfile(String uid) {
    return _profileDao.watchProfile(uid);
  }

  @override
  Future<Profile?> getProfile(String uid) async {
    final Profile? local = await _profileDao.getProfile(uid);
    final bool needsRemote =
        !_isGuestUid(uid) && (local == null || _requiresRemoteRefresh(local));

    if (!needsRemote && local != null) {
      return local;
    }

    if (_isGuestUid(uid)) {
      final Profile guestProfile = local ?? _emptyProfile(uid);
      if (local == null) {
        await _profileDao.upsert(guestProfile);
      }
      return guestProfile;
    }

    try {
      final Profile? remote = await _remoteDataSource.fetch(uid);
      if (remote == null) {
        final Profile fallbackProfile = local ?? _emptyProfile(uid);
        if (local == null) {
          await _profileDao.upsert(fallbackProfile);
        }
        return fallbackProfile;
      }
      await _profileDao.upsert(remote);
      return remote;
    } on FirebaseException catch (_) {
      final Profile fallbackProfile = local ?? _emptyProfile(uid);
      if (local == null) {
        await _profileDao.upsert(fallbackProfile);
      }
      return fallbackProfile;
    } catch (_) {
      final Profile fallbackProfile = local ?? _emptyProfile(uid);
      if (local == null) {
        await _profileDao.upsert(fallbackProfile);
      }
      return fallbackProfile;
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final DateTime now = DateTime.now().toUtc();
    final Profile toPersist = profile.copyWith(updatedAt: now);

    await _database.transaction(() async {
      await _profileDao.upsertInTransaction(toPersist);
      if (!_isGuestUid(toPersist.uid) && !_isDataUrl(toPersist.photoUrl)) {
        await _outboxDao.enqueue(
          entityType: _entityType,
          entityId: toPersist.uid,
          operation: OutboxOperation.upsert,
          payload: _mapPayload(toPersist),
        );
      }
    });

    return toPersist;
  }

  /// Produces the JSON payload stored in the outbox for later sync dispatch.
  Map<String, dynamic> _mapPayload(Profile profile) {
    return <String, dynamic>{
      'uid': profile.uid,
      'name': profile.name,
      'currency': profile.currency.name,
      'locale': profile.locale,
      'photoUrl': profile.photoUrl,
      'updatedAt': profile.updatedAt.toIso8601String(),
    };
  }

  bool _isGuestUid(String uid) => uid.startsWith('guest-');

  bool _isDataUrl(String? value) => value?.startsWith('data:') ?? false;

  bool _requiresRemoteRefresh(Profile profile) =>
      profile.updatedAt.millisecondsSinceEpoch == 0;

  Profile _emptyProfile(String uid) {
    return Profile(
      uid: uid,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
