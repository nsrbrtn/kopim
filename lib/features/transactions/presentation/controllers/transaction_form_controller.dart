import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/entities/update_transaction_request.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/update_transaction_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_form_controller.g.dart';

class TransactionFormArgs {
  const TransactionFormArgs({this.initialTransaction, this.defaultAccountId});

  final TransactionEntity? initialTransaction;
  final String? defaultAccountId;
}

enum TransactionFormError { accountMissing, transactionMissing, unknown }

class TransactionFormState {
  const TransactionFormState({
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
  });

  factory TransactionFormState.initial({
    TransactionEntity? initial,
    String? defaultAccountId,
  }) {
    if (initial != null) {
      final TransactionType initialType =
          initial.type == TransactionType.income.storageValue
          ? TransactionType.income
          : TransactionType.expense;
      return TransactionFormState(
        amount: initial.amount.toStringAsFixed(2),
        accountId: initial.accountId,
        categoryId: initial.categoryId,
        note: initial.note ?? '',
        type: initialType,
        selectedDate: initial.date,
        initialTransaction: initial,
      );
    }

    return TransactionFormState(
      amount: '',
      accountId: defaultAccountId,
      categoryId: null,
      note: '',
      type: TransactionType.expense,
      selectedDate: null,
      initialTransaction: null,
      lastCreatedTransaction: null,
    );
  }

  final String amount;
  final String? accountId;
  final String? categoryId;
  final String note;
  final TransactionType type;
  final bool isSubmitting;
  final bool isSuccess;
  final TransactionFormError? error;
  final DateTime? selectedDate;
  final TransactionEntity? initialTransaction;
  final TransactionEntity? lastCreatedTransaction;

  DateTime get date =>
      selectedDate ?? initialTransaction?.date ?? DateTime.now();

  bool get isEditing => initialTransaction != null;

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

  TransactionFormState copyWith({
    String? amount,
    String? accountId,
    String? categoryId,
    String? note,
    TransactionType? type,
    bool? isSubmitting,
    bool? isSuccess,
    TransactionFormError? error,
    bool clearError = false,
    DateTime? selectedDate,
    bool clearCategory = false,
    TransactionEntity? initialTransaction,
    TransactionEntity? lastCreatedTransaction,
    bool clearLastCreatedTransaction = false,
  }) {
    return TransactionFormState(
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
    );
  }
}

final StreamProvider<List<AccountEntity>> transactionFormAccountsProvider =
    StreamProvider.autoDispose<List<AccountEntity>>((Ref ref) {
      return ref.watch(watchAccountsUseCaseProvider).call();
    });

final StreamProvider<List<Category>> transactionFormCategoriesProvider =
    StreamProvider.autoDispose<List<Category>>((Ref ref) {
      return ref.watch(watchCategoriesUseCaseProvider).call();
    });

@riverpod
class TransactionFormController extends _$TransactionFormController {
  @override
  TransactionFormState build(TransactionFormArgs args) {
    return TransactionFormState.initial(
      initial: args.initialTransaction,
      defaultAccountId: args.defaultAccountId,
    );
  }

  void updateAmount(String value) {
    state = state.copyWith(amount: value, clearError: true, isSuccess: false);
  }

  void updateAccount(String? accountId) {
    state = state.copyWith(
      accountId: accountId,
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

  Future<void> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(error: TransactionFormError.unknown);
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      if (state.isEditing) {
        final TransactionEntity? initial = state.initialTransaction;
        if (initial == null) {
          state = state.copyWith(
            isSubmitting: false,
            error: TransactionFormError.transactionMissing,
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
      final TransactionEntity created = await addUseCase(
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
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        lastCreatedTransaction: created,
      );
      return;
    } on StateError catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: TransactionFormError.accountMissing,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: TransactionFormError.unknown,
      );
    }
  }
}
