import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/animated_fab.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';
import 'package:kopim/core/widgets/kopim_floating_action_button.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/accounts/presentation/controllers/add_account_form_controller.dart';
import 'package:kopim/features/accounts/presentation/widgets/account_color_selector.dart';
import 'package:kopim/features/accounts/presentation/widgets/account_icon_selector.dart';
import 'package:kopim/features/accounts/presentation/utils/account_card_gradients.dart';
import 'package:kopim/l10n/app_localizations.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  static const String routeName = '/accounts/add';

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  static const String _namePlaceholder = 'Основной';
  static const String _balancePlaceholder = 'Введите сумму';
  static const String _currencyPlaceholder = 'Название валюты';
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _customTypeController;
  late final TextEditingController _currencySearchController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _statementDayController;
  late final TextEditingController _paymentDueDaysController;
  late final TextEditingController _interestRateController;
  String _currencyQuery = '';

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
    final AddAccountFormState state = ref.read(
      addAccountFormControllerProvider,
    );
    _nameController = TextEditingController(text: state.name);
    _balanceController = TextEditingController(text: state.balanceInput);
    _customTypeController = TextEditingController(text: state.customType);
    _currencySearchController = TextEditingController();
    _creditLimitController = TextEditingController(
      text: state.creditLimitInput,
    );
    _statementDayController = TextEditingController(
      text: state.statementDayInput,
    );
    _paymentDueDaysController = TextEditingController(
      text: state.paymentDueDaysInput,
    );
    _interestRateController = TextEditingController(
      text: state.interestRateInput,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _customTypeController.dispose();
    _currencySearchController.dispose();
    _creditLimitController.dispose();
    _statementDayController.dispose();
    _paymentDueDaysController.dispose();
    _interestRateController.dispose();
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
        _interestRateController.value = _interestRateController.value.copyWith(
          text: next.interestRateInput,
          selection: TextSelection.collapsed(
            offset: next.interestRateInput.length,
          ),
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
      'credit_card': strings.addAccountTypeCreditCard,
    };
    const List<String> currencyOptions = <String>['USD', 'EUR', 'RUB'];
    const String customTypeValue = '__custom__';

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final KopimLayout layout = theme.kopimLayout;
    final bool showTypeError =
        state.typeError == AddAccountFieldError.emptyType;
    final String? dropdownErrorText = showTypeError && !state.useCustomType
        ? strings.addAccountTypeRequired
        : null;
    final String? selectedTypeValue = state.useCustomType
        ? customTypeValue
        : (state.type.isEmpty ? null : state.type);
    final bool isCreditCard = state.resolvedType == 'credit_card';
    final bool showNameField =
        state.resolvedType != null && state.currency.trim().isNotEmpty;
    final bool showDetails = showNameField && state.name.trim().isNotEmpty;
    final List<String> filteredCurrencies = currencyOptions
        .where(
          (String code) =>
              code.toLowerCase().contains(_currencyQuery.toLowerCase()),
        )
        .toList();
    final Color? selectedColor = parseHexColor(state.color);
    final AccountCardGradient? selectedGradient = resolveAccountCardGradient(
      state.gradientId,
    );
    final PhosphorIconDescriptor? selectedIcon = _resolveAccountIcon(
      state.iconName,
      state.iconStyle,
    );
    final BorderRadius containerRadius = BorderRadius.circular(
      layout.radius.xxl,
    );
    final ColorScheme innerExpandableColors = colorScheme.copyWith(
      surfaceContainer: colorScheme.surfaceContainerHigh,
    );

    void onTypeSelected(String value) {
      if (value == customTypeValue) {
        controller.enableCustomType();
      } else {
        controller.updateType(value);
      }
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      floatingActionButton: AnimatedFab(
        child: KopimFloatingActionButton(
          onPressed: state.isSaving
              ? null
              : () {
                  FocusScope.of(context).unfocus();
                  controller.submit();
                },
          icon: state.isSaving
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.save_outlined),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: containerRadius,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: state.isSaving
                          ? const LinearProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                    if (state.isSaving) const SizedBox(height: 16),
                    Text(
                      strings.addAccountTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: layout.spacing.sectionLarge),
                    _TypeSection(
                      accountTypeLabels: accountTypeLabels,
                      colorScheme: colorScheme,
                      controller: controller,
                      customTypeController: _customTypeController,
                      customTypeValue: customTypeValue,
                      dropdownErrorText: dropdownErrorText,
                      innerExpandableColors: innerExpandableColors,
                      isSaving: state.isSaving,
                      layout: layout,
                      selectedTypeValue: selectedTypeValue,
                      showTypeError: showTypeError,
                      state: state,
                      strings: strings,
                      theme: theme,
                      onTypeSelected: onTypeSelected,
                    ),
                    SizedBox(height: layout.spacing.sectionLarge),
                    _CurrencySection(
                      colorScheme: colorScheme,
                      controller: controller,
                      filteredCurrencies: filteredCurrencies,
                      innerExpandableColors: innerExpandableColors,
                      isSaving: state.isSaving,
                      layout: layout,
                      onQueryChanged: (String value) {
                        setState(() {
                          _currencyQuery = value;
                        });
                      },
                      placeholder: _currencyPlaceholder,
                      selectedCurrency: state.currency,
                      strings: strings,
                      theme: theme,
                      currencySearchController: _currencySearchController,
                    ),
                    if (showNameField) ...<Widget>[
                      SizedBox(height: layout.spacing.sectionLarge),
                      _NameField(
                        controller: _nameController,
                        isSaving: state.isSaving,
                        strings: strings,
                        layout: layout,
                        colorScheme: colorScheme,
                        theme: theme,
                        onChanged: controller.updateName,
                        placeholder: _namePlaceholder,
                        hasError:
                            state.nameError == AddAccountFieldError.emptyName,
                      ),
                    ],
                    if (showDetails) ...<Widget>[
                      SizedBox(height: layout.spacing.sectionLarge),
                      if (!isCreditCard)
                        _BalanceField(
                          controller: _balanceController,
                          isSaving: state.isSaving,
                          strings: strings,
                          layout: layout,
                          colorScheme: colorScheme,
                          theme: theme,
                          onChanged: controller.updateBalance,
                          placeholder: _balancePlaceholder,
                          hasError:
                              state.balanceError ==
                              AddAccountFieldError.invalidBalance,
                        ),
                      if (isCreditCard) ...<Widget>[
                        SizedBox(height: layout.spacing.sectionLarge),
                        _CreditCardSettingsSection(
                          isSaving: state.isSaving,
                          strings: strings,
                          layout: layout,
                          colorScheme: colorScheme,
                          theme: theme,
                          creditLimitController: _creditLimitController,
                          statementDayController: _statementDayController,
                          paymentDueDaysController: _paymentDueDaysController,
                          interestRateController: _interestRateController,
                          onCreditLimitChanged: controller.updateCreditLimit,
                          onStatementDayChanged: controller.updateStatementDay,
                          onPaymentDueDaysChanged:
                              controller.updatePaymentDueDays,
                          onInterestRateChanged: controller.updateInterestRate,
                          creditLimitError: state.creditLimitError != null,
                          statementDayError: state.statementDayError != null,
                          paymentDueDaysError:
                              state.paymentDueDaysError != null,
                          interestRateError: state.interestRateError != null,
                        ),
                      ],
                      SizedBox(height: layout.spacing.sectionLarge),
                      AccountIconSelector(
                        icon: selectedIcon,
                        enabled: !state.isSaving,
                        onIconChanged: controller.updateIcon,
                      ),
                      SizedBox(height: layout.spacing.sectionLarge),
                      _ColorPickerRow(
                        colorScheme: colorScheme,
                        controller: controller,
                        layout: layout,
                        selectedColor: selectedColor,
                        selectedGradient: selectedGradient,
                        strings: strings,
                        theme: theme,
                        isSaving: state.isSaving,
                      ),
                      SizedBox(height: layout.spacing.sectionLarge),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: state.isPrimary,
                        onChanged: state.isSaving
                            ? null
                            : controller.updateIsPrimary,
                        title: Text(
                          strings.accountPrimaryToggleLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          strings.accountPrimaryToggleSubtitle,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        thumbColor: WidgetStateProperty.resolveWith(
                          (Set<WidgetState> states) =>
                              states.contains(WidgetState.selected)
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                        trackColor: WidgetStateProperty.resolveWith(
                          (Set<WidgetState> states) =>
                              states.contains(WidgetState.selected)
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                    if (state.errorMessage != null) ...<Widget>[
                      SizedBox(height: layout.spacing.sectionLarge),
                      Text(
                        strings.addAccountError,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      SizedBox(height: layout.spacing.between),
                      Text(
                        state.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.isSaving,
    required this.strings,
    required this.layout,
    required this.colorScheme,
    required this.theme,
    required this.onChanged,
    required this.placeholder,
    required this.hasError,
  });

  final TextEditingController controller;
  final bool isSaving;
  final AppLocalizations strings;
  final KopimLayout layout;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final ValueChanged<String> onChanged;
  final String placeholder;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.addAccountNameLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: layout.spacing.between),
        KopimTextField(
          controller: controller,
          placeholder: placeholder,
          enabled: !isSaving,
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
          fillColor: colorScheme.surfaceContainerHigh,
          placeholderColor: colorScheme.onSurfaceVariant,
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: layout.spacing.between),
            child: Text(
              strings.addAccountNameRequired,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _BalanceField extends StatelessWidget {
  const _BalanceField({
    required this.controller,
    required this.isSaving,
    required this.strings,
    required this.layout,
    required this.colorScheme,
    required this.theme,
    required this.onChanged,
    required this.placeholder,
    required this.hasError,
  });

  final TextEditingController controller;
  final bool isSaving;
  final AppLocalizations strings;
  final KopimLayout layout;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final ValueChanged<String> onChanged;
  final String placeholder;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.addAccountBalanceLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: layout.spacing.between),
        KopimTextField(
          controller: controller,
          placeholder: placeholder,
          enabled: !isSaving,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          fillColor: colorScheme.surfaceContainerHigh,
          placeholderColor: colorScheme.onSurfaceVariant,
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: layout.spacing.between),
            child: Text(
              strings.addAccountBalanceInvalid,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _TypeSection extends StatelessWidget {
  const _TypeSection({
    required this.accountTypeLabels,
    required this.colorScheme,
    required this.controller,
    required this.customTypeController,
    required this.customTypeValue,
    required this.dropdownErrorText,
    required this.innerExpandableColors,
    required this.isSaving,
    required this.layout,
    required this.selectedTypeValue,
    required this.showTypeError,
    required this.state,
    required this.strings,
    required this.theme,
    required this.onTypeSelected,
  });

  final Map<String, String> accountTypeLabels;
  final ColorScheme colorScheme;
  final AddAccountFormController controller;
  final TextEditingController customTypeController;
  final String customTypeValue;
  final String? dropdownErrorText;
  final ColorScheme innerExpandableColors;
  final bool isSaving;
  final KopimLayout layout;
  final String? selectedTypeValue;
  final bool showTypeError;
  final AddAccountFormState state;
  final AppLocalizations strings;
  final ThemeData theme;
  final ValueChanged<String> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.copyWith(colorScheme: innerExpandableColors),
      child: KopimExpandableSectionPlayful(
        title: strings.addAccountTypeLabel,
        initiallyExpanded: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ...<MapEntry<String, String>>[
              ...accountTypeLabels.entries,
              MapEntry<String, String>(
                customTypeValue,
                strings.addAccountTypeCustom,
              ),
            ].map(
              (MapEntry<String, String> entry) => RadioListTile<String>(
                value: entry.key,
                // ignore: deprecated_member_use
                groupValue: selectedTypeValue,
                // ignore: deprecated_member_use
                onChanged: isSaving
                    ? null
                    : (String? value) {
                        if (value != null) {
                          onTypeSelected(value);
                        }
                      },
                title: Text(entry.value),
                // ignore: deprecated_member_use
                activeColor: colorScheme.primary,
                shape: const CircleBorder(),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (state.useCustomType) ...<Widget>[
              SizedBox(height: layout.spacing.between),
              KopimTextField(
                controller: customTypeController,
                placeholder: strings.addAccountCustomTypeLabel,
                enabled: !isSaving,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onChanged: controller.updateCustomType,
                fillColor: colorScheme.surfaceContainerHighest,
                placeholderColor: colorScheme.onSurfaceVariant,
              ),
            ],
            if (showTypeError)
              Padding(
                padding: EdgeInsets.only(top: layout.spacing.between),
                child: Text(
                  dropdownErrorText ?? strings.addAccountTypeRequired,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CreditCardSettingsSection extends StatelessWidget {
  const _CreditCardSettingsSection({
    required this.isSaving,
    required this.strings,
    required this.layout,
    required this.colorScheme,
    required this.theme,
    required this.creditLimitController,
    required this.statementDayController,
    required this.paymentDueDaysController,
    required this.interestRateController,
    required this.onCreditLimitChanged,
    required this.onStatementDayChanged,
    required this.onPaymentDueDaysChanged,
    required this.onInterestRateChanged,
    required this.creditLimitError,
    required this.statementDayError,
    required this.paymentDueDaysError,
    required this.interestRateError,
  });

  final bool isSaving;
  final AppLocalizations strings;
  final KopimLayout layout;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final TextEditingController creditLimitController;
  final TextEditingController statementDayController;
  final TextEditingController paymentDueDaysController;
  final TextEditingController interestRateController;
  final ValueChanged<String> onCreditLimitChanged;
  final ValueChanged<String> onStatementDayChanged;
  final ValueChanged<String> onPaymentDueDaysChanged;
  final ValueChanged<String> onInterestRateChanged;
  final bool creditLimitError;
  final bool statementDayError;
  final bool paymentDueDaysError;
  final bool interestRateError;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(layout.radius.xxl),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.addAccountCreditCardSettingsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: layout.spacing.section),
          _CreditCardField(
            label: strings.addAccountCreditCardLimitLabel,
            placeholder: strings.addAccountCreditCardLimitPlaceholder,
            controller: creditLimitController,
            isSaving: isSaving,
            errorText: creditLimitError
                ? strings.addAccountCreditCardLimitError
                : null,
            onChanged: onCreditLimitChanged,
            layout: layout,
            colorScheme: colorScheme,
          ),
          SizedBox(height: layout.spacing.section),
          _CreditCardField(
            label: strings.addAccountCreditCardStatementDayLabel,
            placeholder: strings.addAccountCreditCardStatementDayPlaceholder,
            controller: statementDayController,
            isSaving: isSaving,
            errorText: statementDayError
                ? strings.addAccountCreditCardStatementDayError
                : null,
            tooltipText: strings.addAccountCreditCardStatementDayHelp,
            onChanged: onStatementDayChanged,
            layout: layout,
            colorScheme: colorScheme,
          ),
          SizedBox(height: layout.spacing.section),
          _CreditCardField(
            label: strings.addAccountCreditCardPaymentDueDaysLabel,
            placeholder: strings.addAccountCreditCardPaymentDueDaysPlaceholder,
            controller: paymentDueDaysController,
            isSaving: isSaving,
            errorText: paymentDueDaysError
                ? strings.addAccountCreditCardPaymentDueDaysError
                : null,
            tooltipText: strings.addAccountCreditCardPaymentDueDaysHelp,
            onChanged: onPaymentDueDaysChanged,
            layout: layout,
            colorScheme: colorScheme,
          ),
          SizedBox(height: layout.spacing.section),
          _CreditCardField(
            label: strings.addAccountCreditCardInterestRateLabel,
            placeholder: strings.addAccountCreditCardInterestRatePlaceholder,
            controller: interestRateController,
            isSaving: isSaving,
            errorText: interestRateError
                ? strings.addAccountCreditCardInterestRateError
                : null,
            onChanged: onInterestRateChanged,
            layout: layout,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _CreditCardField extends StatelessWidget {
  const _CreditCardField({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.isSaving,
    required this.onChanged,
    required this.layout,
    required this.colorScheme,
    this.errorText,
    this.tooltipText,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool isSaving;
  final ValueChanged<String> onChanged;
  final KopimLayout layout;
  final ColorScheme colorScheme;
  final String? errorText;
  final String? tooltipText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
            ),
            if (tooltipText != null) ...<Widget>[
              const SizedBox(width: 6),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.help_outline,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => _showHelpDialog(context),
              ),
            ],
          ],
        ),
        SizedBox(height: layout.spacing.between),
        KopimTextField(
          controller: controller,
          placeholder: placeholder,
          enabled: !isSaving,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          fillColor: colorScheme.surfaceContainerHigh,
          placeholderColor: colorScheme.onSurfaceVariant,
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: layout.spacing.between),
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    final String? message = tooltipText;
    if (message == null || message.isEmpty) {
      return;
    }
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(label),
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
}

class _CurrencySection extends StatelessWidget {
  const _CurrencySection({
    required this.colorScheme,
    required this.controller,
    required this.filteredCurrencies,
    required this.innerExpandableColors,
    required this.isSaving,
    required this.layout,
    required this.onQueryChanged,
    required this.placeholder,
    required this.selectedCurrency,
    required this.strings,
    required this.theme,
    required this.currencySearchController,
  });

  final ColorScheme colorScheme;
  final AddAccountFormController controller;
  final List<String> filteredCurrencies;
  final ColorScheme innerExpandableColors;
  final bool isSaving;
  final KopimLayout layout;
  final ValueChanged<String> onQueryChanged;
  final String placeholder;
  final String selectedCurrency;
  final AppLocalizations strings;
  final ThemeData theme;
  final TextEditingController currencySearchController;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.copyWith(colorScheme: innerExpandableColors),
      child: KopimExpandableSectionPlayful(
        title: strings.addAccountCurrencyLabel,
        initiallyExpanded: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            KopimTextField(
              controller: currencySearchController,
              placeholder: placeholder,
              enabled: !isSaving,
              onChanged: onQueryChanged,
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              fillColor: colorScheme.surfaceContainerHighest,
              placeholderColor: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: layout.spacing.section),
            Wrap(
              spacing: layout.spacing.between,
              runSpacing: layout.spacing.between,
              children: filteredCurrencies
                  .map(
                    (String code) => RawChip(
                      label: Text(
                        code,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: selectedCurrency == code
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      avatar: _CurrencyAvatar(
                        code: code,
                        selected: selectedCurrency == code,
                      ),
                      selected: selectedCurrency == code,
                      onSelected: isSaving
                          ? null
                          : (_) => controller.updateCurrency(code),
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      showCheckmark: false,
                      padding: EdgeInsets.symmetric(
                        horizontal: layout.spacing.between / 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(layout.radius.card),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPickerRow extends StatelessWidget {
  const _ColorPickerRow({
    required this.colorScheme,
    required this.controller,
    required this.layout,
    required this.selectedColor,
    required this.selectedGradient,
    required this.strings,
    required this.theme,
    required this.isSaving,
  });

  final ColorScheme colorScheme;
  final AddAccountFormController controller;
  final KopimLayout layout;
  final Color? selectedColor;
  final AccountCardGradient? selectedGradient;
  final AppLocalizations strings;
  final ThemeData theme;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            strings.accountColorLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        InkWell(
          onTap: isSaving
              ? null
              : () async {
                  final AccountCardStyleSelection? picked =
                      await showAccountColorPickerDialog(
                        context: context,
                        strings: strings,
                        initialColor: selectedColor,
                        initialGradientId: selectedGradient?.id,
                      );
                  if (picked != null) {
                    controller
                      ..updateColor(picked.color)
                      ..updateGradient(picked.gradientId);
                  }
                },
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selectedGradient == null
                  ? selectedColor ?? colorScheme.surfaceContainerHighest
                  : null,
              gradient: selectedGradient?.toGradient(),
              border: Border.all(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            child: selectedColor == null && selectedGradient == null
                ? Icon(Icons.palette_outlined, color: colorScheme.onSurface)
                : null,
          ),
        ),
      ],
    );
  }
}

class _CurrencyAvatar extends StatelessWidget {
  const _CurrencyAvatar({required this.code, required this.selected});

  final String code;
  final bool selected;

  String get _symbol {
    switch (code.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'RUB':
        return '₽';
      default:
        return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: selected ? colors.primary : colors.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _symbol,
        style: theme.textTheme.labelLarge?.copyWith(
          color: selected ? colors.onPrimary : colors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
