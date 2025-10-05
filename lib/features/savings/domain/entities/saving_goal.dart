import 'package:freezed_annotation/freezed_annotation.dart';

part 'saving_goal.freezed.dart';
part 'saving_goal.g.dart';

@freezed
abstract class SavingGoal with _$SavingGoal {
  const SavingGoal._();

  const factory SavingGoal({
    required String id,
    required String userId,
    required String name,
    required int targetAmount,
    required int currentAmount,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? archivedAt,
  }) = _SavingGoal;

  factory SavingGoal.fromJson(Map<String, dynamic> json) =>
      _$SavingGoalFromJson(json);

  bool get isArchived => archivedAt != null;

  int get remainingAmount => targetAmount - currentAmount;
}
