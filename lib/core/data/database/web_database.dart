// ignore_for_file: deprecated_member_use

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection openAppDatabaseConnection() {
  return DatabaseConnection.delayed(
    Future(() async {
      final WasmDatabaseResult result = await WasmDatabase.open(
        databaseName: 'kopim_db',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    }),
  );
}
