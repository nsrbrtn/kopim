import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Строит детерминированный идентификатор повторяющегося события
/// по сочетанию `ruleId` и момента наступления в UTC.
String buildRecurringOccurrenceId({
  required String ruleId,
  required DateTime dueAt,
}) {
  final DateTime normalized = dueAt.toUtc();
  final String raw = '$ruleId@${normalized.toIso8601String()}';
  return sha1.convert(utf8.encode(raw)).toString();
}
