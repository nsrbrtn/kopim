export 'transaction_draft_controller.dart'
    show
        TransactionDraftController,
        TransactionDraftError,
        TransactionDraftState,
        TransactionFormArgs,
        transactionDraftControllerProvider,
        transactionFormAccountsProvider,
        transactionFormCategoriesProvider;

import 'package:riverpod/riverpod.dart';
import 'package:riverpod/legacy.dart';

import 'transaction_draft_controller.dart';

typedef TransactionFormState = TransactionDraftState;
typedef TransactionFormError = TransactionDraftError;

typedef TransactionFormControllerProvider
    = StateNotifierProvider<TransactionFormController, TransactionDraftState>;

typedef TransactionFormControllerFamily
    = StateNotifierProviderFamily<TransactionFormController,
        TransactionDraftState, TransactionFormArgs>;

final TransactionFormControllerFamily transactionFormControllerProvider =
    StateNotifierProvider.autoDispose.family<TransactionFormController,
        TransactionDraftState, TransactionFormArgs>(
  (Ref ref, TransactionFormArgs args) => TransactionFormController(ref, args: args),
);

class TransactionFormController extends TransactionDraftController {
  TransactionFormController(
    Ref ref, {
    required this.args,
  }) : super(ref) {
    applyArgs(args);
  }

  final TransactionFormArgs args;
}
