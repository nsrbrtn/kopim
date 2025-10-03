import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_occurrence.freezed.dart';
part 'recurring_occurrence.g.dart';

enum RecurringOccurrenceStatus {
  scheduled('scheduled'),
  posted('posted'),
  skipped('skipped'),
  failed('failed');

  const RecurringOccurrenceStatus(this.value);
  final String value;

  static RecurringOccurrenceStatus fromValue(String value) {
    return RecurringOccurrenceStatus.values.firstWhere(
      (RecurringOccurrenceStatus status) => status.value == value,
      orElse: () => RecurringOccurrenceStatus.scheduled,
    );
  }
}

@freezed
abstract class RecurringOccurrence with _$RecurringOccurrence {
  const factory RecurringOccurrence({
    required String id,
    required String ruleId,
    required DateTime dueAt,
    @Default(RecurringOccurrenceStatus.scheduled)
    RecurringOccurrenceStatus status,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? postedTxId,
  }) = _RecurringOccurrence;

  const RecurringOccurrence._();

  factory RecurringOccurrence.fromJson(Map<String, dynamic> json) =>
      _$RecurringOccurrenceFromJson(json);
}
