import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/use_cases/set_transaction_tags_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/entities/update_transaction_request.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/update_transaction_use_case.dart';

class TransactionFormArgs {
  const TransactionFormArgs({
    this.initialTransaction,
    this.defaultAccountId,
    this.initialAmount,
    this.initialCategoryId,
    this.initialType,
  });

  final TransactionEntity? initialTransaction;
  final String? defaultAccountId;
  final String? initialAmount;
  final String? initialCategoryId;
  final TransactionType? initialType;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionFormArgs &&
        other.initialTransaction == initialTransaction &&
        other.defaultAccountId == defaultAccountId &&
        other.initialAmount == initialAmount &&
        other.initialCategoryId == initialCategoryId &&
        other.initialType == initialType;
  }

  @override
  int get hashCode => Object.hash(
    initialTransaction,
    defaultAccountId,
    initialAmount,
    initialCategoryId,
    initialType,
  );
}

enum TransactionDraftError { accountMissing, transactionMissing, unknown }

class TransactionDraftState {
  const TransactionDraftState({
    this.amount = '',
    this.accountId,
    this.transferAccountId,
    this.categoryId,
    this.tagIds = const <String>[],
    this.note = '',
    this.type = TransactionType.expense,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.selectedDate,
    this.initialTransaction,
    this.lastCreatedTransaction,
    this.hasInitialized = false,
    this.hasLoadedTags = false,
    this.preferredAccountId,
    this.accountScale,
  });

  factory TransactionDraftState.forAdd({String? defaultAccountId}) {
    return TransactionDraftState(
      amount: '',
      accountId: defaultAccountId,
      transferAccountId: null,
      categoryId: null,
      tagIds: const <String>[],
      note: '',
      type: TransactionType.expense,
      selectedDate: null,
      initialTransaction: null,
      lastCreatedTransaction: null,
      hasInitialized: true,
      hasLoadedTags: false,
      preferredAccountId: defaultAccountId,
      accountScale: null,
    );
  }

  factory TransactionDraftState.forEdit(TransactionEntity transaction) {
    final TransactionType initialType = parseTransactionType(transaction.type);
    final MoneyAmount amount = transaction.amountValue;
    return TransactionDraftState(
      amount: amount.toDouble().toStringAsFixed(amount.scale),
      accountId: transaction.accountId,
      transferAccountId: transaction.transferAccountId,
      categoryId: transaction.categoryId,
      tagIds: const <String>[],
      note: transaction.note ?? '',
      type: initialType,
      selectedDate: transaction.date,
      initialTransaction: transaction,
      lastCreatedTransaction: null,
      hasInitialized: true,
      hasLoadedTags: false,
      preferredAccountId: transaction.accountId,
      accountScale: transaction.amountScale,
    );
  }

  final String amount;
  final String? accountId;
  final String? transferAccountId;
  final String? categoryId;
  final List<String> tagIds;
  final String note;
  final TransactionType type;
  final bool isSubmitting;
  final bool isSuccess;
  final TransactionDraftError? error;
  final DateTime? selectedDate;
  final TransactionEntity? initialTransaction;
  final TransactionEntity? lastCreatedTransaction;
  final bool hasInitialized;
  final bool hasLoadedTags;
  final String? preferredAccountId;
  final int? accountScale;

  bool get isEditing => initialTransaction != null;

  DateTime get date =>
      selectedDate ?? initialTransaction?.date ?? DateTime.now();

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

  MoneyAmount? get parsedAmountValue => parseAmount(accountScale ?? 2);

  double? get parsedAmount => parsedAmountValue?.toDouble();

  bool get canSubmit =>
      !isSubmitting &&
      accountId != null &&
      parseAmount(accountScale ?? 2) != null &&
      (type.isTransfer
          ? transferAccountId != null && transferAccountId != accountId
          : true);

