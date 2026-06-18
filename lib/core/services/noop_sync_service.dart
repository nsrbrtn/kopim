import 'dart:async';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/core/services/sync_status.dart';

enum NoopSyncReason { cloudSyncDisabled, blockedByLocalData }

class NoopSyncService implements SyncService {
  NoopSyncService({
    this.strict = false,
    this.reason = NoopSyncReason.cloudSyncDisabled,
  });

  final bool strict;
  final NoopSyncReason reason;

  Future<void> _guard(String method) async {
    if (strict) {
      throw StateError('$method must not be called in localOnly mode');
    }
    return;
  }

  @override
  Future<void> initialize() => _guard('initialize');

  @override
  Future<void> dispose() async {}

  @override
  Future<void> syncPending() => _guard('syncPending');

  @override
  Future<SyncActionResult> triggerSync() async {
    await _guard('triggerSync');
    return SyncActionResult.noChanges;
  }

  @override
  Future<IncrementalSyncStatus> triggerManualSync() async {
    await _guard('triggerManualSync');
    return IncrementalSyncStatus(
      result: switch (reason) {
        NoopSyncReason.cloudSyncDisabled =>
          IncrementalSyncResult.cloudSyncDisabled,
        NoopSyncReason.blockedByLocalData =>
          IncrementalSyncResult.blockedByLocalData,
      },
      pulledCount: 0,
    );
  }

  @override
  SyncStatus get status => SyncStatus.offline;

  @override
  Stream<SyncStatus> get statusStream => const Stream<SyncStatus>.empty();
}
