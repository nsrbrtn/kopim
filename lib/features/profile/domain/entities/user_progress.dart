import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';
part 'user_progress.g.dart';

@freezed
abstract class UserProgress with _$UserProgress {
  const UserProgress._();

  const factory UserProgress({
    @Default(0) int totalTx,
    @Default(1) int level,
    required String title,
    required int nextThreshold,
    required DateTime updatedAt,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);
}
