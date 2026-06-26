import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/widgets/animated_fab.dart';
import 'package:kopim/core/widgets/kopim_glass_fab.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_sheet_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeAddTransactionButton extends ConsumerWidget {
  const HomeAddTransactionButton({super.key, required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AnimatedFab(
      child: KopimGlassFab(
        icon: Icon(Icons.add, size: 48, color: colorScheme.primary),
        enableShadow: false,
        foregroundColor: colorScheme.primary,
        onPressed: () =>
            ref.read(transactionSheetControllerProvider.notifier).openForAdd(),
      ),
    );
  }
}
