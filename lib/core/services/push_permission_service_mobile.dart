import 'package:kopim/core/services/logger_service.dart';

import 'push_permission_service.dart';

PushPermissionService createPushPermissionService({LoggerService? logger}) {
  return const MobilePushPermissionService();
}

class MobilePushPermissionService implements PushPermissionService {
  const MobilePushPermissionService();

  @override
  Future<bool> ensurePermission({bool requestIfNeeded = true}) async {
    return true;
  }

  @override
  bool get isSupported => true;
}
