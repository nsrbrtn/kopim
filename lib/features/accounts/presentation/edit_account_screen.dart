import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/widgets/kopim_dropdown_field.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/delete_account_use_case.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
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
  late final TextEditingController _creditLimitController;
  late final TextEditingController _statementDayController;
  late final TextEditingController _paymentDueDaysController;
  late final TextEditingController _interestRateController;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final EditAccountFormState initialState = ref.read(
      editAccountFormControllerProvider(widget.account),
    );
    _nameController = TextEditingController(text: initialState.name);
    _balanceController = TextEditingController(text: initialState.balanceInput);
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
    if (isCreditCardAccountType(widget.account.type)) {
      Future<void>.microtask(
        () => ref
            .read(editAccountFormControllerProvider(widget.account).notifier)
            .loadCreditCard(),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    _statementDayController.dispose();
    _paymentDueDaysController.dispose();
    _interestRateController.dispose();
    super.dispose();
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
          _statementDayController.value = _statementDayController.value
              .copyWith(
                text: next.statementDayInput,
                selection: TextSelection.collapsed(
                  offset: next.statementDayInput.length,
                ),
              );
        }
        if (previous?.paymentDueDaysInput != next.paymentDueDaysInput &&
            _paymentDueDaysController.text != next.paymentDueDaysInput) {
          _paymentDueDaysController.value = _paymentDueDaysController.value
              .copyWith(
                text: next.paymentDueDaysInput,
                selection: TextSelection.collapsed(
                  offset: next.paymentDueDaysInput.length,
                ),
              );
        }
        if (previous?.interestRateInput != next.interestRateInput &&
            _interestRateController.text != next.interestRateInput) {
          _interestRateController.value = _interestRateController.value
              .copyWith(
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
      'bank': strings.addAccountTypeBank,
      'credit_card': strings.addAccountTypeCreditCard,
      'investment': strings.addAccountTypeInvestment,
    };

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final KopimLayout layout = theme.kopimLayout;
    final bool isCreditCard = state.resolvedType == 'credit_card';
    final String? typeError = state.typeError == EditAccountFieldError.emptyType
        ? strings.editAccountTypeRequired
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(strings.editAccountTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (state.isSaving) const LinearProgressIndicator(),
              SizedBox(height: layout.spacing.section),
              _EditTextField(
                controller: _nameController,
                label: strings.editAccountNameLabel,
                placeholder: strings.editAccountNameLabel,
                isSaving: state.isSaving,
                colorScheme: colorScheme,
                layout: layout,
                textInputAction: TextInputAction.next,
                errorText: state.nameError == EditAccountFieldError.emptyName
                    ? strings.editAccountNameRequired
                    : null,
                onChanged: controller.updateName,
              ),
              SizedBox(height: layout.spacing.section),
              if (!isCreditCard) ...<Widget>[
                _EditTextField(
                  controller: _balanceController,
                  label: strings.editAccountBalanceLabel,
                  placeholder: strings.editAccountBalanceLabel,
                  isSaving: state.isSaving,
                  colorScheme: colorScheme,
                  layout: layout,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText:
                      state.balanceError == EditAccountFieldError.invalidBalance
                      ? strings.editAccountBalanceInvalid
                      : null,
                  onChanged: controller.updateBalance,
                ),
                SizedBox(height: layout.spacing.section),
              ],
              _EditDropdownField<String>(
                label: strings.editAccountCurrencyLabel,
                value: state.currency,
                isSaving: state.isSaving,
                colorScheme: colorScheme,
                items: currencyOptions
                    .map(
                      (String code) => DropdownMenuItem<String>(
                        value: code,
                        child: Text(code),
                      ),
                    )
                    .toList(),
                valueLabelBuilder: (String? value) => value ?? '',
                onChanged: (String? value) {
                  if (value != null) {
                    controller.updateCurrency(value);
                  }
                },
              ),
              SizedBox(height: layout.spacing.sectionLarge),
              _EditDropdownField<String>(
                key: ValueKey<String>('edit-type-${state.type}'),
                label: strings.editAccountTypeLabel,
                value: state.type.isEmpty ? null : state.type,
                isSaving: state.isSaving,
                colorScheme: colorScheme,
                items: <DropdownMenuItem<String>>[
                  ...accountTypeLabels.entries.map(
                    (MapEntry<String, String> entry) =>
                        DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                  ),
                ],
                errorText: typeError,
                valueLabelBuilder: (String? value) {
                  if (value == null) {
                    return '';
                  }
                  return accountTypeLabels[value] ?? value;
                },
                onChanged: (String? value) {
                  if (value != null) {
                    controller.updateType(value);
                  }
                },
              ),
              if (isCreditCard) ...<Widget>[
                SizedBox(height: layout.spacing.section),
                _EditTextField(
                  controller: _creditLimitController,
                  label: strings.addAccountCreditCardLimitLabel,
                  placeholder: strings.addAccountCreditCardLimitPlaceholder,
                  isSaving: state.isSaving,
                  colorScheme: colorScheme,
                  layout: layout,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: state.creditLimitError != null
                      ? strings.addAccountCreditCardLimitError
                      : null,
                  onChanged: controller.updateCreditLimit,
                ),
                SizedBox(height: layout.spacing.section),
                _EditTextField(
                  controller: _statementDayController,
                  label: strings.addAccountCreditCardStatementDayLabel,
                  placeholder:
                      strings.addAccountCreditCardStatementDayPlaceholder,
                  isSaving: state.isSaving,
                  colorScheme: colorScheme,
                  layout: layout,
                  keyboardType: TextInputType.number,
                  errorText: state.statementDayError != null
                      ? strings.addAccountCreditCardStatementDayError
                      : null,
                  suffixIcon: IconButton(
                    onPressed: () => _showHelpDialog(
                      strings.addAccountCreditCardStatementDayLabel,
                      strings.addAccountCreditCardStatementDayHelp,
                    ),
                    icon: const Icon(Icons.question_mark, size: 18),
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onChanged: controller.updateStatementDay,
                ),
                SizedBox(height: layout.spacing.section),
                _EditTextField(
                  controller: _paymentDueDaysController,
                  label: strings.addAccountCreditCardPaymentDueDaysLabel,
                  placeholder:
                      strings.addAccountCreditCardPaymentDueDaysPlaceholder,
                  isSaving: state.isSaving,
                  colorScheme: colorScheme,
                  layout: layout,
                  keyboardType: TextInputType.number,
                  errorText: state.paymentDueDaysError != null
                      ? strings.addAccountCreditCardPaymentDueDaysError
                      : null,
                  suffixIcon: IconButton(
                    onPressed: () => _showHelpDialog(
                      strings.addAccountCreditCardPaymentDueDaysLabel,
                      strings.addAccountCreditCardPaymentDueDaysHelp,
                    ),
                    icon: const Icon(Icons.question_mark, size: 18),
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onChanged: controller.updatePaymentDueDays,
                ),
                SizedBox(height: layout.spacing.section),
                _EditTextField(
                  controller: _interestRateController,
                  label: strings.addAccountCreditCardInterestRateLabel,
                  placeholder:
                      strings.addAccountCreditCardInterestRatePlaceholder,
                  isSaving: state.isSaving,
                  colorScheme: colorScheme,
                  layout: layout,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: state.interestRateError != null
                      ? strings.addAccountCreditCardInterestRateError
                      : null,
                  onChanged: controller.updateInterestRate,
                ),
              ],
              SizedBox(height: layout.spacing.section),
              AccountIconSelector(
                icon: selectedIcon,
                enabled: !state.isSaving,
                onIconChanged: controller.updateIcon,
              ),
              SizedBox(height: layout.spacing.section),
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
                SizedBox(height: layout.spacing.section),
                Text(
                  state.customType,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              SizedBox(height: layout.spacing.section),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: state.isPrimary,
                onChanged: state.isSaving ? null : controller.updateIsPrimary,
                title: Text(strings.accountPrimaryToggleLabel),
                subtitle: Text(strings.accountPrimaryToggleSubtitle),
              ),
              if (state.errorMessage != null) ...<Widget>[
                SizedBox(height: layout.spacing.section),
                Text(
                  strings.editAccountGenericError,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                SizedBox(height: layout.spacing.between),
                Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
              SizedBox(height: layout.spacing.sectionLarge),
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
              SizedBox(height: layout.spacing.section),
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
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(strings.editAccountDeleteError),
          ),
        );
    }
  }
}

class _EditTextField extends StatelessWidget {
  const _EditTextField({
    required this.controller,
    required this.label,
    required this.placeholder,
    required this.isSaving,
    required this.colorScheme,
    required this.layout,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String placeholder;
  final bool isSaving;
  final ColorScheme colorScheme;
  final KopimLayout layout;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: layout.spacing.between),
        KopimTextField(
          controller: controller,
          placeholder: placeholder,
          enabled: !isSaving,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          suffixIcon: suffixIcon,
          fillColor: colorScheme.surfaceContainerHigh,
          placeholderColor: colorScheme.onSurfaceVariant,
          hasError: errorText != null,
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: layout.spacing.between),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _EditDropdownField<T> extends StatelessWidget {
  const _EditDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.isSaving,
    required this.colorScheme,
    required this.onChanged,
    this.errorText,
    this.valueLabelBuilder,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final bool isSaving;
  final ColorScheme colorScheme;
  final ValueChanged<T?> onChanged;
  final String? errorText;
  final String Function(T?)? valueLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = theme.kopimLayout;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        KopimDropdownField<T>(
          key: key,
          label: label,
          value: value,
          items: items,
          enabled: !isSaving,
          onChanged: isSaving ? null : (T value) => onChanged(value),
          valueLabelBuilder: valueLabelBuilder,
          fillColor: colorScheme.surfaceContainerHigh,
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: layout.spacing.between),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
