import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_job.freezed.dart';
part 'recurring_job.g.dart';

@freezed
abstract class RecurringJob with _$RecurringJob {
  const factory RecurringJob({
    required int id,
    required String type,
    required String payload,
    required DateTime runAt,
    required int attempts,
    String? lastError,
    required DateTime createdAt,
  }) = _RecurringJob;

  const RecurringJob._();

  factory RecurringJob.fromJson(Map<String, dynamic> json) =>
      _$RecurringJobFromJson(json);
}
