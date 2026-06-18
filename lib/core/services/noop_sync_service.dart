import 'dart:async';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/core/services/sync_status.dart';

class NoopSyncService implements SyncService {
  NoopSyncService({this.strict = false});

  final bool strict;

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
    return const IncrementalSyncStatus(
      result: IncrementalSyncResult.noChanges,
      pulledCount: 0,
    );
  }

  @override
  SyncStatus get status => SyncStatus.offline;

  @override
  Stream<SyncStatus> get statusStream => const Stream<SyncStatus>.empty();
}
