import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_actions_controller.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_sheet_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_view.dart';
import 'package:kopim/l10n/app_localizations.dart';

class TransactionFormOverlay extends ConsumerStatefulWidget {
  const TransactionFormOverlay({super.key});

  @override
  ConsumerState<TransactionFormOverlay> createState() =>
      _TransactionFormOverlayState();
}

class _TransactionFormOverlayState
    extends ConsumerState<TransactionFormOverlay> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _closeWithUnfocus(WidgetRef ref) {
    FocusScope.of(context).unfocus();
    ref.read(transactionSheetControllerProvider.notifier).close();
  }

  TransactionFormArgs _buildFormArgs(TransactionSheetState sheetState) {
    return sheetState.mode == TransactionSheetMode.edit &&
            sheetState.transaction != null
        ? TransactionFormArgs(initialTransaction: sheetState.transaction)
        : TransactionFormArgs(defaultAccountId: sheetState.defaultAccountId);
  }

  Color _resolveBackdropColor(ThemeData theme) {
    if (kIsWeb) {
      return theme.colorScheme.surfaceContainerLowest;
    }
    return theme.colorScheme.surfaceContainerLowest;
  }

  Future<void> _submitForm(WidgetRef ref, TransactionFormArgs formArgs) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(Duration.zero);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(transactionFormControllerProvider(formArgs).notifier)
        .submit();
  }

  @override
  Widget build(BuildContext context) {
    final TransactionSheetState sheetState = ref.watch(
      transactionSheetControllerProvider,
    );
    if (!sheetState.isVisible) {
      return const SizedBox.shrink();
    }
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TransactionFormArgs formArgs = _buildFormArgs(sheetState);
    final TransactionFormProvider formProvider =
        transactionFormControllerProvider(formArgs);
    final bool isSubmitting = ref.watch(
      formProvider.select((TransactionDraftState state) => state.isSubmitting),
    );
    final ThemeData theme = Theme.of(context);
    final Color backdropColor = _resolveBackdropColor(theme);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop && !isSubmitting) {
          _closeWithUnfocus(ref);
        }
      },
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              onTap: isSubmitting ? null : () => _closeWithUnfocus(ref),
              child: ColoredBox(color: backdropColor),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                offset: Offset.zero,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: TransactionFormView(
                          formKey: _formKey,
                          formArgs: formArgs,
                          autofocusAmount: true,
                          showSubmitButton: false,
                          onSuccess: (TransactionFormResult result) {
                            _closeWithUnfocus(ref);
                            ref
                                .read(formProvider.notifier)
                                .resetDraft(
                                  defaultAccountId: sheetState.defaultAccountId,
                                );
                            final ScaffoldMessengerState messenger =
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar();
                            final Widget content = Text(
                              strings.addTransactionSuccess,
                            );
                            final TransactionEntity? created =
                                result.createdTransaction;
                            messenger.showSnackBar(
                              SnackBar(
                                content: content,
                                duration: const Duration(seconds: 3),
                                action: created == null
                                    ? null
                                    : SnackBarAction(
                                        label: strings.commonUndo,
                                        onPressed: () {
                                          final ScaffoldMessengerState
                                          undoMessenger = ScaffoldMessenger.of(
                                            context,
                                          )..hideCurrentSnackBar();
                                          ref
                                              .read(
                                                transactionActionsControllerProvider
                                                    .notifier,
                                              )
                                              .deleteTransaction(created.id)
                                              .then((bool undone) {
                                                if (!mounted) {
                                                  return;
                                                }
                                                undoMessenger
                                                  ..hideCurrentSnackBar()
                                                  ..showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        undone
                                                            ? strings
                                                                  .addTransactionUndoSuccess
                                                            : strings
                                                                  .addTransactionUndoError,
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 3,
                                                      ),
                                                    ),
                                                  );
                                              });
                                        },
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      right: 24,
                      bottom: 16,
                      child: FloatingActionButton.extended(
                        heroTag: 'transaction_form_submit_fab',
                        onPressed: isSubmitting
                            ? null
                            : () async => _submitForm(ref, formArgs),
                        icon: isSubmitting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(strings.addTransactionSubmit),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
