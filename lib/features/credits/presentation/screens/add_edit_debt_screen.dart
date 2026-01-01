import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/core/widgets/kopim_dropdown_field.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/domain/use_cases/add_debt_use_case.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/edit_upcoming_payment_screen.dart';

class AddEditDebtScreen extends ConsumerStatefulWidget {
  const AddEditDebtScreen({super.key, this.debt});

  final DebtEntity? debt;

  @override
  ConsumerState<AddEditDebtScreen> createState() => _AddEditDebtScreenState();
}

class _AddEditDebtScreenState extends ConsumerState<AddEditDebtScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedAccountId;
  DateTime? _selectedDueDate;

  bool _amountError = false;
  bool _accountError = false;
  bool _dateError = false;

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      _amountController.text = widget.debt!.amount.toString();
      _noteController.text = widget.debt!.note ?? '';
      _selectedAccountId = widget.debt!.accountId;
      _selectedDueDate = widget.debt!.dueDate;
      _dateController.text = _formatDate(widget.debt!.dueDate);
    } else {
      final DateTime now = DateTime.now();
      _selectedDueDate = now;
      _dateController.text = _formatDate(now);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat.yMMMd(context.loc.localeName);
    return formatter.format(date);
  }

  bool _validate() {
    setState(() {
      _amountError = double.tryParse(_amountController.text) == null;
      _accountError = _selectedAccountId == null;
      _dateError = _selectedDueDate == null;
    });
    return !(_amountError || _accountError || _dateError);
  }

  Future<void> _save() async {
    if (!_validate()) return;
    if (widget.debt == null) {
      await ref.read(addDebtUseCaseProvider).call(
        accountId: _selectedAccountId!,
        amount: double.parse(_amountController.text),
        dueDate: _selectedDueDate!,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
    } else {
      // В рамках текущей задачи реализуем только создание и удаление.
    }
    if (mounted) context.pop();
  }

  Future<void> _saveAndConfigurePayment() async {
    if (!_validate()) return;
    if (widget.debt != null) {
      return;
    }
    await ref.read(addDebtUseCaseProvider).call(
      accountId: _selectedAccountId!,
      amount: double.parse(_amountController.text),
      dueDate: _selectedDueDate!,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    final Category? category = await ref
        .read(categoryRepositoryProvider)
        .findByName(AddDebtUseCase.returnDebtCategoryName);
    if (mounted) {
      final String title = _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : context.loc.debtsDefaultTitle;
      final EditUpcomingPaymentScreenArgs args = EditUpcomingPaymentScreenArgs(
        initialTitle: title,
        initialAmount: double.parse(_amountController.text),
        initialAccountId: _selectedAccountId,
        initialCategoryId: category?.id,
        initialDayOfMonth: _selectedDueDate?.day,
      );

      context.pop();
      context.push(args.location, extra: args);
    }
  }

  Future<void> _delete() async {
    if (widget.debt != null) {
      await ref.read(deleteDebtUseCaseProvider).call(widget.debt!);
      if (mounted) context.pop();
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime initial = _selectedDueDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selectedDueDate = picked;
      _dateController.text = _formatDate(picked);
      _dateError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Stream<List<AccountEntity>> accountsAsync = ref
        .watch(watchAccountsUseCaseProvider)
        .call();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.debt == null
              ? context.loc.debtsAddTitle
              : context.loc.debtsEditTitle,
        ),
        actions: <Widget>[
          if (widget.debt != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Удалить долг?'),
                    content: const Text('Запись будет удалена без возможности восстановления.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _delete();
                        },
                        child: const Text('Удалить'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<List<AccountEntity>>(
        stream: accountsAsync,
        builder:
            (BuildContext context, AsyncSnapshot<List<AccountEntity>> snapshot) {
              final List<AccountEntity> accounts =
                  snapshot.data ?? <AccountEntity>[];
              if (accounts.isEmpty) {
                return Center(
                  child: Text(context.loc.addTransactionNoAccounts),
                );
              }
              if (_selectedAccountId == null) {
                final AccountEntity primary = accounts.firstWhere(
                  (AccountEntity account) => account.isPrimary,
                  orElse: () => accounts.first,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _selectedAccountId == null) {
                    setState(() {
                      _selectedAccountId = primary.id;
                      _accountError = false;
                    });
                  }
                });
              }
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: <Widget>[
                    KopimDropdownField<String>(
                      value: _selectedAccountId,
                      items: accounts
                          .map(
                            (AccountEntity account) =>
                                DropdownMenuItem<String>(
                                  value: account.id,
                                  child: Text(account.name),
                                ),
                          )
                          .toList(growable: false),
                      label: context.loc.debtsAccountLabel,
                      hint: context.loc.debtsAccountHint,
                      enabled: accounts.isNotEmpty,
                      onChanged: (String value) {
                        setState(() {
                          _selectedAccountId = value;
                          _accountError = false;
                        });
                      },
                    ),
                    if (_accountError) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        context.loc.debtsAccountError,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    KopimTextField(
                      controller: _amountController,
                      placeholder: context.loc.debtsAmountLabel,
                      prefixIcon: const Icon(Icons.payments_outlined),
                      keyboardType: TextInputType.number,
                      hasError: _amountError,
                    ),
                    const SizedBox(height: 16),
                    KopimTextField(
                      controller: _dateController,
                      placeholder: context.loc.debtsDueDateLabel,
                      prefixIcon: const Icon(Icons.event_outlined),
                      readOnly: true,
                      onTap: _selectDueDate,
                      hasError: _dateError,
                    ),
                    const SizedBox(height: 16),
                    KopimTextField(
                      controller: _noteController,
                      placeholder: context.loc.debtsNoteLabel,
                      prefixIcon: const Icon(Icons.edit_note_outlined),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        context.loc.debtsSaveAction,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (widget.debt == null) ...<Widget>[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _saveAndConfigurePayment,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          context.loc.debtsSaveAndScheduleAction,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
      ),
    );
  }
}
