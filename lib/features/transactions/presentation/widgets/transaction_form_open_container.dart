import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_draft_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_view.dart';

class TransactionFormOpenContainer extends StatelessWidget {
  const TransactionFormOpenContainer({
    super.key,
    required this.closedBuilder,
    this.formArgs = const TransactionFormArgs(),
    this.transitionDuration = const Duration(milliseconds: 450),
    this.onClosed,
  });

  final TransactionFormArgs formArgs;
  final Duration transitionDuration;
  final void Function(TransactionFormResult? result)? onClosed;
  final Widget Function(BuildContext context, VoidCallback openContainer)
      closedBuilder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return OpenContainer<TransactionFormResult>(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: transitionDuration,
      closedColor: Colors.transparent,
      openColor: theme.colorScheme.surface,
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      openShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      tappable: false,
      onClosed: onClosed,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return closedBuilder(context, openContainer);
      },
      openBuilder: (BuildContext context, VoidCallback _) {
        return AddTransactionScreen(formArgs: formArgs);
      },
    );
  }
}
