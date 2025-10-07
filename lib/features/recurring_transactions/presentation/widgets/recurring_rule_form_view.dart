import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_rule_form_controller.dart';
import 'package:kopim/features/recurring_transactions/presentation/models/recurring_rule_form_result.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_scheduler.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/l10n/app_localizations.dart';

class RecurringRuleFormView extends ConsumerWidget {
  const RecurringRuleFormView({
    super.key,
    required this.formKey,
    required this.onSuccess,
    this.initialRule,
  });

  final GlobalKey<FormState> formKey;
  final ValueChanged<RecurringRuleFormResult> onSuccess;
  final RecurringRule? initialRule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final RecurringRuleFormControllerProvider provider =
        recurringRuleFormControllerProvider(initialRule: initialRule);
    final RecurringRuleFormState state = ref.watch(provider);
    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      recurringRuleAccountsProvider,
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      recurringRuleCategoriesProvider,
    );

    ref.listen<RecurringRuleFormState>(provider, (
      RecurringRuleFormState? previous,
      RecurringRuleFormState next,
    ) {
      if (next.submissionSuccess && previous?.submissionSuccess != true) {
        ref.read(provider.notifier).acknowledgeSuccess();
        if (context.mounted) {
          final RecurringRuleFormResult result = next.isEditing
              ? RecurringRuleFormResult.updated
              : RecurringRuleFormResult.created;
          onSuccess(result);
        }
      } else if (next.generalErrorMessage != null &&
          next.generalErrorMessage != previous?.generalErrorMessage &&
          context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.generalErrorMessage!)));
      }
    });

    return accountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => _ErrorMessage(message: error.toString()),
      data: (List<AccountEntity> accounts) {
        if (accounts.isEmpty) {
          return _ErrorMessage(message: strings.addRecurringRuleNoAccounts);
        }
        return categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => _ErrorMessage(message: error.toString()),
          data: (List<Category> categories) {
            if (state.account == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AccountEntity? selected;
                if (state.accountId != null) {
                  for (final AccountEntity account in accounts) {
                    if (account.id == state.accountId) {
                      selected = account;
                      break;
                    }
                  }
                }
                ref
                    .read(provider.notifier)
                    .updateAccount(selected ?? accounts.first);
              });
            }
            final List<Category> filteredCategories = categories
                .where(
                  (Category category) =>
                      !category.isDeleted &&
                      category.type == state.type.storageValue,
                )
                .toList(growable: false);
            if (filteredCategories.isEmpty) {
              return _ErrorMessage(
                message: strings.addRecurringRuleNoCategories,
              );
            }
            if (state.category == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Category? selected;
                if (state.categoryId != null) {
                  for (final Category category in filteredCategories) {
                    if (category.id == state.categoryId) {
                      selected = category;
                      break;
                    }
                  }
                }
                ref
                    .read(provider.notifier)
                    .updateCategory(selected ?? filteredCategories.first);
              });
            }
            return _RecurringRuleForm(
              formKey: formKey,
              state: state,
              accounts: accounts,
              categories: filteredCategories,
              initialRule: initialRule,
            );
          },
        );
      },
    );
  }
}

class _RecurringRuleForm extends ConsumerWidget {
  const _RecurringRuleForm({
    required this.formKey,
    required this.state,
    required this.accounts,
    required this.categories,
    required this.initialRule,
  });

