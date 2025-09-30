import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/accounts/presentation/controllers/add_account_form_controller.dart';
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

  @override
  void initState() {
    super.initState();
    final AddAccountFormState state = ref.read(
      addAccountFormControllerProvider,
    );
    _nameController = TextEditingController(text: state.name);
    _balanceController = TextEditingController(text: state.balanceInput);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
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

    final ThemeData theme = Theme.of(context);

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
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: strings.addAccountNameLabel,
                  errorText: state.nameError == AddAccountFieldError.emptyName
                      ? strings.addAccountNameRequired
                      : null,
                ),
                enabled: !state.isSaving,
                textInputAction: TextInputAction.next,
                onChanged: controller.updateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(
                  labelText: strings.addAccountBalanceLabel,
                  errorText:
                      state.balanceError == AddAccountFieldError.invalidBalance
                      ? strings.addAccountBalanceInvalid
                      : null,
                ),
                enabled: !state.isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: controller.updateBalance,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: state.currency,
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
                value: state.type,
                decoration: InputDecoration(
                  labelText: strings.addAccountTypeLabel,
                ),
                items: accountTypeLabels.entries
                    .map(
                      (MapEntry<String, String> entry) =>
                          DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                    )
                    .toList(),
                onChanged: state.isSaving
                    ? null
                    : (String? value) {
                        if (value != null) {
                          controller.updateType(value);
                        }
                      },
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
