import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

InputDecoration _transactionTextFieldDecoration(
  BuildContext context, {
  required String labelText,
  String? hintText,
}) {
  final ThemeData theme = Theme.of(context);
  const OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    filled: true,
    fillColor: theme.colorScheme.surfaceContainerHighest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: border,
    enabledBorder: border,
    focusedBorder: border,
  );
}

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
          if (formArgs.initialTransaction == null && context.mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(strings.transactionXpGained)),
              );
          }
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
          accounts: accounts,
          categoriesAsync: categoriesAsync,
          formArgs: formArgs,
          submitLabel: submitLabel ?? strings.addTransactionSubmit,
        );
      },
    );
  }
}

typedef _FormSectionBuilder = Widget Function();

class _TransactionForm extends ConsumerWidget {
  const _TransactionForm({
    required this.formKey,
    required this.accounts,
    required this.categoriesAsync,
    required this.formArgs,
    required this.submitLabel,
  });

  final GlobalKey<FormState> formKey;
  final List<AccountEntity> accounts;
  final AsyncValue<List<Category>> categoriesAsync;
  final TransactionFormArgs formArgs;
  final String submitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(formArgs);
    final bool isSubmitting = ref.watch(
      transactionProvider.select(
        (TransactionFormState state) => state.isSubmitting,
      ),
    );

    final ThemeData theme = Theme.of(context);

    final List<_FormSectionBuilder> sections = <_FormSectionBuilder>[
      () => RepaintBoundary(
        child: _AccountDropdownField(
          key: const ValueKey<String>('transaction_account_field'),
          accounts: accounts,
          formArgs: formArgs,
          strings: strings,
        ),
      ),
      () => const SizedBox(height: 16),
      () => RepaintBoundary(
        child: _AmountField(formArgs: formArgs, strings: strings),
      ),
      () => const SizedBox(height: 16),
      () => RepaintBoundary(
        child: _TransactionTypeSelector(
          key: const ValueKey<String>('transaction_type_selector'),
          formArgs: formArgs,
          strings: strings,
        ),
      ),
      () => const SizedBox(height: 16),
      () => RepaintBoundary(
        child: _CategoryDropdownField(
          key: const ValueKey<String>('transaction_category_field'),
          categoriesAsync: categoriesAsync,
          formArgs: formArgs,
          strings: strings,
        ),
      ),
      if (categoriesAsync.isLoading) () => const SizedBox(height: 8),
      if (categoriesAsync.isLoading)
        () => RepaintBoundary(
          child: _CategoriesStatusMessage(
            key: const ValueKey<String>('transaction_categories_loading'),
            message: strings.addTransactionCategoriesLoading,
          ),
        ),
      if (categoriesAsync.hasError) () => const SizedBox(height: 8),
      if (categoriesAsync.hasError)
        () => RepaintBoundary(
          child: _CategoriesStatusMessage(
            key: const ValueKey<String>('transaction_categories_error'),
            message: strings.addTransactionCategoriesError(
              categoriesAsync.error.toString(),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      () => const SizedBox(height: 16),
      () => RepaintBoundary(child: _DatePickerField(formArgs: formArgs)),
      () => const SizedBox(height: 16),
      () => RepaintBoundary(child: _TimePickerField(formArgs: formArgs)),
      () => const SizedBox(height: 16),
      () => RepaintBoundary(child: _NoteField(formArgs: formArgs)),
      () => const SizedBox(height: 24),
      () => RepaintBoundary(
        child: _SubmitButton(
          key: const ValueKey<String>('transaction_submit_button'),
          formArgs: formArgs,
          formKey: formKey,
          isSubmitting: isSubmitting,
          submitLabel: submitLabel,
        ),
      ),
    ];

    return Form(
      key: formKey,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        cacheExtent: MediaQuery.sizeOf(context).height,
        itemCount: sections.length,
        itemBuilder: (BuildContext context, int index) => sections[index](),
      ),
    );
  }
}

class _AccountDropdownField extends ConsumerWidget {
  const _AccountDropdownField({
    super.key,
    required this.accounts,
    required this.formArgs,
    required this.strings,
  });

