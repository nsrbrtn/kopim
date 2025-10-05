import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/presentation/controllers/edit_goal_controller.dart';
import 'package:kopim/features/savings/presentation/controllers/edit_goal_state.dart';
import 'package:kopim/l10n/app_localizations.dart';

InputDecoration _goalFieldDecoration(
  BuildContext context, {
  required String label,
  String? helper,
  String? error,
}) {
  final ThemeData theme = Theme.of(context);
  const OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    labelText: label,
    helperText: helper,
    errorText: error,
    filled: true,
    fillColor: theme.colorScheme.surfaceContainerHighest,
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  );
}

class AddEditGoalScreen extends ConsumerStatefulWidget {
  const AddEditGoalScreen({super.key, this.goal});

  final SavingGoal? goal;

  static Route<void> route({SavingGoal? goal}) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => AddEditGoalScreen(goal: goal),
    );
  }

  @override
  ConsumerState<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends ConsumerState<AddEditGoalScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _noteController;
  ProviderSubscription<EditGoalState>? _subscription;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetController = TextEditingController(
      text: widget.goal != null
          ? (widget.goal!.targetAmount / 100).toStringAsFixed(2)
          : '',
    );
    _noteController = TextEditingController(text: widget.goal?.note ?? '');
    _subscription = ref.listenManual<EditGoalState>(
      editGoalControllerProvider(widget.goal),
      (EditGoalState? previous, EditGoalState next) {
        if (next.submissionSuccess) {
          final AppLocalizations strings = AppLocalizations.of(context)!;
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.savingsGoalSavedMessage)),
          );
          Navigator.of(context).pop();
        } else if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
          if (!mounted) {
            return;
          }
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
    _nameController.dispose();
    _targetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EditGoalState state = ref.watch(
      editGoalControllerProvider(widget.goal),
    );
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final bool isEditing = widget.goal != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? strings.savingsEditGoalTitle
              : strings.savingsAddGoalTitle,
        ),
      ),
      body: SafeArea(
        child: Form(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: _goalFieldDecoration(
                    context,
                    label: strings.savingsNameLabel,
                    error: state.nameError,
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (String value) => ref
                      .read(editGoalControllerProvider(widget.goal).notifier)
                      .updateName(value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _targetController,
                  decoration: _goalFieldDecoration(
                    context,
                    label: strings.savingsTargetLabel,
                    helper: strings.savingsTargetHelper,
                    error: state.targetError,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (String value) => ref
                      .read(editGoalControllerProvider(widget.goal).notifier)
                      .updateTarget(value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: _goalFieldDecoration(
                    context,
                    label: strings.savingsNoteLabel,
                  ),
                  maxLines: 3,
                  onChanged: (String value) => ref
                      .read(editGoalControllerProvider(widget.goal).notifier)
                      .updateNote(value),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.isSaving
                        ? null
                        : () => ref
                              .read(
                                editGoalControllerProvider(
                                  widget.goal,
                                ).notifier,
                              )
                              .submit(),
                    child: state.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(strings.savingsSaveGoalButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
