import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/transactions/presentation/controllers/transaction_actions_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

String _buildDeleteErrorMessage({
  required String transactionId,
  required AppLocalizations strings,
  Object? error,
}) {
  final String details = error?.toString().trim() ?? '';
  if (details.isEmpty) {
    return '${strings.transactionDeleteError} (id: $transactionId)';
  }
  return 'Не удалось удалить транзакцию (id: $transactionId): $details';
}

Future<bool> deleteTransactionWithFeedback({
  required BuildContext context,
  required WidgetRef ref,
  required String transactionId,
  required AppLocalizations strings,
}) async {
  final ProviderContainer container = ProviderScope.containerOf(
    context,
    listen: false,
  );
  final TransactionActionsController notifier = container.read(
    transactionActionsControllerProvider.notifier,
  );

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

  final bool deleted = await notifier.deleteTransaction(transactionId);
  final AsyncValue<void> actionState = container.read(
    transactionActionsControllerProvider,
  );
  if (deleted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(strings.transactionDeleteSuccess),
          ),
        );
    }
  } else {
    final Object? error = actionState.hasError ? actionState.error : null;
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 8),
            content: Text(
              _buildDeleteErrorMessage(
                transactionId: transactionId,
                strings: strings,
                error: error,
              ),
            ),
          ),
        );
    }
  }
  notifier.reset();
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
