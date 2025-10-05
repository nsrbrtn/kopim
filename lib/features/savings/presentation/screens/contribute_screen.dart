import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/value_objects/goal_progress.dart';
import 'package:kopim/features/savings/presentation/controllers/contribute_controller.dart';
import 'package:kopim/features/savings/presentation/controllers/contribute_state.dart';
import 'package:kopim/l10n/app_localizations.dart';

InputDecoration _contributionFieldDecoration(
  BuildContext context, {
  required String label,
  String? error,
}) {
  final ThemeData theme = Theme.of(context);
  const OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    labelText: label,
    errorText: error,
    filled: true,
    fillColor: theme.colorScheme.surfaceContainerHighest,
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  );
}

class ContributeScreen extends ConsumerStatefulWidget {
  const ContributeScreen({super.key, required this.goal});

  final SavingGoal goal;

  static Route<void> route(SavingGoal goal) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => ContributeScreen(goal: goal),
    );
  }

  @override
  ConsumerState<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends ConsumerState<ContributeScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  ProviderSubscription<ContributeState>? _subscription;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _subscription = ref.listenManual<ContributeState>(
      contributeControllerProvider(widget.goal),
      (ContributeState? previous, ContributeState next) {
        if (!mounted) {
          return;
        }
        if (previous?.success != true && next.success) {
          final AppLocalizations strings = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.savingsContributionSuccess)),
          );
          Navigator.of(context).pop();
        } else if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ContributeState state = ref.watch(
      contributeControllerProvider(widget.goal),
    );
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final GoalProgress progress = GoalProgress.fromGoal(widget.goal);
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
    );
    final String remainingLabel = currencyFormat.format(
      progress.remaining.minorUnits / 100,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.savingsContributeTitle(widget.goal.name)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.goal.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress.percent),
                      const SizedBox(height: 8),
                      Text(
                        strings.savingsRemainingLabel(remainingLabel),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                decoration: _contributionFieldDecoration(
                  context,
                  label: strings.savingsAmountLabel,
                  error: state.amountError,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (String value) => ref
                    .read(contributeControllerProvider(widget.goal).notifier)
                    .updateAmount(value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: state.selectedAccountId,
                decoration: _contributionFieldDecoration(
                  context,
                  label: strings.savingsSourceAccountLabel,
                ),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(strings.savingsNoAccountOption),
                  ),
                  ...state.accounts.map(
                    (AccountEntity account) => DropdownMenuItem<String?>(
                      value: account.id,
                      child: Text(account.name),
                    ),
                  ),
                ],
                onChanged: (String? value) => ref
                    .read(contributeControllerProvider(widget.goal).notifier)
                    .selectAccount(value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: _contributionFieldDecoration(
                  context,
                  label: strings.savingsContributionNoteLabel,
                ),
                maxLines: 3,
                onChanged: (String value) => ref
                    .read(contributeControllerProvider(widget.goal).notifier)
                    .updateNote(value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.isSubmitting
                      ? null
                      : () => ref
                            .read(
                              contributeControllerProvider(
                                widget.goal,
                              ).notifier,
                            )
                            .submit(),
                  icon: const Icon(Icons.trending_up),
                  label: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(strings.savingsSubmitContributionButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
