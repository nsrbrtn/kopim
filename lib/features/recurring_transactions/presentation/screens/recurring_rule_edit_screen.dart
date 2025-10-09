import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_transactions_providers.dart';
import 'package:kopim/features/recurring_transactions/presentation/models/recurring_rule_form_result.dart';
import 'package:kopim/features/recurring_transactions/presentation/widgets/recurring_rule_form_view.dart';
import 'package:kopim/l10n/app_localizations.dart';

class RecurringRuleEditScreen extends ConsumerStatefulWidget {
  const RecurringRuleEditScreen({super.key, required this.ruleId});

  static const String routeName = '/recurring-transactions/edit';

  final String ruleId;

  @override
  ConsumerState<RecurringRuleEditScreen> createState() =>
      _RecurringRuleEditScreenState();
}

class _RecurringRuleEditScreenState
    extends ConsumerState<RecurringRuleEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<RecurringRule?> ruleAsync = ref.watch(
      recurringRuleByIdProvider(widget.ruleId),
    );

    return ruleAsync.when(
      data: (RecurringRule? rule) {
        if (rule == null) {
          return Scaffold(
            appBar: AppBar(title: Text(strings.editRecurringRuleTitle)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.homeUpcomingPaymentsMissingRule,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(strings.cancelButtonLabel),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(strings.editRecurringRuleTitle)),
          body: SafeArea(
            child: RecurringRuleFormView(
              formKey: _formKey,
              initialRule: rule,
              onSuccess: (RecurringRuleFormResult result) {
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop(result);
              },
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(strings.editRecurringRuleTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stackTrace) => Scaffold(
        appBar: AppBar(title: Text(strings.editRecurringRuleTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              strings.genericErrorMessage,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
