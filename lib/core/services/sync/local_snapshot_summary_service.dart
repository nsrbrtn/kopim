import 'package:drift/drift.dart';
import 'package:riverpod/riverpod.dart';

import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

class LocalSnapshotSummaryService {
  const LocalSnapshotSummaryService({
    required AppDatabase database,
    required OutboxDao outboxDao,
  }) : _database = database,
       _outboxDao = outboxDao;

  final AppDatabase _database;
  final OutboxDao _outboxDao;

  Future<LocalSnapshotSummary> summarize() async {
    final int pendingOutboxCount = await _outboxDao.pendingCount();
    final bool hasUserData = await _database.hasAnyUserData();
    final bool hasSystemData = await _hasSystemData();

    final LocalSnapshotState state = switch ((
      pendingOutboxCount,
      hasUserData,
      hasSystemData,
    )) {
      (final int count, _, _) when count > 0 =>
        LocalSnapshotState.hasPendingOutbox,
      (0, true, _) => LocalSnapshotState.hasUserData,
      (0, false, true) => LocalSnapshotState.hasOnlySystemData,
      _ => LocalSnapshotState.empty,
    };

    return LocalSnapshotSummary(
      state: state,
      hasUserData: hasUserData,
      hasSystemData: hasSystemData,
      pendingOutboxCount: pendingOutboxCount,
      fingerprint:
          'local:${state.name}|user:$hasUserData|system:$hasSystemData|outbox:$pendingOutboxCount',
    );
  }

  Future<bool> _hasSystemData() async {
    final List<QueryRow> systemCategories = await _database
        .customSelect('SELECT 1 FROM categories WHERE is_system = 1 LIMIT 1')
        .get();
    if (systemCategories.isNotEmpty) {
      return true;
    }

    final List<QueryRow> profiles = await _database
        .customSelect('SELECT 1 FROM profiles LIMIT 1')
        .get();
    return profiles.isNotEmpty;
  }
}

final Provider<LocalSnapshotSummaryService>
localSnapshotSummaryServiceProvider = Provider<LocalSnapshotSummaryService>((
  Ref ref,
) {
  return LocalSnapshotSummaryService(
    database: ref.watch(appDatabaseProvider),
    outboxDao: ref.watch(outboxDaoProvider),
  );
});
