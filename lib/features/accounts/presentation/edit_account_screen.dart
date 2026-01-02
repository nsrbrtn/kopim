import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/delete_account_use_case.dart';
import 'package:kopim/features/accounts/presentation/controllers/edit_account_form_controller.dart';
import 'package:kopim/features/accounts/presentation/widgets/account_color_selector.dart';
import 'package:kopim/features/accounts/presentation/widgets/account_icon_selector.dart';
import 'package:kopim/l10n/app_localizations.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  const EditAccountScreen({super.key, required this.account});

  static const String routeName = '/accounts/edit';

  final AccountEntity account;

  static Route<void> route(AccountEntity account) {
    return MaterialPageRoute<void>(
      builder: (_) => EditAccountScreen(account: account),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  ConsumerState<EditAccountScreen> createState() => _EditAccountScreenState();
}

class EditAccountScreenArgs {
  const EditAccountScreenArgs({required this.account});

  final AccountEntity account;

  static EditAccountScreenArgs fromState(GoRouterState state) {
    final Object? extra = state.extra;
    if (extra is EditAccountScreenArgs) {
      return extra;
    }
    if (extra is AccountEntity) {
      return EditAccountScreenArgs(account: extra);
    }
    throw GoException('EditAccountScreenArgs were not provided');
  }

  String get location => EditAccountScreen.routeName;
}

enum AccountEditResult { updated, deleted }

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _customTypeController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _statementDayController;
  late final TextEditingController _paymentDueDaysController;
  late final TextEditingController _interestRateController;
  bool _isDeleting = false;

  void _showHelpDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  PhosphorIconDescriptor? _resolveAccountIcon(String? name, String? style) {
    if (name == null || name.isEmpty) {
      return null;
    }
    return PhosphorIconDescriptor(
      name: name,
      style: PhosphorIconStyleX.fromName(style),
    );
  }

  @override
  void initState() {
    super.initState();
    final EditAccountFormState initialState = ref.read(
      editAccountFormControllerProvider(widget.account),
    );
    _nameController = TextEditingController(text: initialState.name);
    _balanceController = TextEditingController(text: initialState.balanceInput);
    _customTypeController = TextEditingController(
      text: initialState.customType,
    );
    _creditLimitController = TextEditingController(
      text: initialState.creditLimitInput,
    );
    _statementDayController = TextEditingController(
      text: initialState.statementDayInput,
    );
    _paymentDueDaysController = TextEditingController(
      text: initialState.paymentDueDaysInput,
    );
    _interestRateController = TextEditingController(
      text: initialState.interestRateInput,
    );
    if (widget.account.type == 'credit_card') {
      Future<void>.microtask(
        () =>
            ref
                .read(editAccountFormControllerProvider(widget.account).notifier)
                .loadCreditCard(),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _customTypeController.dispose();
    _creditLimitController.dispose();
    _statementDayController.dispose();
    _paymentDueDaysController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final EditAccountFormState state = ref.watch(
      editAccountFormControllerProvider(widget.account),
    );
    final EditAccountFormController controller = ref.read(
      editAccountFormControllerProvider(widget.account).notifier,
    );
    final PhosphorIconDescriptor? selectedIcon = _resolveAccountIcon(
      state.iconName,
      state.iconStyle,
    );

    ref.listen<EditAccountFormState>(
      editAccountFormControllerProvider(widget.account),
      (EditAccountFormState? previous, EditAccountFormState next) {
        if (previous?.name != next.name && _nameController.text != next.name) {
          _nameController.value = _nameController.value.copyWith(
            text: next.name,
            selection: TextSelection.collapsed(offset: next.name.length),
          );
        }
        if (previous?.balanceInput != next.balanceInput &&
            _balanceController.text != next.balanceInput) {
          _balanceController.value = _balanceController.value.copyWith(
            text: next.balanceInput,
            selection: TextSelection.collapsed(
              offset: next.balanceInput.length,
            ),
          );
        }
        if (previous?.customType != next.customType &&
            _customTypeController.text != next.customType) {
          _customTypeController.value = _customTypeController.value.copyWith(
            text: next.customType,
            selection: TextSelection.collapsed(offset: next.customType.length),
          );
        }
        if (previous?.creditLimitInput != next.creditLimitInput &&
            _creditLimitController.text != next.creditLimitInput) {
          _creditLimitController.value = _creditLimitController.value.copyWith(
            text: next.creditLimitInput,
            selection: TextSelection.collapsed(
              offset: next.creditLimitInput.length,
            ),
          );
        }
        if (previous?.statementDayInput != next.statementDayInput &&
            _statementDayController.text != next.statementDayInput) {
          _statementDayController.value = _statementDayController.value.copyWith(
            text: next.statementDayInput,
            selection: TextSelection.collapsed(
              offset: next.statementDayInput.length,
            ),
          );
        }
        if (previous?.paymentDueDaysInput != next.paymentDueDaysInput &&
            _paymentDueDaysController.text != next.paymentDueDaysInput) {
          _paymentDueDaysController.value =
              _paymentDueDaysController.value.copyWith(
                text: next.paymentDueDaysInput,
                selection: TextSelection.collapsed(
                  offset: next.paymentDueDaysInput.length,
                ),
              );
        }
        if (previous?.interestRateInput != next.interestRateInput &&
            _interestRateController.text != next.interestRateInput) {
          _interestRateController.value =
              _interestRateController.value.copyWith(
                text: next.interestRateInput,
                selection: TextSelection.collapsed(
                  offset: next.interestRateInput.length,
                ),
              );
        }
        final bool submitted =
            previous?.submissionSuccess != true && next.submissionSuccess;
        if (submitted && mounted) {
          Navigator.of(context).pop(AccountEditResult.updated);
          controller.clearSubmissionFlag();
        }
      },
    );

    const List<String> currencyOptions = <String>['USD', 'EUR', 'RUB'];
    final Map<String, String> accountTypeLabels = <String, String>{
      'cash': strings.addAccountTypeCash,
      'card': strings.addAccountTypeCard,
      'bank': strings.addAccountTypeBank,
      'credit_card': strings.addAccountTypeCreditCard,
    };
    const String customTypeValue = '__custom__';

    final ThemeData theme = Theme.of(context);
    final bool showTypeError =
        state.typeError == EditAccountFieldError.emptyType;
    final String? dropdownErrorText = showTypeError && !state.useCustomType
        ? strings.editAccountTypeRequired
        : null;
    final bool isCreditCard = state.resolvedType == 'credit_card';

    return Scaffold(
      appBar: AppBar(title: Text(strings.editAccountTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (state.isSaving) const LinearProgressIndicator(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: strings.editAccountNameLabel,
                  errorText: state.nameError == EditAccountFieldError.emptyName
                      ? strings.editAccountNameRequired
                      : null,
                ),
                enabled: !state.isSaving,
                textInputAction: TextInputAction.next,
                onChanged: controller.updateName,
              ),
              const SizedBox(height: 16),
              if (!isCreditCard) ...<Widget>[
                TextFormField(
                  controller: _balanceController,
                  decoration: InputDecoration(
                    labelText: strings.editAccountBalanceLabel,
                    errorText: state.balanceError ==
                            EditAccountFieldError.invalidBalance
                        ? strings.editAccountBalanceInvalid
                        : null,
                  ),
                  enabled: !state.isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: controller.updateBalance,
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                initialValue: state.currency,
                decoration: InputDecoration(
                  labelText: strings.editAccountCurrencyLabel,
                ),
                items: currencyOptions
                    .map(
                      (String code) => DropdownMenuItem<String>(
                        value: code,
                        child: Text(code),
                      ),
                    )
                    .toList(),
                onChanged: state.isSaving
                    ? null
                    : (String? value) {
                        if (value != null) {
                          controller.updateCurrency(value);
                        }
                      },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                key: ValueKey<String>(
                  'edit-type-${state.useCustomType ? customTypeValue : state.type}',
                ),
                initialValue: state.useCustomType
                    ? customTypeValue
                    : state.type,
                decoration: InputDecoration(
                  labelText: strings.editAccountTypeLabel,
                  errorText: dropdownErrorText,
                ),
                items: <DropdownMenuItem<String>>[
                  ...accountTypeLabels.entries.map(
                    (MapEntry<String, String> entry) =>
                        DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                  ),
                  DropdownMenuItem<String>(
                    value: customTypeValue,
                    child: Text(strings.editAccountTypeCustom),
                  ),
                ],
                onChanged: state.isSaving
                    ? null
                    : (String? value) {
                        if (value == null) {
                          return;
                        }
                        if (value == customTypeValue) {
                          controller.enableCustomType();
                        } else {
                          controller.updateType(value);
                        }
                      },
              ),
              if (isCreditCard) ...<Widget>[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _creditLimitController,
                  decoration: InputDecoration(
                    labelText: strings.addAccountCreditCardLimitLabel,
                    errorText: state.creditLimitError != null
                        ? strings.addAccountCreditCardLimitError
                        : null,
                  ),
                  enabled: !state.isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: controller.updateCreditLimit,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _statementDayController,
                  decoration: InputDecoration(
                    labelText: strings.addAccountCreditCardStatementDayLabel,
                    errorText: state.statementDayError != null
                        ? strings.addAccountCreditCardStatementDayError
                        : null,
                    suffixIcon: IconButton(
                      onPressed: () => _showHelpDialog(
                        strings.addAccountCreditCardStatementDayLabel,
                        strings.addAccountCreditCardStatementDayHelp,
                      ),
                      icon: const Icon(Icons.help_outline, size: 18),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  enabled: !state.isSaving,
                  keyboardType: TextInputType.number,
                  onChanged: controller.updateStatementDay,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paymentDueDaysController,
                  decoration: InputDecoration(
                    labelText:
                        strings.addAccountCreditCardPaymentDueDaysLabel,
                    errorText: state.paymentDueDaysError != null
                        ? strings.addAccountCreditCardPaymentDueDaysError
                        : null,
                    suffixIcon: IconButton(
                      onPressed: () => _showHelpDialog(
                        strings.addAccountCreditCardPaymentDueDaysLabel,
                        strings.addAccountCreditCardPaymentDueDaysHelp,
                      ),
                      icon: const Icon(Icons.help_outline, size: 18),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  enabled: !state.isSaving,
                  keyboardType: TextInputType.number,
                  onChanged: controller.updatePaymentDueDays,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _interestRateController,
                  decoration: InputDecoration(
                    labelText: strings.addAccountCreditCardInterestRateLabel,
                    errorText: state.interestRateError != null
                        ? strings.addAccountCreditCardInterestRateError
                        : null,
                  ),
                  enabled: !state.isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: controller.updateInterestRate,
                ),
              ],
              const SizedBox(height: 16),
              AccountIconSelector(
                icon: selectedIcon,
                enabled: !state.isSaving,
                onIconChanged: controller.updateIcon,
              ),
              const SizedBox(height: 16),
              AccountColorSelector(
                color: state.color,
                gradientId: state.gradientId,
                enabled: !state.isSaving,
                onStyleChanged: (AccountCardStyleSelection selection) {
                  controller
                    ..updateColor(selection.color)
                    ..updateGradient(selection.gradientId);
                },
              ),
              if (state.useCustomType) ...<Widget>[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customTypeController,
                  decoration: InputDecoration(
                    labelText: strings.editAccountCustomTypeLabel,
                    errorText: showTypeError
                        ? strings.editAccountTypeRequired
                        : null,
                  ),
                  enabled: !state.isSaving,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: controller.updateCustomType,
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: state.isPrimary,
                onChanged: state.isSaving ? null : controller.updateIsPrimary,
                title: Text(strings.accountPrimaryToggleLabel),
                subtitle: Text(strings.accountPrimaryToggleSubtitle),
              ),
              if (state.errorMessage != null) ...<Widget>[
                const SizedBox(height: 16),
                Text(
                  strings.editAccountGenericError,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.isSaving
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        controller.submit();
                      },
                child: state.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(strings.editAccountSaveCta),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: state.isSaving || _isDeleting
                    ? null
                    : () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
                label: _isDeleting
                    ? Text(strings.editAccountDeleteLoading)
                    : Text(strings.editAccountDeleteCta),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.editAccountDeleteConfirmationTitle),
          content: Text(strings.editAccountDeleteConfirmationMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.editAccountDeleteConfirmationCancel),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(strings.editAccountDeleteConfirmationConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    final DeleteAccountUseCase deleteAccount = ref.read(
      deleteAccountUseCaseProvider,
    );
    try {
      await deleteAccount(widget.account.id);
      if (!mounted) {
        return;
      }
      navigator.pop(AccountEditResult.deleted);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isDeleting = false;
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(strings.editAccountDeleteError)));
    }
  }
}
