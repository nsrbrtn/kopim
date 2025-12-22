import 'package:riverpod/riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

enum TransactionSheetMode { add, edit }

class TransactionSheetState {
  const TransactionSheetState({
    this.isVisible = false,
    this.mode,
    this.transactionId,
    this.defaultAccountId,
    this.transaction,
  });

  final bool isVisible;
  final TransactionSheetMode? mode;
  final String? transactionId;
  final String? defaultAccountId;
  final TransactionEntity? transaction;

  TransactionSheetState copyWith({
    bool? isVisible,
    TransactionSheetMode? mode,
    String? transactionId,
    String? defaultAccountId,
    TransactionEntity? transaction,
  }) {
    return TransactionSheetState(
      isVisible: isVisible ?? this.isVisible,
      mode: mode ?? this.mode,
      transactionId: transactionId ?? this.transactionId,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      transaction: transaction ?? this.transaction,
    );
  }
}

final StateNotifierProvider<TransactionSheetController, TransactionSheetState>
transactionSheetControllerProvider =
    StateNotifierProvider<TransactionSheetController, TransactionSheetState>(
      (Ref ref) => TransactionSheetController(ref),
    );

class TransactionSheetController extends StateNotifier<TransactionSheetState> {
  TransactionSheetController(this.ref)
    : super(const TransactionSheetState(isVisible: false));

  final Ref ref;

  void openForAdd({String? defaultAccountId}) {
    state = state.copyWith(
      isVisible: true,
      mode: TransactionSheetMode.add,
      transactionId: null,
      defaultAccountId: defaultAccountId,
      transaction: null,
    );
  }

  void openForEdit(TransactionEntity transaction) {
    state = state.copyWith(
      isVisible: true,
      mode: TransactionSheetMode.edit,
      transactionId: transaction.id,
      transaction: transaction,
    );
  }

  void close() {
    state = state.copyWith(isVisible: false);
  }
}
