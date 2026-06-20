import 'package:riverpod/riverpod.dart';

class CloudActivationRuntimeGuard {
  bool _inProgress = false;

  bool get isInProgress => _inProgress;

  bool tryAcquire() {
    if (_inProgress) {
      return false;
    }
    _inProgress = true;
    return true;
  }

  void release() {
    _inProgress = false;
  }
}

final Provider<CloudActivationRuntimeGuard>
cloudActivationRuntimeGuardProvider = Provider<CloudActivationRuntimeGuard>((
  Ref ref,
) {
  return CloudActivationRuntimeGuard();
});
