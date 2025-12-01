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
    final ColorScheme expandableColors = colorScheme.copyWith(
      surfaceContainer: colorScheme.surfaceContainerHigh,
    );

    Future<void> openTypeSelector() async {
      final String currentValue = state.useCustomType
          ? customTypeValue
          : (state.type.isEmpty ? '' : state.type);
      final String? selected = await showDialog<String>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(strings.addAccountTypeLabel),
            content: StatefulBuilder(
              builder: (
                BuildContext context,
                void Function(void Function()) setStateDialog,
              ) {
                String tempSelection = currentValue;

                void handleTap(String value) {
                  Navigator.of(dialogContext).pop(value);
                }

                final List<MapEntry<String, String>> items =
                    <MapEntry<String, String>>[
                  ...accountTypeLabels.entries,
                  MapEntry<String, String>(
                    customTypeValue,
                    strings.addAccountTypeCustom,
                  ),
                ];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items
                      .map(
                        (MapEntry<String, String> entry) => CheckboxListTile(
                          value: tempSelection == entry.key,
                          onChanged: (bool? _) => handleTap(entry.key),
                          title: Text(entry.value),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(strings.dialogCancel),
              ),
            ],
          );
        },
      );

      if (selected == null) return;
      if (selected == customTypeValue) {
        controller.enableCustomType();
      } else {
        controller.updateType(selected);
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
                    Text(
                      strings.addAccountNameLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: layout.spacing.between),
                    KopimTextField(
                      controller: _nameController,
                      placeholder: strings.addAccountNameLabel,
                      enabled: !state.isSaving,
                      textInputAction: TextInputAction.next,
                      onChanged: controller.updateName,
                      fillColor: colorScheme.surfaceContainerHigh,
                      placeholderColor: colorScheme.onSurfaceVariant,
                    ),
                    if (state.nameError == AddAccountFieldError.emptyName)
                      Padding(
                        padding:
                            EdgeInsets.only(top: layout.spacing.between),
                        child: Text(
                          strings.addAccountNameRequired,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    SizedBox(height: layout.spacing.sectionLarge),
                    Text(
                      strings.addAccountBalanceLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: layout.spacing.between),
                    KopimTextField(
                      controller: _balanceController,
                      placeholder: strings.addAccountBalanceLabel,
                      enabled: !state.isSaving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: controller.updateBalance,
                      fillColor: colorScheme.surfaceContainerHigh,
                      placeholderColor: colorScheme.onSurfaceVariant,
                    ),
                    if (state.balanceError ==
                        AddAccountFieldError.invalidBalance)
                      Padding(
                        padding:
                            EdgeInsets.only(top: layout.spacing.between),
                        child: Text(
                          strings.addAccountBalanceInvalid,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    SizedBox(height: layout.spacing.sectionLarge),
                    Text(
                      strings.addAccountTypeLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: layout.spacing.section),
                    Theme(
                      data: theme.copyWith(colorScheme: expandableColors),
                      child: KopimExpandableSectionPlayful(
                        title: strings.addAccountTypeLabel,
                        initiallyExpanded: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: state.isSaving ? null : openTypeSelector,
                              borderRadius:
                                  BorderRadius.circular(layout.radius.card),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(
                                    layout.radius.card,
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.credit_card,
                                      color: colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        selectedTypeValue ==
                                                customTypeValue
                                            ? (state.customType.isNotEmpty
                                                ? state.customType
                                                : strings
                                                    .addAccountCustomTypeLabel)
                                            : (selectedTypeValue != null
                                                ? accountTypeLabels[
                                                    selectedTypeValue]
                                                : strings
                                                    .addAccountTypeLabel) ??
                                                strings
                                                    .addAccountTypeLabel,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: colorScheme.onSurface,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (state.useCustomType) ...<Widget>[
                              SizedBox(height: layout.spacing.between),
                              KopimTextField(
                                controller: _customTypeController,
                                placeholder:
                                    strings.addAccountCustomTypeLabel,
                                enabled: !state.isSaving,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.done,
                                onChanged: controller.updateCustomType,
                                fillColor:
                                    colorScheme.surfaceContainerHigh,
                                placeholderColor:
                                    colorScheme.onSurfaceVariant,
                              ),
                            ],
                            if (showTypeError)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: layout.spacing.between,
                                ),
                                child: Text(
                                  dropdownErrorText ??
                                      strings.addAccountTypeRequired,
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              ),
                            SizedBox(height: layout.spacing.sectionLarge),
                            Text(
                              strings.addAccountCurrencyLabel,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: layout.spacing.between),
                            KopimTextField(
                              controller: _currencySearchController,
                              placeholder: strings.addAccountCurrencyLabel,
                              enabled: !state.isSaving,
                              onChanged: (String value) {
                                setState(() {
                                  _currencyQuery = value;
                                });
                              },
                              prefixIcon: Icon(
                                Icons.search,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              fillColor: colorScheme.surfaceContainerHigh,
                              placeholderColor:
                                  colorScheme.onSurfaceVariant,
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
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                          color: state.currency == code
                                              ? colorScheme.onPrimary
                                              : colorScheme
                                                  .onSurfaceVariant,
                                        ),
                                      ),
                                      avatar: _CurrencyAvatar(
                                        code: code,
                                        selected: state.currency == code,
                                      ),
                                      selected: state.currency == code,
                                      onSelected: state.isSaving
                                          ? null
                                          : (_) => controller
                                              .updateCurrency(code),
                                      selectedColor: colorScheme.primary,
                                      backgroundColor: colorScheme
                                          .surfaceContainerHigh,
                                      showCheckmark: false,
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
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
                    ),
                    SizedBox(height: layout.spacing.sectionLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            strings.accountColorLabel,
                            style:
                                theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: state.isSaving
                              ? null
                              : () async {
                                  final Color? picked =
                                      await showAccountColorPickerDialog(
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
                              color: selectedColor ??
                                  colorScheme.surfaceContainerHighest,
                              border: Border.all(
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.4),
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
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          selected ? colors.primary : colors.surfaceContainerHighest,
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
