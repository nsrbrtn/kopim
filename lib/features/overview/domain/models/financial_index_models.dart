import 'package:flutter/foundation.dart';

@immutable
class FinancialIndexWeights {
  const FinancialIndexWeights({
    this.budget = 0.30,
    this.safety = 0.30,
    this.dynamics = 0.20,
    this.discipline = 0.20,
  });

  final double budget;
  final double safety;
  final double dynamics;
  final double discipline;

  static const FinancialIndexWeights standard = FinancialIndexWeights();
}

enum FinancialIndexStatus { financialRisk, unstable, stable, confidentGrowth }

@immutable
class FinancialIndexFactors {
  const FinancialIndexFactors({
    required this.budgetScore,
    required this.safetyScore,
    required this.dynamicsScore,
    required this.disciplineScore,
  });

  final double budgetScore;
  final double safetyScore;
  final double dynamicsScore;
  final double disciplineScore;

  FinancialIndexFactors normalized() {
    return FinancialIndexFactors(
      budgetScore: budgetScore.clamp(0, 100).toDouble(),
      safetyScore: safetyScore.clamp(0, 100).toDouble(),
      dynamicsScore: dynamicsScore.clamp(0, 100).toDouble(),
      disciplineScore: disciplineScore.clamp(0, 100).toDouble(),
    );
  }
}

@immutable
class FinancialIndexSnapshot {
  const FinancialIndexSnapshot({
    required this.totalScore,
    required this.status,
    required this.factors,
  });

  final int totalScore;
  final FinancialIndexStatus status;
  final FinancialIndexFactors factors;
}

@immutable
class FinancialIndexMonthlyPoint {
  const FinancialIndexMonthlyPoint({required this.month, required this.score});

  final DateTime month;
  final int score;
}

@immutable
class FinancialIndexSeries {
  const FinancialIndexSeries({required this.current, required this.monthly});

  final FinancialIndexSnapshot current;
  final List<FinancialIndexMonthlyPoint> monthly;
}
