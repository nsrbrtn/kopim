import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_actions_controller.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_draft_controller.dart';
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
  bool _allowAutofocus = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleVisibilityChanged(TransactionSheetState state) {
    if (!state.isVisible && _allowAutofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _allowAutofocus = false;
          });
        }
      });
    }
  }

  void _handleOpacityEnd(TransactionSheetState state) {
    if (state.isVisible && !_allowAutofocus) {
      setState(() {
        _allowAutofocus = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TransactionSheetState sheetState =
        ref.watch(transactionSheetControllerProvider);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    _handleVisibilityChanged(sheetState);

    final TransactionFormArgs formArgs = sheetState.mode ==
            TransactionSheetMode.edit &&
        sheetState.transaction != null
        ? TransactionFormArgs(initialTransaction: sheetState.transaction)
        : TransactionFormArgs(defaultAccountId: sheetState.defaultAccountId);

    return PopScope(
      canPop: !sheetState.isVisible,
      onPopInvoked: (bool didPop) {
        if (!didPop && sheetState.isVisible) {
          ref.read(transactionSheetControllerProvider.notifier).close();
        }
      },
      child: IgnorePointer(
        ignoring: !sheetState.isVisible,
        child: Stack(
          children: <Widget>[
            if (sheetState.isVisible)
              ModalBarrier(
                color: Colors.black54,
                dismissible: true,
                onDismiss: () => ref
                    .read(transactionSheetControllerProvider.notifier)
                    .close(),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  offset: sheetState.isVisible
                      ? Offset.zero
                      : const Offset(0, 0.08),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: sheetState.isVisible ? 1 : 0,
                    onEnd: () => _handleOpacityEnd(sheetState),
                    child: SafeArea(
                      child: Material(
                        elevation: 12,
                        borderRadius: BorderRadius.circular(24),
                        clipBehavior: Clip.antiAlias,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLowest,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: TransactionFormView(
                            formKey: _formKey,
                            formArgs: formArgs,
                            autofocusAmount: _allowAutofocus,
                            onSuccess: (TransactionFormResult result) {
                              ref
                                  .read(transactionSheetControllerProvider
                                      .notifier)
                                  .close();
                              ref
                                  .read(
                                      transactionDraftControllerProvider.notifier)
                                  .resetDraft(
                                    defaultAccountId:
                                        sheetState.defaultAccountId,
                                  );
                              final ScaffoldMessengerState messenger =
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar();
                              final Widget content =
                                  Text(strings.addTransactionSuccess);
                              final TransactionEntity? created =
                                  result.createdTransaction;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: content,
                                  action: created == null
                                      ? null
                                      : SnackBarAction(
                                          label: strings.commonUndo,
                                          onPressed: () {
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
                                                  ScaffoldMessenger.of(context)
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
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
