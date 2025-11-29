import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/accounts/presentation/controllers/add_account_form_controller.dart';
import 'package:kopim/features/accounts/presentation/widgets/account_color_selector.dart';
import 'package:kopim/l10n/app_localizations.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  static const String routeName = '/accounts/add';

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _customTypeController;

  @override
  void initState() {
    super.initState();
    final AddAccountFormState state = ref.read(
      addAccountFormControllerProvider,
    );
    _nameController = TextEditingController(text: state.name);
    _balanceController = TextEditingController(text: state.balanceInput);
    _customTypeController = TextEditingController(text: state.customType);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AddAccountFormState state = ref.watch(
      addAccountFormControllerProvider,
    );
    final AddAccountFormController controller = ref.read(
      addAccountFormControllerProvider.notifier,
    );

    ref.listen<AddAccountFormState>(addAccountFormControllerProvider, (
      AddAccountFormState? previous,
      AddAccountFormState next,
    ) {
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
          selection: TextSelection.collapsed(offset: next.balanceInput.length),
        );
      }
      if (previous?.customType != next.customType &&
          _customTypeController.text != next.customType) {
        _customTypeController.value = _customTypeController.value.copyWith(
          text: next.customType,
          selection: TextSelection.collapsed(offset: next.customType.length),
        );
      }
      final bool submitted =
          previous?.submissionSuccess != true && next.submissionSuccess;
      if (submitted && mounted) {
        Navigator.of(context).pop(true);
        controller.clearSubmissionFlag();
      }
    });

    final Map<String, String> accountTypeLabels = <String, String>{
      'cash': strings.addAccountTypeCash,
      'card': strings.addAccountTypeCard,
      'bank': strings.addAccountTypeBank,
    };
    const List<String> currencyOptions = <String>['USD', 'EUR', 'RUB'];
    const String customTypeValue = '__custom__';

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool showTypeError =
        state.typeError == AddAccountFieldError.emptyType;
    final String? dropdownErrorText = showTypeError && !state.useCustomType
        ? strings.addAccountTypeRequired
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(strings.addAccountTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (state.isSaving) const LinearProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                strings.addAccountNameLabel,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 16),
              KopimTextField(
                controller: _nameController,
                placeholder: strings.addAccountNameLabel,
                enabled: !state.isSaving,
                textInputAction: TextInputAction.next,
                onChanged: controller.updateName,
              ),
              const SizedBox(height: 16),
              if (state.nameError == AddAccountFieldError.emptyName) ...<Widget>[
                Text(
                  strings.addAccountNameRequired,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                strings.addAccountBalanceLabel,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 16),
              KopimTextField(
                controller: _balanceController,
                placeholder: strings.addAccountBalanceLabel,
                enabled: !state.isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: controller.updateBalance,
              ),
              const SizedBox(height: 16),
              if (state.balanceError == AddAccountFieldError.invalidBalance)
                Text(
                  strings.addAccountBalanceInvalid,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              if (state.balanceError ==
                  AddAccountFieldError.invalidBalance) ...<Widget>[
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                initialValue: state.currency,
                decoration: InputDecoration(
                  labelText: strings.addAccountCurrencyLabel,
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey<String>(
                  'type-${state.useCustomType ? customTypeValue : state.type}',
                ),
                initialValue: state.useCustomType
                    ? customTypeValue
                    : state.type,
                decoration: InputDecoration(
                  labelText: strings.addAccountTypeLabel,
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
                    child: Text(strings.addAccountTypeCustom),
                  ),
                ],
                onChanged: state.isSaving
                    ? null
                    : (String? value) {
                        if (value != null) {
                          if (value == customTypeValue) {
                            controller.enableCustomType();
                          } else {
                            controller.updateType(value);
                          }
                        }
                      },
              ),
              const SizedBox(height: 16),
              AccountColorSelector(
                color: state.color,
                enabled: !state.isSaving,
                onColorChanged: controller.updateColor,
              ),
              if (state.useCustomType) ...<Widget>[
                const SizedBox(height: 16),
                Text(
                  strings.addAccountCustomTypeLabel,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 16),
                KopimTextField(
                  controller: _customTypeController,
                  placeholder: strings.addAccountCustomTypeLabel,
                  enabled: !state.isSaving,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onChanged: controller.updateCustomType,
                ),
                const SizedBox(height: 16),
                if (showTypeError)
                  Text(
                    strings.addAccountTypeRequired,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
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
                const SizedBox(height: 24),
                Text(
                  strings.addAccountError,
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
                    : Text(strings.addAccountSaveCta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
