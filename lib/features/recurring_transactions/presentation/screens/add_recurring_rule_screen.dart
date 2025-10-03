import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/presentation/models/recurring_rule_form_result.dart';
import 'package:kopim/features/recurring_transactions/presentation/widgets/recurring_rule_form_view.dart';
import 'package:kopim/l10n/app_localizations.dart';

class AddRecurringRuleScreen extends ConsumerStatefulWidget {
  const AddRecurringRuleScreen({super.key, this.initialRule});

  static const String routeName = '/recurring-transactions/add';
  final RecurringRule? initialRule;

  @override
  ConsumerState<AddRecurringRuleScreen> createState() =>
      _AddRecurringRuleScreenState();
}

class _AddRecurringRuleScreenState
    extends ConsumerState<AddRecurringRuleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final bool isEditing = widget.initialRule != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? strings.editRecurringRuleTitle
              : strings.addRecurringRuleTitle,
        ),
      ),
      body: SafeArea(
        child: RecurringRuleFormView(
          formKey: _formKey,
          initialRule: widget.initialRule,
          onSuccess: (RecurringRuleFormResult result) {
            if (!context.mounted) return;
            Navigator.of(context).pop(result);
          },
        ),
      ),
    );
  }
}
