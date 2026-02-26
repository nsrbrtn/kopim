import 'package:kopim/features/overview/domain/models/financial_index_models.dart';

class FinancialIndexCalculator {
  const FinancialIndexCalculator._();

  static const int minScore = 0;
  static const int maxScore = 100;

  static FinancialIndexSnapshot calculate({
    required FinancialIndexFactors factors,
    FinancialIndexWeights weights = FinancialIndexWeights.standard,
  }) {
    final FinancialIndexFactors normalized = factors.normalized();

    final double weightedValue =
        normalized.budgetScore * weights.budget +
        normalized.safetyScore * weights.safety +
        normalized.dynamicsScore * weights.dynamics +
        normalized.disciplineScore * weights.discipline;

    final int totalScore = weightedValue.round().clamp(minScore, maxScore);

    return FinancialIndexSnapshot(
      totalScore: totalScore,
      status: resolveStatus(totalScore),
      factors: normalized,
    );
  }

  static FinancialIndexStatus resolveStatus(int score) {
    final int normalizedScore = score.clamp(minScore, maxScore);
    if (normalizedScore < 40) {
      return FinancialIndexStatus.financialRisk;
    }
    if (normalizedScore < 60) {
      return FinancialIndexStatus.unstable;
    }
    if (normalizedScore < 80) {
      return FinancialIndexStatus.stable;
    }
    return FinancialIndexStatus.confidentGrowth;
  }
}
