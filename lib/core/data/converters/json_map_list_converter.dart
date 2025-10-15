import 'dart:convert';

import 'package:drift/drift.dart';

class JsonMapListConverter
    extends TypeConverter<List<Map<String, dynamic>>, String> {
  const JsonMapListConverter();

  @override
  List<Map<String, dynamic>> fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return const <Map<String, dynamic>>[];
    }
    final Object? decoded = json.decode(fromDb);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  @override
  String toSql(List<Map<String, dynamic>> value) {
    if (value.isEmpty) {
      return '[]';
    }
    return json.encode(value);
  }
}