  final List<AccountEntity> accounts;
  final TransactionFormArgs formArgs;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(formArgs);
    final String? selectedAccountId = ref.watch(
      transactionProvider.select(
        (TransactionFormState state) => state.accountId,
      ),
    );

    final String? resolvedAccountId =
        selectedAccountId ?? (accounts.isNotEmpty ? accounts.first.id : null);
    if (selectedAccountId == null && resolvedAccountId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(transactionProvider.notifier).updateAccount(resolvedAccountId);
      });
    }

    final Map<String, NumberFormat> cache = <String, NumberFormat>{};

    return DropdownButtonFormField<String>(
      key: key,
      initialValue: resolvedAccountId,
      decoration: InputDecoration(
        labelText: strings.addTransactionAccountLabel,
      ),
      items: accounts
          .map(
            (AccountEntity account) => DropdownMenuItem<String>(
              value: account.id,
              child: Text(
                '${account.name} · '
                '${_resolveFormatter(cache, account.currency, strings.localeName).format(account.balance)}',
              ),
            ),
          )
          .toList(growable: false),
      onChanged: (String? value) {
        ref.read(transactionProvider.notifier).updateAccount(value);
      },
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return strings.addTransactionAccountRequired;
        }
        return null;
      },
    );
  }

  NumberFormat _resolveFormatter(
    Map<String, NumberFormat> cache,
    String currency,
    String locale,
  ) {
    final String upper = currency.toUpperCase();
    return cache.putIfAbsent(
      upper,
      () => NumberFormat.currency(locale: locale, symbol: upper),
    );
  }
}

class _TransactionTypeSelector extends ConsumerWidget {
  const _TransactionTypeSelector({
    super.key,
    required this.formArgs,
    required this.strings,
  });

  final TransactionFormArgs formArgs;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(formArgs);
    final TransactionType type = ref.watch(
      transactionProvider.select((TransactionFormState state) => state.type),
    );

    return InputDecorator(
      decoration: InputDecoration(labelText: strings.addTransactionTypeLabel),
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
        selected: <TransactionType>{type},
        onSelectionChanged: (Set<TransactionType> values) {
          if (values.isEmpty) {
            return;
          }
          ref.read(transactionProvider.notifier).updateType(values.first);
        },
        style: const ButtonStyle(
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(style: BorderStyle.none),
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdownField extends ConsumerWidget {
  const _CategoryDropdownField({
    super.key,
    required this.categoriesAsync,
    required this.formArgs,
    required this.strings,
  });

  final AsyncValue<List<Category>> categoriesAsync;
  final TransactionFormArgs formArgs;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(formArgs);
    final String? selectedCategoryId = ref.watch(
      transactionProvider.select(
        (TransactionFormState state) => state.categoryId,
      ),
    );
    final TransactionType type = ref.watch(
      transactionProvider.select((TransactionFormState state) => state.type),
    );

    final List<Category> categories = categoriesAsync.maybeWhen(
      data: (List<Category> data) => data,
      orElse: () => const <Category>[],
    );

    final List<Category> filteredCategories = categories
        .where(
          (Category category) =>
              category.type.toLowerCase() == type.storageValue,
        )
        .toList(growable: false);

    return DropdownButtonFormField<String>(
      key: key,
      initialValue: selectedCategoryId ?? '',
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
        ref.read(transactionProvider.notifier).updateCategory(value);
      },
    );
  }
}

class _CategoriesStatusMessage extends StatelessWidget {
  const _CategoriesStatusMessage({
    super.key,
    required this.message,
    this.style,
  });

  final String message;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(message, style: style),
    );
  }
}

class _SubmitButton extends ConsumerWidget {
  const _SubmitButton({
    super.key,
    required this.formArgs,
    required this.formKey,
    required this.isSubmitting,
    required this.submitLabel,
  });

  final TransactionFormArgs formArgs;
  final GlobalKey<FormState> formKey;
  final bool isSubmitting;
  final String submitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(formArgs);
    return ElevatedButton.icon(
      key: key,
      onPressed: isSubmitting
          ? null
          : () async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }
              await ref.read(transactionProvider.notifier).submit();
            },
      icon: isSubmitting
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                semanticsLabel: submitLabel,
              ),
            )
          : const ExcludeSemantics(child: Icon(Icons.check)),
      label: Text(submitLabel),
    );
  }
}

