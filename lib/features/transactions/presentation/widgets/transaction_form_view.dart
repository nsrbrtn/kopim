import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class TransactionFormView extends ConsumerWidget {
  const TransactionFormView({
    super.key,
    required this.formKey,
    required this.formArgs,
    required this.onSuccess,
    this.submitLabel,
  });

  final GlobalKey<FormState> formKey;
  final TransactionFormArgs formArgs;
  final VoidCallback onSuccess;
  final String? submitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TransactionFormState state = ref.watch(
      transactionFormControllerProvider(formArgs),
    );
    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      transactionFormAccountsProvider,
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      transactionFormCategoriesProvider,
    );

    ref.listen<TransactionFormState>(
      transactionFormControllerProvider(formArgs),
      (TransactionFormState? previous, TransactionFormState next) {
        if (next.isSuccess && previous?.isSuccess != next.isSuccess) {
          ref
              .read(transactionFormControllerProvider(formArgs).notifier)
              .acknowledgeSuccess();
          if (context.mounted) {
            onSuccess();
          }
        } else if (next.error != null && next.error != previous?.error) {
          final String message = switch (next.error) {
            TransactionFormError.accountMissing =>
              strings.addTransactionAccountMissingError,
            TransactionFormError.transactionMissing =>
              strings.transactionFormMissingError,
            _ => strings.addTransactionUnknownError,
          };
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );

    return accountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => _ErrorMessage(
        message: strings.addTransactionAccountsError(error.toString()),
      ),
      data: (List<AccountEntity> accounts) {
        if (accounts.isEmpty) {
          return _EmptyMessage(message: strings.addTransactionNoAccounts);
        }
        return _TransactionForm(
          formKey: formKey,
          state: state,
          accounts: accounts,
          categoriesAsync: categoriesAsync,
          formArgs: formArgs,
          submitLabel: submitLabel ?? strings.addTransactionSubmit,
        );
      },
    );
  }
}

class _TransactionForm extends ConsumerWidget {
  const _TransactionForm({
    required this.formKey,
    required this.state,
    required this.accounts,
    required this.categoriesAsync,
    required this.formArgs,
    required this.submitLabel,
  });

  final GlobalKey<FormState> formKey;
  final TransactionFormState state;
  final List<AccountEntity> accounts;
  final AsyncValue<List<Category>> categoriesAsync;
  final TransactionFormArgs formArgs;
  final String submitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final List<Category> categories = categoriesAsync.maybeWhen(
      data: (List<Category> data) => data,
      orElse: () => const <Category>[],
    );
    final List<Category> filteredCategories = categories
        .where(
          (Category category) =>
              category.type.toLowerCase() == state.type.storageValue,
        )
        .toList(growable: false);

    final String selectedAccountId = state.accountId ?? accounts.first.id;
    if (state.accountId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(transactionFormControllerProvider(formArgs).notifier)
            .updateAccount(selectedAccountId);
      });
    }

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: selectedAccountId,
            decoration: InputDecoration(
              labelText: strings.addTransactionAccountLabel,
            ),
            onChanged: (String? value) {
              ref
                  .read(transactionFormControllerProvider(formArgs).notifier)
                  .updateAccount(value);
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return strings.addTransactionAccountRequired;
              }
              return null;
            },
            items: accounts.map((AccountEntity account) {
              final NumberFormat balanceFormat = NumberFormat.currency(
                locale: strings.localeName,
                symbol: account.currency.toUpperCase(),
              );
              return DropdownMenuItem<String>(
                value: account.id,
                child: Text(
                  '${account.name} · ${balanceFormat.format(account.balance)}',
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.amount,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: InputDecoration(
              labelText: strings.addTransactionAmountLabel,
              hintText: strings.addTransactionAmountHint,
            ),
            onChanged: ref
                .read(transactionFormControllerProvider(formArgs).notifier)
                .updateAmount,
            validator: (_) {
              final double? value = state.parsedAmount;
              if (value == null) {
                return strings.addTransactionAmountInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: InputDecoration(
              labelText: strings.addTransactionTypeLabel,
            ),
            child: SegmentedButton<TransactionType>(
              segments: <ButtonSegment<TransactionType>>[
                ButtonSegment<TransactionType>(
                  value: TransactionType.expense,
                  label: Text(strings.addTransactionTypeExpense),
                ),
                ButtonSegment<TransactionType>(
                  value: TransactionType.income,
                  label: Text(strings.addTransactionTypeIncome),
                ),
              ],
              selected: <TransactionType>{state.type},
              onSelectionChanged: (Set<TransactionType> values) {
                if (values.isEmpty) return;
                ref
                    .read(transactionFormControllerProvider(formArgs).notifier)
                    .updateType(values.first);
              },
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.categoryId ?? '',
            decoration: InputDecoration(
              labelText: strings.addTransactionCategoryLabel,
            ),
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: '',
                child: Text(strings.addTransactionCategoryNone),
              ),
              ...filteredCategories.map(
                (Category category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged: (String? value) {
              ref
                  .read(transactionFormControllerProvider(formArgs).notifier)
                  .updateCategory(value);
            },
          ),
          if (categoriesAsync.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(strings.addTransactionCategoriesLoading),
            ),
          if (categoriesAsync.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                strings.addTransactionCategoriesError(
                  categoriesAsync.error.toString(),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          _DatePickerField(state: state, formArgs: formArgs),
          const SizedBox(height: 16),
          _TimePickerField(state: state, formArgs: formArgs),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.note,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: strings.addTransactionNoteLabel,
            ),
            onChanged: ref
                .read(transactionFormControllerProvider(formArgs).notifier)
                .updateNote,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: state.isSubmitting
                ? null
                : () async {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    await ref
                        .read(
                          transactionFormControllerProvider(formArgs).notifier,
                        )
                        .submit();
                  },
            icon: state.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(submitLabel),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends ConsumerWidget {
  const _DatePickerField({required this.state, required this.formArgs});

  final TransactionFormState state;
  final TransactionFormArgs formArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final DateFormat dateFormat = DateFormat.yMMMd(strings.localeName);
    final DateTime selectedDate = state.date;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event),
      title: Text(strings.addTransactionDateLabel),
      subtitle: Text(dateFormat.format(selectedDate)),
      onTap: () async {
        final DateTime initial = selectedDate;
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          ref
              .read(transactionFormControllerProvider(formArgs).notifier)
              .updateDate(
                DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  initial.hour,
                  initial.minute,
                ),
              );
        }
      },
    );
  }
}

class _TimePickerField extends ConsumerWidget {
  const _TimePickerField({required this.state, required this.formArgs});

  final TransactionFormState state;
  final TransactionFormArgs formArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TimeOfDay selectedTime = TimeOfDay.fromDateTime(state.date);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule),
      title: Text(strings.addTransactionTimeLabel),
      subtitle: Text(localizations.formatTimeOfDay(selectedTime)),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: selectedTime,
          initialEntryMode: TimePickerEntryMode.input,
        );
        if (picked != null) {
          ref
              .read(transactionFormControllerProvider(formArgs).notifier)
              .updateTime(hour: picked.hour, minute: picked.minute);
        }
      },
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
