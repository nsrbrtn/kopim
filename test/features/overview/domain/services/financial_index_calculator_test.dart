import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/overview/domain/models/financial_index_models.dart';
import 'package:kopim/features/overview/domain/services/financial_index_calculator.dart';

void main() {
  group('FinancialIndexCalculator', () {
    test('считает итоговый индекс по формуле из спецификации', () {
      final FinancialIndexSnapshot snapshot =
          FinancialIndexCalculator.calculate(
            factors: const FinancialIndexFactors(
              budgetScore: 80,
              safetyScore: 60,
              dynamicsScore: 70,
              disciplineScore: 90,
            ),
          );

      expect(snapshot.totalScore, 74);
      expect(snapshot.status, FinancialIndexStatus.stable);
    });

    test('ограничивает значения факторов и итог в диапазоне 0..100', () {
      final FinancialIndexSnapshot snapshot =
          FinancialIndexCalculator.calculate(
            factors: const FinancialIndexFactors(
              budgetScore: -120,
              safetyScore: 250,
              dynamicsScore: 70,
              disciplineScore: 90,
            ),
          );

      expect(snapshot.factors.budgetScore, 0);
      expect(snapshot.factors.safetyScore, 100);
      expect(snapshot.totalScore, 62);
    });

    test('возвращает корректные статусы на границах диапазонов', () {
      expect(
        FinancialIndexCalculator.resolveStatus(0),
        FinancialIndexStatus.financialRisk,
      );
      expect(
        FinancialIndexCalculator.resolveStatus(39),
        FinancialIndexStatus.financialRisk,
      );
      expect(
        FinancialIndexCalculator.resolveStatus(40),
        FinancialIndexStatus.unstable,
      );
      expect(
        FinancialIndexCalculator.resolveStatus(59),
        FinancialIndexStatus.unstable,
      );
      expect(
        FinancialIndexCalculator.resolveStatus(60),
        FinancialIndexStatus.stable,
      );
      expect(
        FinancialIndexCalculator.resolveStatus(79),
        FinancialIndexStatus.stable,
      );
      expect(
        FinancialIndexCalculator.resolveStatus(80),
        FinancialIndexStatus.confidentGrowth,
      );
      expect(
        FinancialIndexCalculator.resolveStatus(100),
        FinancialIndexStatus.confidentGrowth,
      );
    });
  });
}
