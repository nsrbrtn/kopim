import 'package:kopim/core/services/logger_service.dart';

import 'push_permission_service_mobile.dart'
    if (dart.library.js) 'push_permission_service_web.dart'
    as implementation;

abstract class PushPermissionService {
  const PushPermissionService();

  bool get isSupported;

  Future<bool> ensurePermission({bool requestIfNeeded = true});
}

PushPermissionService createPushPermissionService({LoggerService? logger}) {
  return implementation.createPushPermissionService(logger: logger);
}
