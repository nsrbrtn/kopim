import 'package:riverpod/riverpod.dart';

enum SyncPauseReason {
  rollbackReplaceLocalWithCloud,
  replaceLocalWithCloudInitialPull,
  importData,
}

class SyncDispatchGuard {
  final Set<SyncPauseReason> _activeReasons = <SyncPauseReason>{};

  bool get isPaused => _activeReasons.isNotEmpty;

  void pause(SyncPauseReason reason) {
    _activeReasons.add(reason);
  }

  void resume(SyncPauseReason reason) {
    _activeReasons.remove(reason);
  }
}

final Provider<SyncDispatchGuard> syncDispatchGuardProvider =
    Provider<SyncDispatchGuard>((Ref ref) {
      return SyncDispatchGuard();
    });
