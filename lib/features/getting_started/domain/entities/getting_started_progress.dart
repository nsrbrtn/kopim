enum GettingStartedStepId { account, category, transaction, profile, goal }

class GettingStartedProgress {
  const GettingStartedProgress({
    required this.hasAccounts,
    required this.hasUserCategories,
    required this.hasTransactions,
    required this.hasProfileName,
    required this.hasSavingGoal,
    required this.hasBudget,
  });

  final bool hasAccounts;
  final bool hasUserCategories;
  final bool hasTransactions;
  final bool hasProfileName;
  final bool hasSavingGoal;
  final bool hasBudget;

  static const List<GettingStartedStepId> orderedSteps = <GettingStartedStepId>[
    GettingStartedStepId.account,
    GettingStartedStepId.category,
    GettingStartedStepId.transaction,
    GettingStartedStepId.profile,
    GettingStartedStepId.goal,
  ];

  bool isStepComplete(GettingStartedStepId stepId) {
    return switch (stepId) {
      GettingStartedStepId.account => hasAccounts,
      GettingStartedStepId.category => hasUserCategories,
      GettingStartedStepId.transaction => hasTransactions,
      GettingStartedStepId.profile => hasProfileName,
      GettingStartedStepId.goal => hasSavingGoal,
    };
  }

  bool get hasMeaningfulData =>
      hasAccounts ||
      hasUserCategories ||
      hasTransactions ||
      hasProfileName ||
      hasSavingGoal ||
      hasBudget;

  int get completedStepsCount => orderedSteps.where(isStepComplete).length;

  int get totalStepsCount => orderedSteps.length;

  bool get isCompleted => completedStepsCount == totalStepsCount;

  GettingStartedStepId? get currentStep {
    for (final GettingStartedStepId stepId in orderedSteps) {
      if (!isStepComplete(stepId)) {
        return stepId;
      }
    }
    return null;
  }

  bool isStepLocked(GettingStartedStepId stepId) {
    final GettingStartedStepId? activeStep = currentStep;
    if (activeStep == null || isStepComplete(stepId)) {
      return false;
    }
    return orderedSteps.indexOf(stepId) > orderedSteps.indexOf(activeStep);
  }
}
