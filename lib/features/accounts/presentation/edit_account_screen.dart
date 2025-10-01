import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/controllers/edit_account_form_controller.dart';
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
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    final EditAccountFormState initialState = ref.read(
      editAccountFormControllerProvider(widget.account),
    );
    _nameController = TextEditingController(text: initialState.name);
    _balanceController = TextEditingController(text: initialState.balanceInput);
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
    final EditAccountFormState state = ref.watch(
      editAccountFormControllerProvider(widget.account),
    );
    final EditAccountFormController controller = ref.read(
      editAccountFormControllerProvider(widget.account).notifier,
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
        final bool submitted =
            previous?.submissionSuccess != true && next.submissionSuccess;
        if (submitted && mounted) {
          Navigator.of(context).pop(true);
          controller.clearSubmissionFlag();
        }
      },
    );

    const List<String> currencyOptions = <String>['USD', 'EUR', 'RUB'];
    final Map<String, String> accountTypeLabels = <String, String>{
      'cash': strings.addAccountTypeCash,
      'card': strings.addAccountTypeCard,
      'bank': strings.addAccountTypeBank,
    };

    final ThemeData theme = Theme.of(context);

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
              TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(
                  labelText: strings.editAccountBalanceLabel,
                  errorText:
                      state.balanceError == EditAccountFieldError.invalidBalance
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.editAccountTypeLabel),
                subtitle: Text(
                  accountTypeLabels[widget.account.type] ?? widget.account.type,
                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
