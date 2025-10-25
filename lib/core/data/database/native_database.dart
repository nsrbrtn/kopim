import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase _openNativeConnection() {
  return LazyDatabase(() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(p.join(directory.path, 'kopim.db'));
    return NativeDatabase.createInBackground(file);
  });
}

DatabaseConnection openAppDatabaseConnection() {
  return DatabaseConnection(_openNativeConnection());
}
