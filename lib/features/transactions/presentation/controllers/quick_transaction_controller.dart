import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';

enum QuickTransactionError { invalidInput, accountMissing, unknown }

class QuickTransactionState {
  const QuickTransactionState({
    this.amount = '',
    this.accountId,
    this.categoryId,
    this.type = TransactionType.expense,
    this.isSubmitting = false,
    this.error,
    this.lastCreatedTransaction,
    this.preferredAccountId,
  });

  final String amount;
  final String? accountId;
  final String? categoryId;
  final TransactionType type;
  final bool isSubmitting;
  final QuickTransactionError? error;
  final TransactionEntity? lastCreatedTransaction;
  final String? preferredAccountId;

  MoneyAmount? parseAmount(int scale) {
    final String normalized = amount.replaceAll(',', '.');
    final MoneyAmount? value = tryParseMoneyAmount(
      input: normalized,
      scale: scale,
      useAbs: true,
    );
    if (value == null || value.minor <= BigInt.zero) {
      return null;
    }
    return value;
  }

  bool get canSubmit =>
      !isSubmitting &&
      accountId != null &&
      categoryId != null &&
      amount.trim().isNotEmpty;

  QuickTransactionState copyWith({
    String? amount,
    String? accountId,
    String? categoryId,
    TransactionType? type,
    bool? isSubmitting,
    QuickTransactionError? error,
    bool clearError = false,
    TransactionEntity? lastCreatedTransaction,
    bool clearLastCreatedTransaction = false,
    String? preferredAccountId,
  }) {
    return QuickTransactionState(
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      lastCreatedTransaction: clearLastCreatedTransaction
          ? null
          : (lastCreatedTransaction ?? this.lastCreatedTransaction),
      preferredAccountId: preferredAccountId ?? this.preferredAccountId,
    );
  }
}

final StateNotifierProvider<QuickTransactionController, QuickTransactionState>
quickTransactionControllerProvider =
    StateNotifierProvider<QuickTransactionController, QuickTransactionState>(
      (Ref ref) => QuickTransactionController(ref),
    );

class QuickTransactionController extends StateNotifier<QuickTransactionState> {
  QuickTransactionController(this.ref) : super(const QuickTransactionState());

  final Ref ref;
  late final AccountRepository _accountRepository = ref.read(
    accountRepositoryProvider,
  );

  void prepare({
    required String categoryId,
    required TransactionType categoryType,
    String? defaultAccountId,
  }) {
    state = QuickTransactionState(
      amount: '',
      accountId:
          state.accountId ?? state.preferredAccountId ?? defaultAccountId,
      categoryId: categoryId,
      type: categoryType,
      preferredAccountId: state.preferredAccountId ?? defaultAccountId,
    );
  }

  void updateAmount(String value) {
    state = state.copyWith(
      amount: value,
      clearError: true,
      clearLastCreatedTransaction: true,
    );
  }

  Future<TransactionEntity?> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(error: QuickTransactionError.invalidInput);
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final AccountEntity? account = await _accountRepository.findById(
        state.accountId!,
      );
      if (account == null) {
        state = state.copyWith(
          isSubmitting: false,
          error: QuickTransactionError.accountMissing,
        );
        return null;
      }
      final int scale =
          account.currencyScale ?? resolveCurrencyScale(account.currency);
      final MoneyAmount? amount = state.parseAmount(scale);
      if (amount == null) {
        state = state.copyWith(
          isSubmitting: false,
          error: QuickTransactionError.invalidInput,
        );
        return null;
      }
      final AddTransactionUseCase addUseCase = ref.read(
        addTransactionUseCaseProvider,
      );
      final ProfileEventRecorder recorder = ref.read(
        profileEventRecorderProvider,
      );
      final TransactionCommandResult<TransactionEntity> createdResult =
          await addUseCase(
            AddTransactionRequest(
              accountId: state.accountId!,
              categoryId: state.categoryId,
              amount: amount,
              date: DateTime.now(),
              note: '',
              type: state.type,
            ),
          );
      unawaited(recorder.record(createdResult.profileEvents));
      final TransactionEntity created = createdResult.value;
      state = state.copyWith(
        isSubmitting: false,
        lastCreatedTransaction: created,
        amount: '',
        preferredAccountId: state.accountId ?? state.preferredAccountId,
      );
      return created;
    } on StateError catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: QuickTransactionError.accountMissing,
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: QuickTransactionError.unknown,
      );
      return null;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}
