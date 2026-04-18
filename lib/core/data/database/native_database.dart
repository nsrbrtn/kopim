import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase _openNativeConnection() {
  return LazyDatabase(() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String databaseName = AppRuntimeConfig.isOffline
        ? 'kopim_offline.db'
        : 'kopim.db';
    final File file = File(p.join(directory.path, databaseName));
    return NativeDatabase.createInBackground(file);
  });
}

DatabaseConnection openAppDatabaseConnection() {
  return DatabaseConnection(_openNativeConnection());
}
