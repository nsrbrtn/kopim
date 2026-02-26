import 'package:flutter/foundation.dart';

@immutable
class OverviewBehaviorProgress {
  const OverviewBehaviorProgress({
    required this.disciplineScore,
    required this.streakDays,
    required this.activeDays30d,
    required this.progress,
    this.windowDays = 30,
  });

  final int disciplineScore;
  final int streakDays;
  final int activeDays30d;
  final double progress;
  final int windowDays;

  bool get hasActivity => activeDays30d > 0;
}
