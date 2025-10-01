import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  static const String routeName = '/transactions/add';

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ref.listen<AddTransactionState>(
      addTransactionControllerProvider,
          (AddTransactionState? previous, AddTransactionState next) {
        if (next.isSuccess && previous?.isSuccess != next.isSuccess) {
          ref.read(addTransactionControllerProvider.notifier).acknowledgeSuccess();
          Navigator.of(context).pop(true);
        } else if (next.error != null && next.error != previous?.error) {
          final AppLocalizations strings = AppLocalizations.of(context)!;
          final String message = switch (next.error) {
            AddTransactionError.accountMissing =>
            strings.addTransactionAccountMissingError,
            _ => strings.addTransactionUnknownError,
          };
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );

    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AddTransactionState state =
    ref.watch(addTransactionControllerProvider);
    final AsyncValue<List<AccountEntity>> accountsAsync =
    ref.watch(addTransactionAccountsProvider);
    final AsyncValue<List<Category>> categoriesAsync =
    ref.watch(addTransactionCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.addTransactionTitle)),
      body: SafeArea(
        child: accountsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => _ErrorMessage(
            message: strings.addTransactionAccountsError(error.toString()),
          ),
          data: (List<AccountEntity> accounts) {
            if (accounts.isEmpty) {
              return _EmptyMessage(message: strings.addTransactionNoAccounts);
            }
            return _TransactionForm(
              formKey: _formKey,
              state: state,
              accounts: accounts,
              categoriesAsync: categoriesAsync,
            );
          },
        ),
      ),
    );
  }
}

class _TransactionForm extends ConsumerWidget {
  const _TransactionForm({
    required this.formKey,
    required this.state,
    required this.accounts,
    required this.categoriesAsync,
  });

  final GlobalKey<FormState> formKey;
  final AddTransactionState state;
  final List<AccountEntity> accounts;
  final AsyncValue<List<Category>> categoriesAsync;

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
        ref.read(addTransactionControllerProvider.notifier).updateAccount(selectedAccountId);
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
              ref.read(addTransactionControllerProvider.notifier).updateAccount(value);
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return strings.addTransactionAccountRequired;
              }
              return null;
            },
            items: accounts.map(
                  (AccountEntity account) {
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
              },
            ).toList(),
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
            onChanged: ref.read(addTransactionControllerProvider.notifier).updateAmount,
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
                ref.read(addTransactionControllerProvider.notifier).updateType(values.first);
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
              ref.read(addTransactionControllerProvider.notifier).updateCategory(value);
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
                strings.addTransactionCategoriesError(categoriesAsync.error.toString()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          _DatePickerField(state: state),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.note,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: strings.addTransactionNoteLabel,
            ),
            onChanged: ref.read(addTransactionControllerProvider.notifier).updateNote,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: state.isSubmitting
                ? null
                : () async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }
              await ref.read(addTransactionControllerProvider.notifier).submit();
            },
            icon: state.isSubmitting
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.check),
            label: Text(strings.addTransactionSubmit),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends ConsumerWidget {
  const _DatePickerField({required this.state});

  final AddTransactionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final DateFormat dateFormat = DateFormat.yMMMd(strings.localeName);
    final DateTime selectedDate = state.selectedDate ?? DateTime.now();

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
          ref.read(addTransactionControllerProvider.notifier).updateDate(
            DateTime(picked.year, picked.month, picked.day, initial.hour, initial.minute),
          );
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
