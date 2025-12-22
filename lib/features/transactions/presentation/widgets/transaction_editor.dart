import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/transactions/presentation/controllers/transaction_actions_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

Future<bool> deleteTransactionWithFeedback({
  required BuildContext context,
  required WidgetRef ref,
  required String transactionId,
  required AppLocalizations strings,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(strings.transactionDeleteConfirmTitle),
        content: Text(strings.transactionDeleteConfirmMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.dialogConfirm),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    return false;
  }

  final bool deleted = await ref
      .read(transactionActionsControllerProvider.notifier)
      .deleteTransaction(transactionId);
  final AsyncValue<void> actionState = ref.read(
    transactionActionsControllerProvider,
  );
  if (deleted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(strings.transactionDeleteSuccess)),
        );
    }
  } else {
    final Object? error = actionState.hasError ? actionState.error : null;
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error?.toString() ?? strings.transactionDeleteError),
          ),
        );
    }
  }
  ref.read(transactionActionsControllerProvider.notifier).reset();
  return deleted;
}

Widget buildDeleteBackground(Color color, {Color? iconColor}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    ),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Icon(Icons.delete_outline, color: iconColor ?? Colors.white),
  );
}
