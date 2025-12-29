import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/sync_status.dart';

final StreamProvider<SyncStatus> syncStatusProvider =
    StreamProvider.autoDispose<SyncStatus>((Ref ref) {
      final service = ref.watch(syncServiceProvider);
      return service.statusStream;
    });
