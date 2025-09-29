import 'dart:async';

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
    if (local != null) {
      return local;
    }
    final Profile? remote = await _remoteDataSource.fetch(uid);
    if (remote == null) {
      return null;
    }
    await _profileDao.upsert(remote);
    return remote;
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final DateTime now = DateTime.now().toUtc();
    final Profile toPersist = profile.copyWith(updatedAt: now);

    await _database.transaction(() async {
      await _profileDao.upsertInTransaction(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.uid,
        operation: OutboxOperation.upsert,
        payload: _mapPayload(toPersist),
      );
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
      'updatedAt': profile.updatedAt.toIso8601String(),
    };
  }
}
