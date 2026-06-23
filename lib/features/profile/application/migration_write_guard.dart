import 'dart:async';

import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/services/sync/sync_contract.dart';
import 'package:kopim/features/profile/data/migration_freeze_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/migration_freeze_state.dart';

enum MigrationMutationOrigin {
  repositoryWrite,
  importFlow,
  backgroundMutation,
  outboxEnqueue,
}

class MigrationFreezeActive implements Exception {
  const MigrationFreezeActive({
    required this.origin,
    this.entityType,
    this.phase,
  });

  final MigrationMutationOrigin origin;
  final String? entityType;
  final String? phase;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('MigrationFreezeActive(')
      ..write(origin.name);
    if (entityType != null) {
      buffer.write(', entityType=$entityType');
    }
    if (phase != null) {
      buffer.write(', phase=$phase');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

class MigrationQuiescenceRequired implements Exception {
  const MigrationQuiescenceRequired(this.snapshot);

  final MigrationMutationActivitySnapshot snapshot;

  @override
  String toString() {
    return 'MigrationQuiescenceRequired('
        'repositoryWrites=${snapshot.activeRepositoryWrites}, '
        'importMutations=${snapshot.activeImportMutations}, '
        'backgroundMutations=${snapshot.activeBackgroundMutations}, '
        'internalWrites=${snapshot.activeMigrationInternalWrites}, '
        'persistedImportInProgress=${snapshot.persistedImportInProgress})';
  }
}

class MigrationMutationActivitySnapshot {
  const MigrationMutationActivitySnapshot({
    required this.activeRepositoryWrites,
    required this.activeImportMutations,
    required this.activeBackgroundMutations,
    required this.activeMigrationInternalWrites,
    required this.persistedImportInProgress,
  });

  final int activeRepositoryWrites;
  final int activeImportMutations;
  final int activeBackgroundMutations;
  final int activeMigrationInternalWrites;
  final bool persistedImportInProgress;

  bool get hasActiveMutations =>
      activeRepositoryWrites > 0 ||
      activeImportMutations > 0 ||
      activeBackgroundMutations > 0 ||
      activeMigrationInternalWrites > 0 ||
      persistedImportInProgress;
}

abstract class MigrationWriteGuard {
  const MigrationWriteGuard();

  Future<T> runRepositoryWrite<T>({
    required String entityType,
    required Future<T> Function() action,
  });

  Future<T> runImportMutation<T>({required Future<T> Function() action});

  Future<T> runBackgroundMutation<T>({required Future<T> Function() action});

  Future<void> ensureOutboxMutationAllowed({required String entityType});

  Future<T> runWithMigrationContext<T>(Future<T> Function() action);

  Future<void> activateFreeze({String? uid, String phase, bool uploadStarted});

  Future<void> releaseFreeze();

  Future<MigrationFreezeState?> currentState();

  Future<void> refreshState();

  Future<MigrationMutationActivitySnapshot> snapshotActivity();

  Future<void> ensureQuiescentForInventoryCapture();
}

class NoopMigrationWriteGuard extends MigrationWriteGuard {
  const NoopMigrationWriteGuard();

  @override
  Future<void> activateFreeze({
    String? uid,
    String phase = 'pre_inventory_capture',
    bool uploadStarted = false,
  }) async {}

  @override
  Future<MigrationFreezeState?> currentState() async => null;

  @override
  Future<void> ensureOutboxMutationAllowed({
    required String entityType,
  }) async {}

  @override
  Future<void> ensureQuiescentForInventoryCapture() async {}

  @override
  Future<void> refreshState() async {}

  @override
  Future<void> releaseFreeze() async {}

  @override
  Future<T> runBackgroundMutation<T>({
    required Future<T> Function() action,
  }) async {
    return action();
  }

  @override
  Future<T> runImportMutation<T>({required Future<T> Function() action}) async {
    return action();
  }

  @override
  Future<T> runRepositoryWrite<T>({
    required String entityType,
    required Future<T> Function() action,
  }) async {
    return action();
  }

  @override
  Future<T> runWithMigrationContext<T>(Future<T> Function() action) async {
    return action();
  }

  @override
  Future<MigrationMutationActivitySnapshot> snapshotActivity() async {
    return const MigrationMutationActivitySnapshot(
      activeRepositoryWrites: 0,
      activeImportMutations: 0,
      activeBackgroundMutations: 0,
      activeMigrationInternalWrites: 0,
      persistedImportInProgress: false,
    );
  }
}

class SharedPrefsMigrationWriteGuard extends MigrationWriteGuard {
  SharedPrefsMigrationWriteGuard({
    required db.AppDatabase database,
    required MigrationFreezeStateRepository stateRepository,
  }) : _database = database,
       _stateRepository = stateRepository;

  static final Set<String> _coveredEntityTypes = SyncContract.manifest
      .map((SyncEntityManifestEntry entry) => entry.outboxEntityType)
      .whereType<String>()
      .toSet();
  static final Object _zoneKey = Object();
  static final Object _executionToken = Object();

  final db.AppDatabase _database;
  final MigrationFreezeStateRepository _stateRepository;

  MigrationFreezeState? _cachedState;
  bool _hydrated = false;
  int _activeRepositoryWrites = 0;
  int _activeImportMutations = 0;
  int _activeBackgroundMutations = 0;
  int _activeMigrationInternalWrites = 0;

  @override
  Future<void> activateFreeze({
    String? uid,
    String phase = 'pre_inventory_capture',
    bool uploadStarted = false,
  }) async {
    final MigrationFreezeState state = MigrationFreezeState(
      uid: uid,
      startedAt: DateTime.now().toUtc(),
      phase: phase,
      uploadStarted: uploadStarted,
      version: 1,
    );
    await _stateRepository.saveState(state);
    _cachedState = state;
    _hydrated = true;
  }

  @override
  Future<MigrationFreezeState?> currentState() async {
    if (_hydrated) {
      return _cachedState;
    }
    _cachedState = await _stateRepository.getState();
    _hydrated = true;
    return _cachedState;
  }

  @override
  Future<void> refreshState() async {
    _hydrated = false;
    await currentState();
  }

  @override
  Future<void> releaseFreeze() async {
    await _stateRepository.clearState();
    _cachedState = null;
    _hydrated = true;
  }

  @override
  Future<T> runRepositoryWrite<T>({
    required String entityType,
    required Future<T> Function() action,
  }) async {
    return _runTracked(
      counterIncrement: () => _activeRepositoryWrites += 1,
      counterDecrement: () => _activeRepositoryWrites -= 1,
      action: () async {
        await _ensureCoveredWriteAllowed(
          entityType: entityType,
          origin: MigrationMutationOrigin.repositoryWrite,
        );
        return action();
      },
    );
  }

  @override
  Future<T> runImportMutation<T>({required Future<T> Function() action}) async {
    return _runTracked(
      counterIncrement: () => _activeImportMutations += 1,
      counterDecrement: () => _activeImportMutations -= 1,
      action: () async {
        await _ensureGlobalMutationAllowed(
          origin: MigrationMutationOrigin.importFlow,
        );
        return action();
      },
    );
  }

  @override
  Future<T> runBackgroundMutation<T>({
    required Future<T> Function() action,
  }) async {
    return _runTracked(
      counterIncrement: () => _activeBackgroundMutations += 1,
      counterDecrement: () => _activeBackgroundMutations -= 1,
      action: () async {
        await _ensureGlobalMutationAllowed(
          origin: MigrationMutationOrigin.backgroundMutation,
        );
        return action();
      },
    );
  }

  @override
  Future<void> ensureOutboxMutationAllowed({required String entityType}) async {
    await _ensureCoveredWriteAllowed(
      entityType: entityType,
      origin: MigrationMutationOrigin.outboxEnqueue,
    );
  }

  @override
  Future<T> runWithMigrationContext<T>(Future<T> Function() action) async {
    _activeMigrationInternalWrites += 1;
    try {
      return await runZoned(
        action,
        zoneValues: <Object?, Object?>{_zoneKey: _executionToken},
      );
    } finally {
      _activeMigrationInternalWrites -= 1;
    }
  }

  @override
  Future<MigrationMutationActivitySnapshot> snapshotActivity() async {
    final db.CurrentSyncStateRow? syncState =
        await (_database.select(_database.currentSyncStates)
              ..where((db.$CurrentSyncStatesTable tbl) => tbl.id.equals(1)))
            .getSingleOrNull();
    return MigrationMutationActivitySnapshot(
      activeRepositoryWrites: _activeRepositoryWrites,
      activeImportMutations: _activeImportMutations,
      activeBackgroundMutations: _activeBackgroundMutations,
      activeMigrationInternalWrites: _activeMigrationInternalWrites,
      persistedImportInProgress: syncState?.importInProgress ?? false,
    );
  }

  @override
  Future<void> ensureQuiescentForInventoryCapture() async {
    final MigrationMutationActivitySnapshot snapshot = await snapshotActivity();
    if (snapshot.hasActiveMutations) {
      throw MigrationQuiescenceRequired(snapshot);
    }
  }

  Future<T> _runTracked<T>({
    required void Function() counterIncrement,
    required void Function() counterDecrement,
    required Future<T> Function() action,
  }) async {
    counterIncrement();
    try {
      return await action();
    } finally {
      counterDecrement();
    }
  }

  Future<void> _ensureCoveredWriteAllowed({
    required String entityType,
    required MigrationMutationOrigin origin,
  }) async {
    if (_hasExecutionContext || !_coveredEntityTypes.contains(entityType)) {
      return;
    }
    final MigrationFreezeState? state = await currentState();
    if (state == null) {
      return;
    }
    throw MigrationFreezeActive(
      origin: origin,
      entityType: entityType,
      phase: state.phase,
    );
  }

  Future<void> _ensureGlobalMutationAllowed({
    required MigrationMutationOrigin origin,
  }) async {
    if (_hasExecutionContext) {
      return;
    }
    final MigrationFreezeState? state = await currentState();
    if (state == null) {
      return;
    }
    throw MigrationFreezeActive(origin: origin, phase: state.phase);
  }

  bool get _hasExecutionContext =>
      identical(Zone.current[_zoneKey], _executionToken);
}
