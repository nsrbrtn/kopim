import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
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
  bool _allowAutofocus = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _shouldRenderForm = false;
  TransactionFormArgs _lastFormArgs = const TransactionFormArgs();
  Timer? _hideTimer;

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

  double _resolveBackdropBlurSigma() {
    if (kIsWeb) {
      return 0;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => 16,
      TargetPlatform.android => 12,
      TargetPlatform.linux || TargetPlatform.windows => 8,
      _ => 12,
    };
  }

  Future<void> _submitForm(
    WidgetRef ref,
    TransactionFormArgs formArgs,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(Duration.zero);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(transactionFormControllerProvider(formArgs).notifier)
        .submit();
  }

  void _handleVisibilityChanged(TransactionSheetState state) {
    if (state.isVisible && !_allowAutofocus) {
      _hideTimer?.cancel();
      _hideTimer = null;
      _shouldRenderForm = true;
      _lastFormArgs = _buildFormArgs(state);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _allowAutofocus = true;
          });
        }
      });
    } else if (!state.isVisible && _shouldRenderForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _allowAutofocus = false;
          });
        }
      });
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _shouldRenderForm = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TransactionSheetState sheetState =
        ref.watch(transactionSheetControllerProvider);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    _handleVisibilityChanged(sheetState);

    final TransactionFormArgs formArgs = _shouldRenderForm
        ? _lastFormArgs
        : TransactionFormArgs(defaultAccountId: sheetState.defaultAccountId);
    final TransactionFormProvider? formProvider =
        _shouldRenderForm ? transactionFormControllerProvider(formArgs) : null;
    final bool isSubmitting = formProvider == null
        ? false
        : ref.watch(
            formProvider.select(
              (TransactionDraftState state) => state.isSubmitting,
            ),
          );
    final MediaQueryData mq = MediaQuery.of(context);
    final double viewInsetsBottom = mq.viewInsets.bottom;
    final double viewPaddingBottom = mq.viewPadding.bottom;
    final double effectiveBottomPadding =
        viewInsetsBottom > 0 ? 0 : viewPaddingBottom;
    final double blurSigma = _resolveBackdropBlurSigma();

    return PopScope(
      canPop: !sheetState.isVisible,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop && sheetState.isVisible && !isSubmitting) {
          _closeWithUnfocus(ref);
        }
      },
      child: IgnorePointer(
        ignoring: !sheetState.isVisible,
        child: Stack(
          children: <Widget>[
            if (sheetState.isVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap:
                      isSubmitting ? null : () => _closeWithUnfocus(ref),
                  child: ClipRect(
                    child: blurSigma <= 0
                        ? Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.72),
                          )
                        : BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: blurSigma,
                              sigmaY: blurSigma,
                            ),
                            child: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.72),
                            ),
                          ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                offset: sheetState.isVisible
                    ? Offset.zero
                    : const Offset(0, 0.08),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: sheetState.isVisible ? 1 : 0,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: effectiveBottomPadding),
                    child: Stack(
                      children: <Widget>[
                        if (_shouldRenderForm) ...<Widget>[
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: TransactionFormView(
                                formKey: _formKey,
                                formArgs: formArgs,
                                autofocusAmount: _allowAutofocus,
                                showSubmitButton: false,
                                onSuccess: (TransactionFormResult result) {
                                  _closeWithUnfocus(ref);
                                  ref
                                      .read(formProvider!.notifier)
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
                                                    .deleteTransaction(
                                                      created.id,
                                                    )
                                                    .then((bool undone) {
                                                      if (!mounted) {
                                                        return;
                                                      }
                                                      // ignore: use_build_context_synchronously
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      )
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
                          Positioned(
                            right: 24,
                            bottom: 16 + effectiveBottomPadding,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(strings.addTransactionSubmit),
                            ),
                          ),
                        ],
                      ],
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
