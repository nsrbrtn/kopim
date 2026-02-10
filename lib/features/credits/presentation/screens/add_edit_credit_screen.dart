import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/core/widgets/kopim_dropdown_field.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/core/widgets/phosphor_icon_picker.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/credits/domain/utils/credit_calculations.dart';
import 'package:kopim/features/accounts/presentation/widgets/account_color_selector.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/edit_upcoming_payment_screen.dart';

class AddEditCreditScreen extends ConsumerStatefulWidget {
  const AddEditCreditScreen({super.key, this.credit});

  final CreditEntity? credit;

  @override
  ConsumerState<AddEditCreditScreen> createState() =>
      _AddEditCreditScreenState();
}

class _AddEditCreditScreenState extends ConsumerState<AddEditCreditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _paymentDayController = TextEditingController();
  bool _isHidden = false;
  bool _isAlreadyIssued = false;
  String? _selectedIssueAccountId;
  PhosphorIconDescriptor? _icon;
  String? _color;
  String? _gradientId;

  // Состояния ошибок для KopimTextField
  bool _nameError = false;
  bool _amountError = false;
  bool _rateError = false;
  bool _termError = false;
  bool _paymentDayError = false;
  bool _issueAccountError = false;

  @override
  void initState() {
    super.initState();
    if (widget.credit != null) {
      final MoneyAmount totalAmount = widget.credit!.totalAmountValue;
      _amountController.text = totalAmount.toDouble().toStringAsFixed(
        totalAmount.scale,
      );
      _rateController.text = widget.credit!.interestRate.toString();
      _termController.text = widget.credit!.termMonths.toString();
      _paymentDayController.text = widget.credit!.paymentDay.toString();

      // Загружаем данные счета
      Future<void>.microtask(() async {
        final AccountEntity? account = await ref
            .read(accountRepositoryProvider)
            .findById(widget.credit!.accountId);
        if (account != null && mounted) {
          setState(() {
            _nameController.text = account.name;
            _color = account.color;
            _gradientId = account.gradientId;
            _isHidden = account.isHidden;
            if (account.iconName != null) {
              _icon = PhosphorIconDescriptor(
                name: account.iconName!,
                style: PhosphorIconStyle.values.firstWhere(
                  (PhosphorIconStyle s) =>
                      s.name == (account.iconStyle ?? 'fill'),
                  orElse: () => PhosphorIconStyle.fill,
                ),
              );
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _rateController.dispose();
    _termController.dispose();
    _paymentDayController.dispose();
    super.dispose();
  }

  bool _validate() {
    final int scale = resolveCurrencyScale('RUB');
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      final MoneyAmount? amount = tryParseMoneyAmount(
        input: _amountController.text,
        scale: scale,
        useAbs: true,
      );
      _amountError = amount == null || amount.minor <= BigInt.zero;
      final double? rate = double.tryParse(_rateController.text);
      _rateError = rate == null || rate < 0;
      final int? term = int.tryParse(_termController.text);
      _termError = term == null || term <= 0;
      final int? day = int.tryParse(_paymentDayController.text);
      _paymentDayError = day == null || day < 1 || day > 31;
      if (widget.credit == null) {
        _issueAccountError =
            !_isAlreadyIssued && _selectedIssueAccountId == null;
      } else {
        _issueAccountError = false;
      }
    });
    return !(_nameError ||
        _amountError ||
        _rateError ||
        _termError ||
        _paymentDayError ||
        _issueAccountError);
  }

  DateTime _resolveFirstPaymentDate(int paymentDay) {
    final DateTime now = DateTime.now();
    final DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    final int maxDay = DateUtils.getDaysInMonth(
      nextMonth.year,
      nextMonth.month,
    );
    final int safeDay = paymentDay.clamp(1, maxDay);
    return DateTime(nextMonth.year, nextMonth.month, safeDay);
  }

  Future<void> _save() async {
    if (_validate()) {
      final String name = _nameController.text.trim();
      final int scale = resolveCurrencyScale('RUB');
      final MoneyAmount amount = tryParseMoneyAmount(
        input: _amountController.text,
        scale: scale,
        useAbs: true,
      )!;
      final double rate = double.parse(_rateController.text);
      final int term = int.parse(_termController.text);
      final int paymentDay = int.parse(_paymentDayController.text);
      if (widget.credit == null) {
        await ref
            .read(addCreditUseCaseProvider)
            .call(
              name: name,
              totalAmount: amount,
              currency: 'RUB', // TODO: Брать из настроек
              interestRate: rate,
              termMonths: term,
              startDate: DateTime.now(),
              firstPaymentDate: _resolveFirstPaymentDate(paymentDay),
              paymentDay: paymentDay,
              targetAccountId: _isAlreadyIssued
                  ? null
                  : _selectedIssueAccountId,
              isAlreadyIssued: _isAlreadyIssued,
              color: _color,
              gradientId: _gradientId,
              iconName: _icon?.name,
              iconStyle: _icon?.style.name,
              isHidden: _isHidden,
            );
      } else {
        await ref
            .read(updateCreditUseCaseProvider)
            .call(
              credit: widget.credit!,
              name: name,
              totalAmount: amount,
              interestRate: rate,
              termMonths: term,
              paymentDay: paymentDay,
              color: _color,
              gradientId: _gradientId,
              iconName: _icon?.name,
              iconStyle: _icon?.style.name,
              isHidden: _isHidden,
            );
      }
      if (mounted) context.pop();
    }
  }

  Future<void> _saveAndConfigurePayment() async {
    if (_validate()) {
      final String name = _nameController.text.trim();
      if (widget.credit == null) {
        final int scale = resolveCurrencyScale('RUB');
        final CreditEntity credit = await ref
            .read(addCreditUseCaseProvider)
            .call(
              name: name,
              totalAmount: tryParseMoneyAmount(
                input: _amountController.text,
                scale: scale,
                useAbs: true,
              )!,
              currency: 'RUB', // TODO: Брать из настроек
              interestRate: double.parse(_rateController.text),
              termMonths: int.parse(_termController.text),
              startDate: DateTime.now(),
              firstPaymentDate: _resolveFirstPaymentDate(
                int.parse(_paymentDayController.text),
              ),
              paymentDay: int.parse(_paymentDayController.text),
              targetAccountId: _isAlreadyIssued
                  ? null
                  : _selectedIssueAccountId,
              isAlreadyIssued: _isAlreadyIssued,
              color: _color,
              iconName: _icon?.name,
              iconStyle: _icon?.style.name,
              isHidden: _isHidden,
            );

        if (mounted) {
          final double amount = calculateAnnuityMonthlyPayment(
            principal: credit.totalAmountValue.abs().toDouble(),
            annualInterestRate: credit.interestRate,
            termMonths: credit.termMonths,
          );

          final EditUpcomingPaymentScreenArgs
          args = EditUpcomingPaymentScreenArgs(
            initialTitle: _nameController.text,
            initialAmount: amount,
            initialCategoryId: credit.categoryId,
            initialDayOfMonth: credit.paymentDay,
            // initialAccountId намеренно не передаем, чтобы использовался основной счет по умолчанию
          );

          // Сначала закрываем текущий экран (кредит уже сохранен)
          context.pop();
          // Затем открываем экран добавления платежа
          context.push(args.location, extra: args);
        }
      }
    }
  }

  Future<void> _delete() async {
    if (widget.credit != null) {
      await ref.read(deleteCreditUseCaseProvider).call(widget.credit!);
      if (mounted) context.pop();
    }
  }

  Future<void> _selectIcon() async {
    final PhosphorIconDescriptor? selection = await showPhosphorIconPicker(
      context: context,
      labels: PhosphorIconPickerLabels(
        title: context.loc.manageCategoriesIconPickerTitle,
        emptyStateLabel: 'Ничего не найдено',
        styleLabels: <PhosphorIconStyle, String>{
          PhosphorIconStyle.thin: 'Тонкий',
          PhosphorIconStyle.light: 'Легкий',
          PhosphorIconStyle.regular: 'Обычный',
          PhosphorIconStyle.bold: 'Жирный',
          PhosphorIconStyle.fill: 'Заливка',
        },
        groupLabels: const <String, String>{
          'finance': 'Финансы',
          'loans': 'Кредиты',
          'transactionTypes': 'Типы транзакций',
        },
      ),
      initial: _icon,
      allowedStyles: const <PhosphorIconStyle>{PhosphorIconStyle.fill},
    );
    if (selection != null) {
      setState(() => _icon = selection);
    }
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
          widget.credit == null
              ? context.loc.creditsAddTitle
              : context.loc.creditsEditTitle,
        ),
        actions: <Widget>[
          if (widget.credit != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Удалить кредит?'),
                    content: const Text(
                      'Все связанные данные, включая счет и категорию, будут удалены.',
                    ),
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
      body: Form(
        key: _formKey,
        child: StreamBuilder<List<AccountEntity>>(
          stream: accountsAsync,
          builder: (BuildContext context, AsyncSnapshot<List<AccountEntity>> snapshot) {
            final List<AccountEntity> accounts =
                snapshot.data ?? const <AccountEntity>[];
            final List<AccountEntity> availableIssueAccounts = accounts
                .where((AccountEntity account) => account.type != 'credit')
                .toList(growable: false);
            if (_selectedIssueAccountId != null &&
                !availableIssueAccounts.any(
                  (AccountEntity account) =>
                      account.id == _selectedIssueAccountId,
                )) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _selectedIssueAccountId = null;
                  _issueAccountError = false;
                });
              });
            }
            return ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                KopimTextField(
                  controller: _nameController,
                  placeholder: context.loc.creditsNameLabel,
                  prefixIcon: const Icon(Icons.edit_outlined),
                  hasError: _nameError,
                ),
                const SizedBox(height: 16),
                KopimTextField(
                  controller: _amountController,
                  placeholder: context.loc.creditsAmountLabel,
                  prefixIcon: const Icon(Icons.account_balance_outlined),
                  keyboardType: TextInputType.number,
                  hasError: _amountError,
                ),
                const SizedBox(height: 16),
                KopimTextField(
                  controller: _rateController,
                  placeholder: context.loc.creditsInterestRateLabel,
                  prefixIcon: const Icon(Icons.percent_outlined),
                  keyboardType: TextInputType.number,
                  hasError: _rateError,
                ),
                const SizedBox(height: 16),
                KopimTextField(
                  controller: _termController,
                  placeholder: context.loc.creditsTermMonthsLabel,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  keyboardType: TextInputType.number,
                  hasError: _termError,
                ),
                const SizedBox(height: 16),
                KopimTextField(
                  controller: _paymentDayController,
                  placeholder: context.loc.creditsPaymentDayLabel,
                  prefixIcon: const Icon(Icons.event_outlined),
                  keyboardType: TextInputType.number,
                  hasError: _paymentDayError,
                ),
                if (widget.credit == null) ...<Widget>[
                  const SizedBox(height: 24),
                  Text('Выдача кредита', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Кредит уже выдан'),
                    subtitle: Text(
                      'В этом случае создается отрицательный баланс на кредитном счете',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: _isAlreadyIssued,
                    onChanged: (bool value) {
                      setState(() {
                        _isAlreadyIssued = value;
                        if (_isAlreadyIssued) {
                          _selectedIssueAccountId = null;
                        }
                        _issueAccountError = false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  KopimDropdownField<String>(
                    value: _selectedIssueAccountId,
                    items: availableIssueAccounts
                        .map(
                          (AccountEntity account) => DropdownMenuItem<String>(
                            value: account.id,
                            child: Text(account.name),
                          ),
                        )
                        .toList(growable: false),
                    label: 'Счет зачисления',
                    hint: availableIssueAccounts.isEmpty
                        ? 'Нет доступных счетов'
                        : 'Выберите счет',
                    enabled:
                        !_isAlreadyIssued && availableIssueAccounts.isNotEmpty,
                    onChanged: (String value) {
                      setState(() {
                        _selectedIssueAccountId = value;
                        _issueAccountError = false;
                      });
                    },
                  ),
                  if (_issueAccountError) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      'Выберите счет для зачисления или отметьте, что кредит уже выдан',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                Text(
                  context.loc.profileThemeHeader,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: _icon != null
                        ? Icon(
                            resolvePhosphorIconData(_icon!),
                            color: theme.colorScheme.onSurface,
                          )
                        : Icon(
                            Icons.category_outlined,
                            color: theme.colorScheme.onSurface,
                          ),
                  ),
                  title: Text(context.loc.manageCategoriesIconLabel),
                  subtitle: Text(_icon != null ? 'Выбрана' : 'Не выбрана'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectIcon,
                ),
                AccountColorSelector(
                  color: _color,
                  gradientId: _gradientId,
                  enabled: true,
                  onStyleChanged: (AccountCardStyleSelection selection) {
                    setState(() {
                      _color = selection.color;
                      _gradientId = selection.gradientId;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text(context.loc.creditsHiddenOnDashboardLabel),
                  subtitle: Text(
                    'Счет не будет отображаться в списке счетов на главном экране',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _isHidden,
                  onChanged: (bool v) => setState(() => _isHidden = v),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: EdgeInsets.zero,
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
                    context.loc.creditsSaveAction,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.credit == null) ...<Widget>[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _saveAndConfigurePayment,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Сохранить и настроить платеж',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
