import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/recurring_transactions/presentation/widgets/recurring_rule_form_view.dart';
import 'package:kopim/l10n/app_localizations.dart';

class AddRecurringRuleScreen extends ConsumerStatefulWidget {
  const AddRecurringRuleScreen({super.key});

  static const String routeName = '/recurring-transactions/add';

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
    return Scaffold(
      appBar: AppBar(title: Text(strings.addRecurringRuleTitle)),
      body: SafeArea(
        child: RecurringRuleFormView(
          formKey: _formKey,
          onSuccess: () {
            if (!context.mounted) return;
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
  }
}