  TransactionDraftState copyWith({
    String? amount,
    String? accountId,
    String? transferAccountId,
    String? categoryId,
    List<String>? tagIds,
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
    bool? hasLoadedTags,
    String? preferredAccountId,
    int? accountScale,
    bool clearTransferAccount = false,
  }) {
    return TransactionDraftState(
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      transferAccountId: clearTransferAccount
          ? null
          : (transferAccountId ?? this.transferAccountId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      tagIds: tagIds ?? this.tagIds,
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
      hasLoadedTags: hasLoadedTags ?? this.hasLoadedTags,
      preferredAccountId: preferredAccountId ?? this.preferredAccountId,
      accountScale: accountScale ?? this.accountScale,
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

final StreamProvider<List<TagEntity>> transactionFormTagsProvider =
    StreamProvider.autoDispose<List<TagEntity>>((Ref ref) {
      return ref.watch(watchTagsUseCaseProvider).call();
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
  late final AccountRepository _accountRepository = ref.read(
    accountRepositoryProvider,
  );

  void applyArgs(TransactionFormArgs args) {
    if (args.initialTransaction != null) {
      setDraftForEdit(args.initialTransaction!);
      unawaited(_loadTagIdsForEdit(args.initialTransaction!.id));
      return;
    }
    if (!state.hasInitialized) {
      resetDraft(defaultAccountId: args.defaultAccountId);
    } else if (state.accountId == null && args.defaultAccountId != null) {
      state = state.copyWith(accountId: args.defaultAccountId);
    }

    final String? amount = args.initialAmount?.trim();
    final String? categoryId = args.initialCategoryId?.trim();
    if (amount != null && amount.isNotEmpty ||
        categoryId != null && categoryId.isNotEmpty ||
        args.initialType != null) {
      state = state.copyWith(
        amount: (amount != null && amount.isNotEmpty) ? amount : state.amount,
        categoryId:
            (categoryId != null && categoryId.isNotEmpty)
                ? categoryId
                : state.categoryId,
        type: args.initialType ?? state.type,
      );
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
      transferAccountId: null,
      categoryId: null,
      tagIds: const <String>[],
      note: '',
      type: TransactionType.expense,
      selectedDate: DateTime.now(),
      hasInitialized: true,
      hasLoadedTags: false,
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
      transferAccountId: state.transferAccountId == accountId
          ? null
          : state.transferAccountId,
      preferredAccountId: accountId ?? state.preferredAccountId,
      accountScale: state.accountScale,
      clearError: true,
      isSuccess: false,
    );
    if (accountId != null) {
      unawaited(_updateAccountScale(accountId));
    }
  }

  void updateCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId, clearError: true);
  }

  void updateTags(List<String> tagIds) {
    state = state.copyWith(tagIds: List<String>.unmodifiable(tagIds));
  }

  void toggleTag(String tagId) {
    final List<String> current = List<String>.from(state.tagIds);
    if (current.contains(tagId)) {
      current.remove(tagId);
    } else {
      current.add(tagId);
    }
    state = state.copyWith(tagIds: List<String>.unmodifiable(current));
  }

  void updateTransferAccount(String? accountId) {
    state = state.copyWith(
      transferAccountId: accountId,
      clearError: true,
      isSuccess: false,
    );
  }

  void updateNote(String value) {
    state = state.copyWith(note: value);
  }

  void updateType(TransactionType type) {
    state = state.copyWith(
      type: type,
      clearCategory: true,
      clearTransferAccount: !type.isTransfer,
    );
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
      final AccountEntity? account = await _accountRepository.findById(
        state.accountId!,
      );
      if (account == null) {
        throw StateError('Account not found');
      }
      final int scale =
          account.currencyScale ?? resolveCurrencyScale(account.currency);
      final MoneyAmount? parsedAmount = state.parseAmount(scale);
      if (parsedAmount == null) {
        state = state.copyWith(
          isSubmitting: false,
          error: TransactionDraftError.unknown,
        );
        return;
      }
      if (state.isEditing) {
        final TransactionEntity? initial = state.initialTransaction;
        if (initial == null) {
          state = state.copyWith(
            isSubmitting: false,
            error: TransactionDraftError.transactionMissing,
          );
          return;
        }
        final String? resolvedCategoryId = state.type.isTransfer
            ? null
            : (state.categoryId?.isEmpty ?? true ? null : state.categoryId);
        final UpdateTransactionUseCase updateUseCase = ref.read(
          updateTransactionUseCaseProvider,
        );
        await updateUseCase(
          UpdateTransactionRequest(
            transactionId: initial.id,
            accountId: state.accountId!,
            transferAccountId: state.transferAccountId,
            categoryId: resolvedCategoryId,
            amount: parsedAmount,
            date: state.date,
            note: state.note,
            type: state.type,
          ),
        );
        await _syncTransactionTags(initial.id);
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
      final String? resolvedCategoryId = state.type.isTransfer
          ? null
          : (state.categoryId?.isEmpty ?? true ? null : state.categoryId);
      final TransactionCommandResult<TransactionEntity> createdResult =
          await addUseCase(
            AddTransactionRequest(
              accountId: state.accountId!,
              transferAccountId: state.transferAccountId,
              categoryId: resolvedCategoryId,
              amount: parsedAmount,
              date: state.date,
              note: state.note,
              type: state.type,
            ),
          );
      unawaited(recorder.record(createdResult.profileEvents));
      final TransactionEntity created = createdResult.value;
      await _syncTransactionTags(created.id);
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

  Future<void> _updateAccountScale(String accountId) async {
    final AccountEntity? account = await _accountRepository.findById(accountId);
    if (account == null) return;
    final int scale =
        account.currencyScale ?? resolveCurrencyScale(account.currency);
    state = state.copyWith(accountScale: scale);
  }

  Future<void> _loadTagIdsForEdit(String transactionId) async {
    if (state.hasLoadedTags) {
      return;
    }
    try {
      final List<String> tagIds = await ref.read(
        getTransactionTagIdsUseCaseProvider,
      )(transactionId);
      state = state.copyWith(
        tagIds: List<String>.unmodifiable(tagIds),
        hasLoadedTags: true,
      );
    } catch (_) {
      state = state.copyWith(hasLoadedTags: true);
    }
  }

  Future<void> _syncTransactionTags(String transactionId) async {
    final SetTransactionTagsUseCase setTagsUseCase = ref.read(
      setTransactionTagsUseCaseProvider,
    );
    final LoggerService logger = ref.read(loggerServiceProvider);
    try {
      await setTagsUseCase(transactionId: transactionId, tagIds: state.tagIds);
    } catch (error) {
      logger.logError('Не удалось сохранить тэги транзакции', error);
    }
  }
}
