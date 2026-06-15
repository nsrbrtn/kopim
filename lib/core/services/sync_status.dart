enum SyncStatus { offline, syncing, upToDate }

enum SyncActionResult {
  synced,
  offline,
  unauthenticated,
  alreadySyncing,
  noChanges,
}

enum IncrementalSyncResult {
  success,
  pushFailed,
  offline,
  unauthenticated,
  alreadySyncing,
  noChanges,
  error,
}

class IncrementalSyncStatus {
  const IncrementalSyncStatus({
    required this.result,
    this.pulledCount = 0,
    this.errorMessage,
  });

  final IncrementalSyncResult result;
  final int pulledCount;
  final String? errorMessage;
}
