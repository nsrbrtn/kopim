import 'dart:convert';
import 'dart:io';

// ignore_for_file: depend_on_referenced_packages
import 'package:source_map_stack_trace/source_map_stack_trace.dart';
import 'package:source_maps/parser.dart' as parser;
import 'package:source_maps/source_maps.dart';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln(
      'Использование: dart symbolize_stack.dart <stack.txt> <main.dart.js.map>',
    );
    exit(64);
  }
  final File stackFile = File(args[0]);
  final File mapFile = File(args[1]);
  if (!stackFile.existsSync()) {
    stderr.writeln('Файл стека не найден: ${stackFile.path}');
    exit(66);
  }
  if (!mapFile.existsSync()) {
    stderr.writeln('Файл sourcemap не найден: ${mapFile.path}');
    exit(66);
  }

  final String stackText = stackFile.readAsStringSync();
  final Map<String, Object?> jsonMap =
      json.decode(mapFile.readAsStringSync()) as Map<String, Object?>;
  final String mapText = json.encode(jsonMap);
  final Mapping mapping = parser.parse(mapText);

  final StackTrace mapped = mapStackTrace(
    mapping,
    StackTrace.fromString(stackText),
    minified: true,
  );
  stdout.writeln(mapped.toString());
}
