import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/entities/update_transaction_request.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/update_transaction_use_case.dart';

class TransactionFormArgs {
  const TransactionFormArgs({this.initialTransaction, this.defaultAccountId});

  final TransactionEntity? initialTransaction;
  final String? defaultAccountId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionFormArgs &&
        other.initialTransaction == initialTransaction &&
        other.defaultAccountId == defaultAccountId;
  }

  @override
  int get hashCode => Object.hash(initialTransaction, defaultAccountId);
}

enum TransactionDraftError { accountMissing, transactionMissing, unknown }

class TransactionDraftState {
  const TransactionDraftState({
    this.amount = '',
    this.accountId,
    this.categoryId,
    this.note = '',
    this.type = TransactionType.expense,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.selectedDate,
    this.initialTransaction,
    this.lastCreatedTransaction,
    this.hasInitialized = false,
    this.preferredAccountId,
  });

  factory TransactionDraftState.forAdd({String? defaultAccountId}) {
    return TransactionDraftState(
      amount: '',
      accountId: defaultAccountId,
      categoryId: null,
      note: '',
      type: TransactionType.expense,
      selectedDate: null,
      initialTransaction: null,
      lastCreatedTransaction: null,
      hasInitialized: true,
      preferredAccountId: defaultAccountId,
    );
  }

  factory TransactionDraftState.forEdit(TransactionEntity transaction) {
    final TransactionType initialType =
        transaction.type == TransactionType.income.storageValue
        ? TransactionType.income
        : TransactionType.expense;
    return TransactionDraftState(
      amount: transaction.amount.toStringAsFixed(2),
      accountId: transaction.accountId,
      categoryId: transaction.categoryId,
      note: transaction.note ?? '',
      type: initialType,
      selectedDate: transaction.date,
      initialTransaction: transaction,
      lastCreatedTransaction: null,
      hasInitialized: true,
      preferredAccountId: transaction.accountId,
    );
  }

  final String amount;
  final String? accountId;
  final String? categoryId;
  final String note;
  final TransactionType type;
  final bool isSubmitting;
  final bool isSuccess;
  final TransactionDraftError? error;
  final DateTime? selectedDate;
  final TransactionEntity? initialTransaction;
  final TransactionEntity? lastCreatedTransaction;
  final bool hasInitialized;
  final String? preferredAccountId;

  bool get isEditing => initialTransaction != null;

  DateTime get date =>
      selectedDate ?? initialTransaction?.date ?? DateTime.now();

  double? get parsedAmount {
    final String normalized = amount.replaceAll(',', '.');
    final double? value = double.tryParse(normalized);
    if (value == null || value <= 0) {
      return null;
    }
    return value;
  }

  bool get canSubmit =>
      !isSubmitting && accountId != null && parsedAmount != null;

  TransactionDraftState copyWith({
    String? amount,
    String? accountId,
    String? categoryId,
    String? note,
    TransactionType? type,
    bool? isSubmitting,
    bool? isSuccess,
    TransactionDraftError? error,
    bool clearError = false,
    DateTime? selectedDate,
    bool clearCategory = false,
    TransactionEntity? initialTransaction,
    TransactionEntity? lastCreatedTransaction,
    bool clearLastCreatedTransaction = false,
    bool? hasInitialized,
    String? preferredAccountId,
  }) {
    return TransactionDraftState(
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      note: note ?? this.note,
      type: type ?? this.type,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: clearError ? null : (error ?? this.error),
      selectedDate: selectedDate ?? this.selectedDate,
      initialTransaction: initialTransaction ?? this.initialTransaction,
      lastCreatedTransaction: clearLastCreatedTransaction
          ? null
          : (lastCreatedTransaction ?? this.lastCreatedTransaction),
      hasInitialized: hasInitialized ?? this.hasInitialized,
      preferredAccountId: preferredAccountId ?? this.preferredAccountId,
    );
  }
}

final StreamProvider<List<AccountEntity>> transactionFormAccountsProvider =
    StreamProvider.autoDispose<List<AccountEntity>>((Ref ref) {
      return ref.watch(watchAccountsUseCaseProvider).call().map((
        List<AccountEntity> accounts,
      ) {
        return accounts.where((AccountEntity a) => a.type != 'credit').toList();
      });
    });

final StreamProvider<List<Category>> transactionFormCategoriesProvider =
    StreamProvider.autoDispose<List<Category>>((Ref ref) {
      return ref.watch(watchCategoriesUseCaseProvider).call();
    });

