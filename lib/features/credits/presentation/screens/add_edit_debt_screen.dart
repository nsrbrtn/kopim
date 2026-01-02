import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/core/widgets/kopim_dropdown_field.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/edit_payment_reminder_screen.dart';

class AddEditDebtScreen extends ConsumerStatefulWidget {
  const AddEditDebtScreen({super.key, this.debt});

  final DebtEntity? debt;

  @override
  ConsumerState<AddEditDebtScreen> createState() => _AddEditDebtScreenState();
}

class _AddEditDebtScreenState extends ConsumerState<AddEditDebtScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedAccountId;
  DateTime? _selectedDueDate;

  bool _nameError = false;
  bool _amountError = false;
  bool _accountError = false;
  bool _dateError = false;
  bool _didInitFromDependencies = false;

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      _nameController.text = widget.debt!.name;
      _amountController.text = widget.debt!.amount.toString();
      _noteController.text = widget.debt!.note ?? '';
      _selectedAccountId = widget.debt!.accountId;
      _selectedDueDate = widget.debt!.dueDate;
    } else {
      final DateTime now = DateTime.now();
      _selectedDueDate = now;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitFromDependencies) return;
    _didInitFromDependencies = true;
    if (widget.debt != null && _nameController.text.trim().isEmpty) {
      _nameController.text = context.loc.debtsDefaultTitle;
    }
    final DateTime? dueDate = _selectedDueDate;
    if (dueDate != null) {
      _dateController.text = _formatDate(dueDate);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      _nameError = _nameController.text.trim().isEmpty;
      _amountError = double.tryParse(_amountController.text) == null;
      _accountError = _selectedAccountId == null;
      _dateError = _selectedDueDate == null;
    });
    return !(_nameError || _amountError || _accountError || _dateError);
  }

  Future<void> _save() async {
    if (!_validate()) return;
    if (widget.debt == null) {
      await ref.read(addDebtUseCaseProvider).call(
        accountId: _selectedAccountId!,
        name: _nameController.text.trim(),
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
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      dueDate: _selectedDueDate!,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    if (mounted) {
      final EditPaymentReminderScreenArgs args =
          EditPaymentReminderScreenArgs(
            initialTitle: _nameController.text.trim(),
            initialAmount: double.parse(_amountController.text),
            initialWhenLocal: _selectedDueDate,
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
    final Stream<List<CreditEntity>> creditsAsync = ref
        .watch(watchCreditsUseCaseProvider)
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
              return StreamBuilder<List<CreditEntity>>(
                stream: creditsAsync,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<CreditEntity>> creditsSnapshot,
                ) {
                  final Set<String> creditAccountIds =
                      creditsSnapshot.data
                          ?.map((CreditEntity credit) => credit.accountId)
                          .toSet() ??
                      <String>{};
                  final List<AccountEntity> availableAccounts =
                      accounts
                          .where(
                            (AccountEntity account) =>
                                !creditAccountIds.contains(account.id),
                          )
                          .toList();
                  if (availableAccounts.isEmpty) {
                    return Center(
                      child: Text(context.loc.addTransactionNoAccounts),
                    );
                  }
                  if (_selectedAccountId == null ||
                      !availableAccounts.any(
                        (AccountEntity account) =>
                            account.id == _selectedAccountId,
                      )) {
                    final AccountEntity primary = availableAccounts.firstWhere(
                      (AccountEntity account) => account.isPrimary,
                      orElse: () => availableAccounts.first,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
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
                        KopimTextField(
                          controller: _nameController,
                          placeholder: context.loc.debtsNameLabel,
                          prefixIcon: const Icon(Icons.receipt_long_outlined),
                          hasError: _nameError,
                        ),
                        const SizedBox(height: 16),
                        KopimDropdownField<String>(
                          value: _selectedAccountId,
                          items: availableAccounts
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
                          enabled: availableAccounts.isNotEmpty,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
      ),
    );
  }
}
