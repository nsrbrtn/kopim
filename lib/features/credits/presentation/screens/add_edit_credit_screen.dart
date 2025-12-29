import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/core/widgets/phosphor_icon_picker.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
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
  bool _isHidden = false;
  PhosphorIconDescriptor? _icon;
  String? _color;

  // Состояния ошибок для KopimTextField
  bool _nameError = false;
  bool _amountError = false;
  bool _rateError = false;
  bool _termError = false;

  @override
  void initState() {
    super.initState();
    if (widget.credit != null) {
      _amountController.text = widget.credit!.totalAmount.toString();
      _rateController.text = widget.credit!.interestRate.toString();
      _termController.text = widget.credit!.termMonths.toString();

      // Загружаем данные счета
      Future<void>.microtask(() async {
        final AccountEntity? account = await ref
            .read(accountRepositoryProvider)
            .findById(widget.credit!.accountId);
        if (account != null && mounted) {
          setState(() {
            _nameController.text = account.name;
            _color = account.color;
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
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.isEmpty;
      _amountError = double.tryParse(_amountController.text) == null;
      _rateError = double.tryParse(_rateController.text) == null;
      _termError = int.tryParse(_termController.text) == null;
    });
    return !(_nameError || _amountError || _rateError || _termError);
  }

  Future<void> _save() async {
    if (_validate()) {
      if (widget.credit == null) {
        await ref
            .read(addCreditUseCaseProvider)
            .call(
              name: _nameController.text,
              totalAmount: double.parse(_amountController.text),
              currency: 'RUB', // TODO: Брать из настроек
              interestRate: double.parse(_rateController.text),
              termMonths: int.parse(_termController.text),
              startDate: DateTime.now(),
              color: _color,
              iconName: _icon?.name,
              iconStyle: _icon?.style.name,
              isHidden: _isHidden,
            );
      } else {
        // В рамках текущей задачи реализуем только создание и удаление.
        // Обновление параметров кредита (суммы, ставки) — более сложная логика,
        // затрагивающая пересчет графиков платежей.
      }
      if (mounted) context.pop();
    }
  }

  Future<void> _saveAndConfigurePayment() async {
    if (_validate()) {
      if (widget.credit == null) {
        final credit = await ref
            .read(addCreditUseCaseProvider)
            .call(
              name: _nameController.text,
              totalAmount: double.parse(_amountController.text),
              currency: 'RUB', // TODO: Брать из настроек
              interestRate: double.parse(_rateController.text),
              termMonths: int.parse(_termController.text),
              startDate: DateTime.now(),
              color: _color,
              iconName: _icon?.name,
              iconStyle: _icon?.style.name,
              isHidden: _isHidden,
            );

        if (mounted) {
          final double amount =
              (double.tryParse(_amountController.text) ?? 0) /
              (int.tryParse(_termController.text) ?? 1);

          final EditUpcomingPaymentScreenArgs
          args = EditUpcomingPaymentScreenArgs(
            initialTitle: _nameController.text,
            initialAmount: amount,
            initialCategoryId: credit.categoryId,
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
      labels: const PhosphorIconPickerLabels(
        title: 'Выберите иконку', // TODO: Localize
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.credit == null
              ? context.loc.creditsAddTitle
              : 'Редактировать кредит',
        ), // TODO: Localize
        actions: [
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
        child: ListView(
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
            const SizedBox(height: 24),
            Text(
              'Оформление', // TODO: Localize
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
              title: const Text('Иконка'), // TODO: Localize
              subtitle: Text(_icon != null ? 'Выбрана' : 'Не выбрана'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectIcon,
            ),
            AccountColorSelector(
              color: _color,
              enabled: true,
              onColorChanged: (String? c) => setState(() => _color = c),
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
            if (widget.credit == null) ...[
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
        ),
      ),
    );
  }
}