final StateNotifierProvider<TransactionDraftController, TransactionDraftState>
transactionDraftControllerProvider =
    StateNotifierProvider<TransactionDraftController, TransactionDraftState>(
      (Ref ref) => TransactionDraftController(ref),
    );

class TransactionDraftController extends StateNotifier<TransactionDraftState> {
  TransactionDraftController(this.ref)
    : super(const TransactionDraftState(hasInitialized: false));

  final Ref ref;

  void applyArgs(TransactionFormArgs args) {
    if (args.initialTransaction != null) {
      setDraftForEdit(args.initialTransaction!);
      return;
    }
    if (!state.hasInitialized) {
      resetDraft(defaultAccountId: args.defaultAccountId);
    } else if (state.accountId == null && args.defaultAccountId != null) {
      state = state.copyWith(accountId: args.defaultAccountId);
    }
  }

  void resetDraft({String? defaultAccountId}) {
    state = TransactionDraftState.forAdd(
      defaultAccountId:
          state.accountId ?? state.preferredAccountId ?? defaultAccountId,
    );
  }

  void setDraftForAdd({String? defaultAccountId, bool resetAmount = true}) {
    state = TransactionDraftState(
      amount: resetAmount ? '' : state.amount,
      accountId:
          state.accountId ?? state.preferredAccountId ?? defaultAccountId,
      categoryId: null,
      note: '',
      type: TransactionType.expense,
      selectedDate: DateTime.now(),
      hasInitialized: true,
      preferredAccountId:
          state.preferredAccountId ?? state.accountId ?? defaultAccountId,
    );
  }

  void setDraftForEdit(TransactionEntity transaction) {
    state = TransactionDraftState.forEdit(transaction);
  }

  void markInitialized() {
    if (!state.hasInitialized) {
      state = state.copyWith(hasInitialized: true);
    }
  }

  void updateAmount(String value) {
    state = state.copyWith(amount: value, clearError: true, isSuccess: false);
  }

  void updateAccount(String? accountId) {
    state = state.copyWith(
      accountId: accountId,
      preferredAccountId: accountId ?? state.preferredAccountId,
      clearError: true,
      isSuccess: false,
    );
  }

  void updateCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId, clearError: true);
  }

  void updateNote(String value) {
    state = state.copyWith(note: value);
  }

  void updateType(TransactionType type) {
    state = state.copyWith(type: type, clearCategory: true);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void updateTime({required int hour, required int minute}) {
    final DateTime base = state.date;
    state = state.copyWith(
      selectedDate: DateTime(base.year, base.month, base.day, hour, minute),
    );
  }

  void acknowledgeSuccess() {
    if (state.isSuccess) {
      state = state.copyWith(isSuccess: false);
    }
  }

  void clearLastCreatedTransaction() {
    if (state.lastCreatedTransaction != null) {
      state = state.copyWith(clearLastCreatedTransaction: true);
    }
  }

  void clearErrors() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<void> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(error: TransactionDraftError.unknown);
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      if (state.isEditing) {
        final TransactionEntity? initial = state.initialTransaction;
        if (initial == null) {
          state = state.copyWith(
            isSubmitting: false,
            error: TransactionDraftError.transactionMissing,
          );
          return;
        }
        final UpdateTransactionUseCase updateUseCase = ref.read(
          updateTransactionUseCaseProvider,
        );
        await updateUseCase(
          UpdateTransactionRequest(
            transactionId: initial.id,
            accountId: state.accountId!,
            categoryId: state.categoryId?.isEmpty ?? true
                ? null
                : state.categoryId,
            amount: state.parsedAmount!,
            date: state.date,
            note: state.note,
            type: state.type,
          ),
        );
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          clearLastCreatedTransaction: true,
        );
        return;
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
              categoryId: state.categoryId?.isEmpty ?? true
                  ? null
                  : state.categoryId,
              amount: state.parsedAmount!,
              date: state.date,
              note: state.note,
              type: state.type,
            ),
          );
      unawaited(recorder.record(createdResult.profileEvents));
      final TransactionEntity created = createdResult.value;
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        lastCreatedTransaction: created,
        preferredAccountId: state.accountId ?? state.preferredAccountId,
      );
    } on StateError catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: TransactionDraftError.accountMissing,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: TransactionDraftError.unknown,
      );
    }
  }
}
