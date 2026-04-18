import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_progress.dart';

void main() {
  group('GettingStartedProgress', () {
    test('вычисляет активный шаг и блокирует следующие шаги по порядку', () {
      const GettingStartedProgress progress = GettingStartedProgress(
        hasAccounts: true,
        hasUserCategories: false,
        hasTransactions: false,
        hasProfileName: false,
        hasSavingGoal: false,
        hasBudget: false,
      );

      expect(progress.currentStep, GettingStartedStepId.category);
      expect(progress.isStepLocked(GettingStartedStepId.transaction), isTrue);
      expect(progress.isStepLocked(GettingStartedStepId.profile), isTrue);
      expect(progress.completedStepsCount, 1);
      expect(progress.isCompleted, isFalse);
    });

    test('считает meaningful data при наличии бюджета даже без цели', () {
      const GettingStartedProgress progress = GettingStartedProgress(
        hasAccounts: false,
        hasUserCategories: false,
        hasTransactions: false,
        hasProfileName: false,
        hasSavingGoal: false,
        hasBudget: true,
      );

      expect(progress.hasMeaningfulData, isTrue);
      expect(progress.currentStep, GettingStartedStepId.account);
    });

    test(
      'считает чеклист завершенным только после всех обязательных шагов',
      () {
        const GettingStartedProgress progress = GettingStartedProgress(
          hasAccounts: true,
          hasUserCategories: true,
          hasTransactions: true,
          hasProfileName: true,
          hasSavingGoal: true,
          hasBudget: false,
        );

        expect(progress.isCompleted, isTrue);
        expect(progress.currentStep, isNull);
        expect(progress.completedStepsCount, progress.totalStepsCount);
      },
    );
  });
}
