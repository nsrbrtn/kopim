import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/widgets/empty_state_view.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_sheet_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.titleLarge;
    if (action == null) {
      return Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Text(title, style: style),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(width: 24),
        Expanded(child: Text(title, style: style)),
        const SizedBox(width: 8),
        action!,
      ],
    );
  }
}

class HomeErrorMessage extends StatelessWidget {
  const HomeErrorMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.error,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(message, style: style, textAlign: TextAlign.center),
      ),
    );
  }
}

class HomeEmptyMessage extends ConsumerWidget {
  const HomeEmptyMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return EmptyStateView(
      icon: Icons.receipt_long_outlined,
      title: message,
      description: strings.homeTransactionsEmptyDescription,
      actionLabel: strings.homeTransactionsCreateButton,
      onActionPressed: () =>
          ref.read(transactionSheetControllerProvider.notifier).openForAdd(),
      isCompact: true,
    );
  }
}
