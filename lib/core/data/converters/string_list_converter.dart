import 'dart:convert';

import 'package:drift/drift.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return const <String>[];
    }
    try {
      final Object? decoded = jsonDecode(fromDb);
      if (decoded is List) {
        return decoded
            .whereType<Object?>()
            .map((Object? value) => value?.toString() ?? '')
            .where((String value) => value.isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {
      // Fallback to treating the stored string as comma-separated values.
      return fromDb
          .split(',')
          .map((String value) => value.trim())
          .where((String value) => value.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  @override
  String toSql(List<String> value) {
    if (value.isEmpty) {
      return '[]';
    }
    return jsonEncode(value);
  }
}
