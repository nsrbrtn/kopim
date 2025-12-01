import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/animated_fab.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';
import 'package:kopim/core/widgets/kopim_floating_action_button.dart';
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
  static const String _namePlaceholder = 'Основной';
  static const String _balancePlaceholder = 'Введите сумму';
  static const String _currencyPlaceholder = 'Название валюты';
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _customTypeController;
  late final TextEditingController _currencySearchController;
  String _currencyQuery = '';

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _customTypeController.dispose();
    _currencySearchController.dispose();
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
    final KopimLayout layout = theme.kopimLayout;
    final bool showTypeError =
        state.typeError == AddAccountFieldError.emptyType;
    final String? dropdownErrorText = showTypeError && !state.useCustomType
        ? strings.addAccountTypeRequired
        : null;
    final String? selectedTypeValue = state.useCustomType
        ? customTypeValue
        : (state.type.isEmpty ? null : state.type);
    final List<String> filteredCurrencies = currencyOptions
        .where(
          (String code) => code
              .toLowerCase()
              .contains(_currencyQuery.toLowerCase()),
        )
        .toList();
    final Color? selectedColor = parseHexColor(state.color);
    final BorderRadius containerRadius =
        BorderRadius.circular(layout.radius.xxl);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                    SizedBox(height: layout.spacing.sectionLarge),
                    _BalanceField(
                      controller: _balanceController,
                      isSaving: state.isSaving,
                      strings: strings,
                      layout: layout,
                      colorScheme: colorScheme,
                      theme: theme,
                      onChanged: controller.updateBalance,
                      placeholder: _balancePlaceholder,
                      hasError: state.balanceError ==
                          AddAccountFieldError.invalidBalance,
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
                    SizedBox(height: layout.spacing.sectionLarge),
                    _ColorPickerRow(
                      colorScheme: colorScheme,
                      controller: controller,
                      layout: layout,
                      selectedColor: selectedColor,
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
                      activeColor: colorScheme.onPrimary,
                      activeTrackColor: colorScheme.primary,
                    ),
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
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
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
      data: theme.copyWith(
        colorScheme: innerExpandableColors,
      ),
      child: KopimExpandableSectionPlayful(
        title: strings.addAccountTypeLabel,
        initiallyExpanded: false,
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
                groupValue: selectedTypeValue,
                onChanged: isSaving
                    ? null
                    : (String? value) {
                        if (value != null) {
                          onTypeSelected(value);
                        }
                      },
                title: Text(entry.value),
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
                padding: EdgeInsets.only(
                  top: layout.spacing.between,
                ),
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
      data: theme.copyWith(
        colorScheme: innerExpandableColors,
      ),
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
                        borderRadius: BorderRadius.circular(
                          layout.radius.card,
                        ),
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
    required this.strings,
    required this.theme,
    required this.isSaving,
  });

  final ColorScheme colorScheme;
  final AddAccountFormController controller;
  final KopimLayout layout;
  final Color? selectedColor;
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
                  final Color? picked = await showAccountColorPickerDialog(
                    context: context,
                    strings: strings,
                    initialColor: selectedColor,
                  );
                  if (picked != null) {
                    controller.updateColor(
                      colorToHex(
                        picked,
                        includeAlpha: false,
                      ),
                    );
                  }
                },
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selectedColor ?? colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
            ),
            child: selectedColor == null
                ? Icon(
                    Icons.palette_outlined,
                    color: colorScheme.onSurface,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _CurrencyAvatar extends StatelessWidget {
  const _CurrencyAvatar({
    required this.code,
    required this.selected,
  });

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
