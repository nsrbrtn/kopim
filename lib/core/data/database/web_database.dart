// ignore_for_file: deprecated_member_use

import 'package:drift/drift.dart';
import 'package:drift/web.dart';

DatabaseConnection openAppDatabaseConnection() {
  final WebDatabase executor = WebDatabase.withStorage(
    DriftWebStorage.indexedDb('kopim_db'),
  );
  return DatabaseConnection(executor);
}