  final GlobalKey<FormState> formKey;
  final RecurringRuleFormState state;
  final List<AccountEntity> accounts;
  final List<Category> categories;
  final RecurringRule? initialRule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final DateFormat dateFormat = DateFormat.yMMMMd(strings.localeName);
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    final DateTime? previewNextDue = _resolvePreviewNextDue(state);
    final String nextDueText = previewNextDue == null
        ? strings.addRecurringRuleNextDuePreviewUnknown
        : dateFormat.format(previewNextDue);

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          TextFormField(
            initialValue: state.title,
            decoration: InputDecoration(
              labelText: strings.addRecurringRuleNameLabel,
              errorText: state.titleError == null
                  ? null
                  : strings.addRecurringRuleTitleRequired,
            ),
            onChanged: ref
                .read(
                  recurringRuleFormControllerProvider(
                    initialRule: initialRule,
                  ).notifier,
                )
                .updateTitle,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.amountInput,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: InputDecoration(
              labelText: strings.addRecurringRuleAmountLabel,
              hintText: strings.addRecurringRuleAmountHint,
              errorText: state.amountError == null
                  ? null
                  : strings.addRecurringRuleAmountInvalid,
            ),
            onChanged: ref
                .read(
                  recurringRuleFormControllerProvider(
                    initialRule: initialRule,
                  ).notifier,
                )
                .updateAmount,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.notes,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: strings.addRecurringRuleNoteLabel,
              hintText: strings.addRecurringRuleNoteHint,
            ),
            onChanged: ref
                .read(
                  recurringRuleFormControllerProvider(
                    initialRule: initialRule,
                  ).notifier,
                )
                .updateNotes,
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: InputDecoration(
              labelText: strings.addRecurringRuleAccountLabel,
              errorText: state.accountError == null
                  ? null
                  : strings.addRecurringRuleAccountRequired,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.account?.id,
                hint: Text(strings.addRecurringRuleAccountLabel),
                isExpanded: true,
                items: accounts
                    .map(
                      (AccountEntity account) => DropdownMenuItem<String>(
                        value: account.id,
                        child: Text('${account.name} · ${account.currency}'),
                      ),
                    )
                    .toList(growable: false),
                onChanged: state.isSubmitting
                    ? null
                    : (String? value) {
                        final AccountEntity? account = value == null
                            ? null
                            : accounts.firstWhere(
                                (AccountEntity item) => item.id == value,
                              );
                        ref
                            .read(
                              recurringRuleFormControllerProvider(
                                initialRule: initialRule,
                              ).notifier,
                            )
                            .updateAccount(account);
                      },
              ),
            ),
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: InputDecoration(
              labelText: strings.addRecurringRuleCategoryLabel,
              errorText: state.categoryError == null
                  ? null
                  : strings.addRecurringRuleCategoryRequired,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.category?.id,
                hint: Text(strings.addRecurringRuleCategoryLabel),
                isExpanded: true,
                items: categories
                    .map(
                      (Category category) => DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: state.isSubmitting
                    ? null
                    : (String? value) {
                        final Category? category = value == null
                            ? null
                            : categories.firstWhere(
                                (Category item) => item.id == value,
                              );
                        ref
                            .read(
                              recurringRuleFormControllerProvider(
                                initialRule: initialRule,
                              ).notifier,
                            )
                            .updateCategory(category);
                      },
              ),
            ),
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: InputDecoration(
              labelText: strings.addRecurringRuleTypeLabel,
            ),
            child: SegmentedButton<TransactionType>(
              segments: <ButtonSegment<TransactionType>>[
                ButtonSegment<TransactionType>(
                  value: TransactionType.expense,
                  label: Text(strings.addRecurringRuleTypeExpense),
                ),
                ButtonSegment<TransactionType>(
                  value: TransactionType.income,
                  label: Text(strings.addRecurringRuleTypeIncome),
                ),
              ],
              selected: <TransactionType>{state.type},
              onSelectionChanged: (Set<TransactionType> values) {
                if (values.isEmpty) return;
                ref
                    .read(
                      recurringRuleFormControllerProvider(
                        initialRule: initialRule,
                      ).notifier,
                    )
                    .updateType(values.first);
              },
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(strings.addRecurringRuleStartDateLabel),
            subtitle: Text(dateFormat.format(state.startDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final DateTime? selected = await showDatePicker(
                context: context,
                initialDate: state.startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selected != null && context.mounted) {
                ref
                    .read(
                      recurringRuleFormControllerProvider(
                        initialRule: initialRule,
                      ).notifier,
                    )
                    .updateStartDate(selected);
              }
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(strings.addRecurringRuleStartTimeLabel),
            subtitle: Text(
              materialLocalizations.formatTimeOfDay(
                TimeOfDay(hour: state.applyHour, minute: state.applyMinute),
                alwaysUse24HourFormat: MediaQuery.of(
                  context,
                ).alwaysUse24HourFormat,
              ),
            ),
            trailing: const Icon(Icons.schedule),
            enabled: false,
          ),
          const SizedBox(height: 16),
          Text(
            '${strings.addRecurringRuleNextDuePreviewLabel}: $nextDueText',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          KeyedSubtree(
            key: const ValueKey<String>('recurringRuleAutoPostTile'),
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.addRecurringRuleAutoPostLabel),
              value: state.autoPost,
              onChanged: state.isSubmitting
                  ? null
                  : ref
                        .read(
                          recurringRuleFormControllerProvider(
                            initialRule: initialRule,
                          ).notifier,
                        )
                        .updateAutoPost,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: state.isSubmitting
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    ref
                        .read(
                          recurringRuleFormControllerProvider(
                            initialRule: initialRule,
                          ).notifier,
                        )
                        .submit();
                  },
            child: state.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    state.isEditing
                        ? strings.editRecurringRuleSubmit
                        : strings.addRecurringRuleSubmit,
                  ),
          ),
        ],
      ),
    );
  }
}

DateTime? _resolvePreviewNextDue(RecurringRuleFormState state) {
  if (state.accountId == null || state.categoryId == null) {
    return null;
  }
  final DateTime startLocal = DateTime(
    state.startDate.year,
    state.startDate.month,
    state.startDate.day,
    state.applyHour,
    state.applyMinute,
  );
  final RecurringRule rule = RecurringRule(
    id: 'preview',
    title: state.title.isEmpty ? 'preview' : state.title,
    accountId: state.accountId!,
    categoryId: state.categoryId!,
    amount: state.type == TransactionType.expense ? 1 : -1,
    currency: state.account?.currency ?? 'EUR',
    startAt: startLocal,
    timezone: 'Europe/Helsinki',
    rrule: 'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=${state.startDate.day}',
    notes: null,
    dayOfMonth: state.startDate.day,
    applyAtLocalHour: state.applyHour,
    applyAtLocalMinute: state.applyMinute,
    lastRunAt: null,
    nextDueLocalDate: startLocal,
    isActive: true,
    autoPost: state.autoPost,
    reminderMinutesBefore: null,
    shortMonthPolicy: RecurringRuleShortMonthPolicy.clipToLastDay,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  final RecurringRuleScheduleResult result = const RecurringRuleScheduler()
      .resolve(rule: rule, now: DateTime.now());
  if (result.dueDates.isNotEmpty) {
    return result.dueDates.last;
  }
  return result.nextDue;
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
