import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_transaction_controller.g.dart';

class AddTransactionState {
  const AddTransactionState({
    this.amount = '',
    this.accountId,
    this.categoryId,
    this.note = '',
    this.type = TransactionType.expense,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.selectedDate,
  });

  final String amount;
  final String? accountId;
  final String? categoryId;
  final String note;
  final TransactionType type;
  final bool isSubmitting;
  final bool isSuccess;
  final AddTransactionError? error;
  final DateTime? selectedDate;

  DateTime get date => selectedDate ?? DateTime.now();

  double? get parsedAmount {
    final String normalized = amount.replaceAll(',', '.');
    final double? value = double.tryParse(normalized);
    if (value == null) {
      return null;
    }
    if (value <= 0) {
      return null;
    }
    return value;
  }

  bool get canSubmit =>
      !isSubmitting && accountId != null && parsedAmount != null;

  AddTransactionState copyWith({
    String? amount,
    String? accountId,
    String? categoryId,
    String? note,
    TransactionType? type,
    bool? isSubmitting,
    bool? isSuccess,
    AddTransactionError? error,
    bool clearError = false,
    DateTime? selectedDate,
    bool clearCategory = false,
  }) {
    return AddTransactionState(
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      categoryId: clearCategory
          ? null
          : (categoryId ?? this.categoryId),
      note: note ?? this.note,
      type: type ?? this.type,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: clearError ? null : (error ?? this.error),
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

enum AddTransactionError { accountMissing, unknown }

final StreamProvider<List<AccountEntity>> addTransactionAccountsProvider =
    StreamProvider.autoDispose<List<AccountEntity>>((Ref ref) {
  return ref.watch(watchAccountsUseCaseProvider).call();
});

final StreamProvider<List<Category>> addTransactionCategoriesProvider =
    StreamProvider.autoDispose<List<Category>>((Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
});

@riverpod
class AddTransactionController extends _$AddTransactionController {
  @override
  AddTransactionState build() => const AddTransactionState();

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

  void acknowledgeSuccess() {
    if (state.isSuccess) {
      state = state.copyWith(isSuccess: false);
    }
  }

  Future<void> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(error: AddTransactionError.unknown);
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    final AddTransactionUseCase useCase =
        ref.read(addTransactionUseCaseProvider);
    try {
      await useCase(
        AddTransactionRequest(
          accountId: state.accountId!,
          categoryId: state.categoryId?.isEmpty ?? true
              ? null
              : state.categoryId,
          amount: state.parsedAmount!,
          date: state.selectedDate ?? DateTime.now(),
          note: state.note,
          type: state.type,
        ),
      );
      state = state.copyWith(isSubmitting: false, isSuccess: true);
    } on StateError catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: AddTransactionError.accountMissing,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: AddTransactionError.unknown,
      );
    }
  }
}