class _AmountField extends ConsumerStatefulWidget {
  const _AmountField({required this.formArgs, required this.strings});

  final TransactionFormArgs formArgs;
  final AppLocalizations strings;

  @override
  ConsumerState<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends ConsumerState<_AmountField> {
  late final TextEditingController _controller;
  ProviderSubscription<String>? _subscription;
  Timer? _debounce;
  String _lastSyncedValue = '';

  @override
  void initState() {
    super.initState();
    final TransactionFormState initialState = ref.read(
      transactionFormControllerProvider(widget.formArgs),
    );
    _controller = TextEditingController(text: initialState.amount);
    _lastSyncedValue = initialState.amount;
    _subscription = ref.listenManual<String>(
      transactionFormControllerProvider(
        widget.formArgs,
      ).select((TransactionFormState state) => state.amount),
      (String? previous, String next) {
        if (next == _controller.text) {
          _lastSyncedValue = next;
          return;
        }
        _lastSyncedValue = next;
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _subscription?.close();
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      _pushUpdate(value);
    });
  }

  void _pushUpdate(String value) {
    final String normalized = value.replaceAll(',', '.');
    if (_lastSyncedValue == normalized) {
      return;
    }
    _lastSyncedValue = normalized;
    ref
        .read(transactionFormControllerProvider(widget.formArgs).notifier)
        .updateAmount(normalized);
  }

  void _flushPendingUpdate() {
    _debounce?.cancel();
    final String normalized = _controller.text.replaceAll(',', '.');
    if (_controller.text != normalized) {
      _controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
    _pushUpdate(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSubmitting = ref.watch(
      transactionFormControllerProvider(
        widget.formArgs,
      ).select((TransactionFormState state) => state.isSubmitting),
    );

    return TextFormField(
      controller: _controller,
      enabled: !isSubmitting,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: _transactionTextFieldDecoration(
        context,
        labelText: widget.strings.addTransactionAmountLabel,
        hintText: widget.strings.addTransactionAmountHint,
      ),
      onChanged: _handleChanged,
      onEditingComplete: () {
        _flushPendingUpdate();
        FocusScope.of(context).nextFocus();
      },
      onTapOutside: (_) => _flushPendingUpdate(),
      validator: (_) {
        final double? value = ref
            .read(transactionFormControllerProvider(widget.formArgs))
            .parsedAmount;
        if (value == null) {
          return widget.strings.addTransactionAmountInvalid;
        }
        return null;
      },
    );
  }
}

class _DatePickerField extends ConsumerWidget {
  const _DatePickerField({required this.formArgs});

  final TransactionFormArgs formArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final DateFormat dateFormat = DateFormat.yMMMd(strings.localeName);
    final DateTime selectedDate = ref.watch(
      transactionFormControllerProvider(
        formArgs,
      ).select((TransactionFormState state) => state.date),
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const ExcludeSemantics(child: Icon(Icons.event)),
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
  const _TimePickerField({required this.formArgs});

  final TransactionFormArgs formArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final DateTime selectedDate = ref.watch(
      transactionFormControllerProvider(
        formArgs,
      ).select((TransactionFormState state) => state.date),
    );
    final TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const ExcludeSemantics(child: Icon(Icons.schedule)),
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

class _NoteField extends ConsumerWidget {
  const _NoteField({required this.formArgs});

  final TransactionFormArgs formArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final String note = ref.watch(
      transactionFormControllerProvider(
        formArgs,
      ).select((TransactionFormState state) => state.note),
    );

    return TextFormField(
      initialValue: note,
      minLines: 3,
      maxLines: 3,
      decoration: _transactionTextFieldDecoration(
        context,
        labelText: strings.addTransactionNoteLabel,
      ),
      onChanged: ref
          .read(transactionFormControllerProvider(formArgs).notifier)
          .updateNote,
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
