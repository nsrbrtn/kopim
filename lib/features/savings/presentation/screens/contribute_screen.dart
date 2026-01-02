import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/widgets/kopim_dropdown_field.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/value_objects/goal_progress.dart';
import 'package:kopim/features/savings/presentation/controllers/contribute_controller.dart';
import 'package:kopim/features/savings/presentation/controllers/contribute_state.dart';
import 'package:kopim/l10n/app_localizations.dart';

const String _noAccountValue = '__no_account__';

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
    final KopimLayout layout = context.kopimLayout;
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
    );
    final String remainingLabel = currencyFormat.format(
      progress.remaining.minorUnits / 100,
    );
    final List<DropdownMenuItem<String>> accountItems =
        <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: _noAccountValue,
        child: Text(strings.savingsNoAccountOption),
      ),
      ...state.accounts.map(
        (AccountEntity account) => DropdownMenuItem<String>(
          value: account.id,
          child: Text(account.name),
        ),
      ),
    ];
    final String selectedAccountValue =
        state.selectedAccountId ?? _noAccountValue;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.savingsContributeTitle(widget.goal.name)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(layout.radius.card),
                ),
                clipBehavior: Clip.antiAlias,
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
              KopimTextField(
                controller: _amountController,
                placeholder: strings.savingsAmountLabel,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                hasError:
                    state.amountError != null && state.amountError!.isNotEmpty,
                onChanged: (String value) => ref
                    .read(contributeControllerProvider(widget.goal).notifier)
                    .updateAmount(value),
              ),
              if (state.amountError != null && state.amountError!.isNotEmpty)
                _FieldErrorText(message: state.amountError!),
              const SizedBox(height: 16),
              KopimDropdownField<String>(
                value: selectedAccountValue,
                items: accountItems,
                label: strings.savingsSourceAccountLabel,
                hint: strings.savingsNoAccountOption,
                enabled: accountItems.isNotEmpty,
                onChanged: (String value) => ref
                    .read(contributeControllerProvider(widget.goal).notifier)
                    .selectAccount(
                      value == _noAccountValue ? null : value,
                    ),
              ),
              const SizedBox(height: 16),
              KopimTextField(
                controller: _noteController,
                placeholder: strings.savingsContributionNoteLabel,
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

class _FieldErrorText extends StatelessWidget {
  const _FieldErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
