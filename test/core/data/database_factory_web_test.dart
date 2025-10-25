@TestOn('browser')
// ignore_for_file: deprecated_member_use
library database_factory_web_test; // ignore: unnecessary_library_name

import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/database/database_factory.dart';

void main() {
  test('constructDb создаёт AppDatabase и выполняет базовый запрос', () async {
    final AppDatabase database = constructDb();
    addTearDown(database.close);

    final int value = await database
        .customSelect('SELECT 1 AS value')
        .map((QueryRow row) => row.read<int>('value'))
        .getSingle();
    expect(value, 1);
    expect(database.executor, isA<WebDatabase>());
  });
}
