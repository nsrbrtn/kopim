import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_rule.freezed.dart';
part 'recurring_rule.g.dart';

enum RecurringRuleShortMonthPolicy {
  clipToLastDay('clip_to_last_day'),
  skipMonth('skip_month');

  const RecurringRuleShortMonthPolicy(this.value);
  final String value;

  static RecurringRuleShortMonthPolicy fromValue(String value) {
    return RecurringRuleShortMonthPolicy.values.firstWhere(
      (RecurringRuleShortMonthPolicy policy) => policy.value == value,
      orElse: () => RecurringRuleShortMonthPolicy.clipToLastDay,
    );
  }
}

@freezed
abstract class RecurringRule with _$RecurringRule {
  const factory RecurringRule({
    required String id,
    required String title,
    required String accountId,
    required String categoryId,
    required double amount,
    required String currency,
    required DateTime startAt,
    DateTime? endAt,
    required String timezone,
    required String rrule,
    String? notes,
    @Default(1) int dayOfMonth,
    @Default(0) int applyAtLocalHour,
    @Default(1) int applyAtLocalMinute,
    DateTime? lastRunAt,
    DateTime? nextDueLocalDate,
    @Default(true) bool isActive,
    @Default(false) bool autoPost,
    int? reminderMinutesBefore,
    @Default(RecurringRuleShortMonthPolicy.clipToLastDay)
    RecurringRuleShortMonthPolicy shortMonthPolicy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RecurringRule;

  const RecurringRule._();

  factory RecurringRule.fromJson(Map<String, dynamic> json) =>
      _$RecurringRuleFromJson(json);

  bool get hasEndDate => endAt != null;
}
