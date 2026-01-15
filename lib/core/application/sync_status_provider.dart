import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/core/services/sync_status.dart';

final StreamProvider<SyncStatus> syncStatusProvider =
    StreamProvider.autoDispose<SyncStatus>((Ref ref) {
      final SyncService service = ref.watch(syncServiceProvider);
      return (() async* {
        yield service.status;
        yield* service.statusStream;
      })();
    });
