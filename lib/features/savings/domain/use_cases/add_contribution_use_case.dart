import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';

import '../entities/saving_goal.dart';
import '../repositories/saving_goal_repository.dart';
import '../value_objects/money.dart';

class AddContributionUseCase {
  AddContributionUseCase({
    required SavingGoalRepository repository,
    required AddTransactionUseCase addTransactionUseCase,
    DateTime Function()? clock,
  }) : _repository = repository,
       _addTransactionUseCase = addTransactionUseCase,
       _clock = clock ?? DateTime.now;

  static const String savingsCategoryId = 'savings';

  final SavingGoalRepository _repository;
  final AddTransactionUseCase _addTransactionUseCase;
  final DateTime Function() _clock;

  Future<SavingGoal> call({
    required String goalId,
    required Money amount,
    String? sourceAccountId,
    String? note,
  }) async {
    if (amount.minorUnits <= 0) {
      throw ArgumentError.value(
        amount.minorUnits,
        'amount',
        'Contribution amount must be greater than zero',
      );
    }
    final SavingGoal? goal = await _repository.findById(goalId);
    if (goal == null) {
      throw StateError('Saving goal not found');
    }
    if (goal.isArchived) {
      throw StateError('Cannot contribute to archived goals');
    }
    if (goal.currentAmount >= goal.targetAmount) {
      throw StateError('Goal already reached');
    }
    final DateTime now = _clock().toUtc();
    final int desiredAmount = goal.currentAmount + amount.minorUnits;
    final int cappedAmount = desiredAmount > goal.targetAmount
        ? goal.targetAmount
        : desiredAmount;
    final int appliedDelta = cappedAmount - goal.currentAmount;
    if (appliedDelta <= 0) {
      throw StateError('Contribution does not change goal progress');
    }
    final SavingGoal updatedGoal = goal.copyWith(
      currentAmount: cappedAmount,
      updatedAt: now,
    );

    final String? trimmedNote = note?.trim().isNotEmpty ?? false
        ? note!.trim()
        : null;

    if (sourceAccountId != null && sourceAccountId.isNotEmpty) {
      final String baseNote = 'Savings: ${goal.name}';
      final String composedNote = trimmedNote != null
          ? '$baseNote — $trimmedNote'
          : baseNote;
      await _addTransactionUseCase(
        AddTransactionRequest(
          accountId: sourceAccountId,
          categoryId: savingsCategoryId,
          amount: amount.toDouble(),
          date: now,
          note: composedNote,
          type: TransactionType.expense,
        ),
      );
    }

    await _repository.addContribution(
      updatedGoal: updatedGoal,
      contributionAmount: appliedDelta,
      sourceAccountId: sourceAccountId,
      contributionNote: trimmedNote,
    );
    return updatedGoal;
  }
}
