import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

const Color _kTypeSelectedColor = Color(0xFFAEF75F);
const Color _kTypeSelectedTextColor = Color(0xFF1D3700);
const Color _kPrimaryButtonBackground = Color(0xFFAEF75F);
const Color _kPrimaryButtonForeground = Color(0xFF1D3700);

InputDecoration _transactionTextFieldDecoration(
  BuildContext context, {
  String? labelText,
  String? hintText,
  Color? fillColor,
  Widget? suffixIcon,
}) {
  final ThemeData theme = Theme.of(context);
  final KopimLayout layout = context.kopimLayout;
  final KopimSpacingScale spacing = layout.spacing;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.circular(layout.radius.card),
  );

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    filled: true,
    fillColor: fillColor ?? theme.colorScheme.surfaceContainerHighest,
    contentPadding: EdgeInsets.symmetric(
      horizontal: spacing.section,
      vertical: spacing.section,
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    suffixIcon: suffixIcon,
  );
}

class TransactionFormResult {
  const TransactionFormResult({
    required this.isEditing,
    this.createdTransaction,
  });

  final bool isEditing;
  final TransactionEntity? createdTransaction;
}

class TransactionFormView extends ConsumerWidget {
  const TransactionFormView({
    super.key,
    required this.formKey,
    required this.formArgs,
    required this.onSuccess,
    this.submitLabel,
    this.showSubmitButton = true,
  });

  final GlobalKey<FormState> formKey;
  final TransactionFormArgs formArgs;
  final void Function(TransactionFormResult result) onSuccess;
  final String? submitLabel;
  final bool showSubmitButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      transactionFormAccountsProvider,
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      transactionFormCategoriesProvider,
    );

    ref.listen<TransactionFormState>(
      transactionFormControllerProvider(formArgs),
      (TransactionFormState? previous, TransactionFormState next) {
        if (next.isSuccess && previous?.isSuccess != next.isSuccess) {
          final TransactionEntity? created = next.lastCreatedTransaction;
          final TransactionFormController notifier = ref.read(
            transactionFormControllerProvider(formArgs).notifier,
          );
          notifier
            ..acknowledgeSuccess()
            ..clearLastCreatedTransaction();
          if (context.mounted) {
            onSuccess(
              TransactionFormResult(
                isEditing: formArgs.initialTransaction != null,
                createdTransaction: created,
              ),
            );
          }
        } else if (next.error != null && next.error != previous?.error) {
          final String message = switch (next.error) {
            TransactionFormError.accountMissing =>
              strings.addTransactionAccountMissingError,
            TransactionFormError.transactionMissing =>
              strings.transactionFormMissingError,
            _ => strings.addTransactionUnknownError,
          };
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );

    return accountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => _ErrorMessage(
        message: strings.addTransactionAccountsError(error.toString()),
      ),
      data: (List<AccountEntity> accounts) {
        if (accounts.isEmpty) {
          return _EmptyMessage(message: strings.addTransactionNoAccounts);
        }
        return _TransactionForm(
          formKey: formKey,
          accounts: accounts,
          categoriesAsync: categoriesAsync,
          formArgs: formArgs,
          submitLabel: submitLabel ?? strings.addTransactionSubmit,
          showSubmitButton: showSubmitButton,
        );
      },
    );
  }
}

class _TransactionForm extends ConsumerWidget {
  const _TransactionForm({
    required this.formKey,
    required this.accounts,
    required this.categoriesAsync,
    required this.formArgs,
    required this.submitLabel,
    required this.showSubmitButton,
  });

  final GlobalKey<FormState> formKey;
  final List<AccountEntity> accounts;
  final AsyncValue<List<Category>> categoriesAsync;
  final TransactionFormArgs formArgs;
  final String submitLabel;
  final bool showSubmitButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(formArgs);
    final bool isSubmitting = ref.watch(
      transactionProvider.select(
        (TransactionFormState state) => state.isSubmitting,
      ),
    );

    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final TextStyle labelStyle = theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: theme.colorScheme.onSurfaceVariant,
        ) ??
        theme.textTheme.bodyLarge!;
    final TextStyle helperStyle = theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.surfaceContainerHighest,
        ) ??
        theme.textTheme.bodySmall!;

    return Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final double maxWidth = math.max(availableWidth - spacing.screen * 2, 0);
          final double formWidth = math.min(maxWidth, 412);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              8,
              spacing.sectionLarge,
              8,
              spacing.sectionLarge,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Center(
              child: SizedBox(
                width: formWidth,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _SectionHeader(
                        label: strings.addTransactionAccountLabel,
                        helper: strings.addTransactionAccountHint,
                        labelStyle: labelStyle,
                        helperStyle: helperStyle,
                      ),
                      SizedBox(height: spacing.between),
                      _AccountDropdownField(
                        key: const ValueKey<String>('transaction_account_field'),
                        accounts: accounts,
                        formArgs: formArgs,
                        strings: strings,
                      ),
                      SizedBox(height: spacing.sectionLarge),
                      _SectionHeader(
                        label: strings.addTransactionAmountLabel,
                        labelStyle: labelStyle,
                      ),
                      SizedBox(height: spacing.between),
                      _AmountField(formArgs: formArgs, strings: strings),
                      SizedBox(height: spacing.sectionLarge),
                      _SectionHeader(
                        label: strings.addTransactionTypeLabel,
                        labelStyle: labelStyle,
                      ),
                      SizedBox(height: spacing.between),
                      _TransactionTypeSelector(
                        key: const ValueKey<String>('transaction_type_selector'),
                        formArgs: formArgs,
                        strings: strings,
                      ),
                      SizedBox(height: spacing.sectionLarge),
                      _SectionHeader(
                        label: strings.addTransactionCategoryLabel,
                        labelStyle: labelStyle,
                      ),
                      SizedBox(height: spacing.between),
                      _CategoryDropdownField(
                        key: const ValueKey<String>('transaction_category_field'),
                        categoriesAsync: categoriesAsync,
                        formArgs: formArgs,
                        strings: strings,
                      ),
                      SizedBox(height: spacing.sectionLarge),
                      _DateTimeSelectorRow(formArgs: formArgs),
                      SizedBox(height: spacing.sectionLarge),
                      _NoteField(formArgs: formArgs),
                      if (showSubmitButton) ...[
                        SizedBox(height: spacing.sectionLarge),
                        Center(
                          child: _SubmitButton(
                            key: const ValueKey<String>(
                              'transaction_submit_button',
                            ),
                            formArgs: formArgs,
                            formKey: formKey,
                            isSubmitting: isSubmitting,
                            submitLabel: submitLabel,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AccountDropdownField extends ConsumerStatefulWidget {
  const _AccountDropdownField({
    super.key,
    required this.accounts,
    required this.formArgs,
    required this.strings,
  });

  final List<AccountEntity> accounts;
  final TransactionFormArgs formArgs;
  final AppLocalizations strings;

  @override
  ConsumerState<_AccountDropdownField> createState() =>
      _AccountDropdownFieldState();
}

class _AccountDropdownFieldState extends ConsumerState<_AccountDropdownField> {
  void _selectAccount(String accountId) {
    ref
        .read(transactionFormControllerProvider(widget.formArgs).notifier)
        .updateAccount(accountId);
  }

  @override
  Widget build(BuildContext context) {
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(widget.formArgs);
    final AppLocalizations strings = widget.strings;
    final List<AccountEntity> accounts = widget.accounts;
    final String? selectedAccountId = ref.watch(
      transactionProvider.select(
        (TransactionFormState state) => state.accountId,
      ),
    );

    final String? resolvedAccountId =
        selectedAccountId ??
        _resolveDefaultAccountId(accounts, widget.formArgs.defaultAccountId);
    if (selectedAccountId == null && resolvedAccountId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(transactionProvider.notifier).updateAccount(resolvedAccountId);
      });
    }

    final Map<String, NumberFormat> cache = <String, NumberFormat>{};
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    const double accountRowHeight = 120;
    final List<Widget> accountCards = <Widget>[
      for (int index = 0; index < accounts.length; index++)
        Padding(
          padding: EdgeInsets.only(
            right: index == accounts.length - 1 ? 0 : spacing.between,
          ),
          child: _AccountSelectionCard(
            account: accounts[index],
            formatter: _resolveFormatter(
              cache,
              accounts[index].currency,
              strings.localeName,
            ),
            isSelected: resolvedAccountId != null &&
                accounts[index].id == resolvedAccountId,
            onTap: () => _selectAccount(accounts[index].id),
          ),
        ),
    ];

    return SizedBox(
      height: accountRowHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: accountCards,
        ),
      ),
    );
  }

  NumberFormat _resolveFormatter(
    Map<String, NumberFormat> cache,
    String currency,
    String locale,
  ) {
    final String upper = currency.toUpperCase();
    return cache.putIfAbsent(
      upper,
      () => NumberFormat.currency(locale: locale, symbol: upper),
    );
  }

  String? _resolveDefaultAccountId(
    List<AccountEntity> accounts,
    String? preferredId,
  ) {
    if (preferredId != null) {
      for (final AccountEntity account in accounts) {
        if (account.id == preferredId) {
          return preferredId;
        }
      }
    }
    for (final AccountEntity account in accounts) {
      if (account.isPrimary) {
        return account.id;
      }
    }
    return accounts.isNotEmpty ? accounts.first.id : null;
  }
}

class _AccountSelectionCard extends StatelessWidget {
  const _AccountSelectionCard({
    required this.account,
    required this.formatter,
    required this.isSelected,
    required this.onTap,
  });

  final AccountEntity account;
  final NumberFormat formatter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final Color? accountColor = parseHexColor(account.color);
    final _AccountSelectionCardPalette palette =
        _AccountSelectionCardPalette.fromTheme(
      theme.colorScheme,
      accountColor: accountColor,
    );
    final double cardRadius = layout.radius.card;
    final BorderRadius borderRadius = BorderRadius.circular(cardRadius);
    final TextStyle labelStyle = (theme.textTheme.labelSmall ??
            const TextStyle(fontSize: 11, height: 1.45))
        .copyWith(
      color: palette.support,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w600,
    );
    final TextStyle balanceStyle = (theme.textTheme.titleMedium ??
            const TextStyle(fontSize: 16, height: 20 / 16))
        .copyWith(
      color: palette.emphasis,
      fontWeight: FontWeight.w600,
    );

    const double baseHeight = 72;
    final double cardHeight = baseHeight * (isSelected ? 1.15 : 1);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: SizedBox(
          width: 160,
          height: cardHeight,
          child: Ink(
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: borderRadius,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(account.balance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: balanceStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSelectionCardPalette {
  const _AccountSelectionCardPalette({
    required this.background,
    required this.emphasis,
    required this.support,
  });

  factory _AccountSelectionCardPalette.fromTheme(
    ColorScheme colorScheme, {
    Color? accountColor,
  }) {
    final Color background =
        accountColor ?? colorScheme.surfaceContainerHigh;
    final Brightness brightness =
        ThemeData.estimateBrightnessForColor(background);
    final Color emphasis =
        brightness == Brightness.dark ? Colors.white : Colors.black87;
    final Color support =
        brightness == Brightness.dark ? Colors.white70 : Colors.black54;
    return _AccountSelectionCardPalette(
      background: background,
      emphasis: emphasis,
      support: support,
    );
  }

  final Color background;
  final Color emphasis;
  final Color support;
}

class _TransactionTypeSelector extends ConsumerWidget {
  const _TransactionTypeSelector({
    super.key,
    required this.formArgs,
    required this.strings,
  });

  final TransactionFormArgs formArgs;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(formArgs);
    final TransactionType type = ref.watch(
      transactionProvider.select((TransactionFormState state) => state.type),
    );

    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final double containerRadius = layout.radius.xxl;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _TypeChip(
              label: strings.addTransactionTypeExpense,
              selected: type == TransactionType.expense,
              onTap: () => ref
                  .read(transactionProvider.notifier)
                  .updateType(TransactionType.expense),
              highlightColor: _kTypeSelectedColor,
              selectedTextColor: _kTypeSelectedTextColor,
            ),
          ),
          SizedBox(width: spacing.between),
          Expanded(
            child: _TypeChip(
              label: strings.addTransactionTypeIncome,
              selected: type == TransactionType.income,
              onTap: () => ref
                  .read(transactionProvider.notifier)
                  .updateType(TransactionType.income),
              highlightColor: _kTypeSelectedColor,
              selectedTextColor: _kTypeSelectedTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryDropdownField extends ConsumerStatefulWidget {
  const _CategoryDropdownField({
    super.key,
    required this.categoriesAsync,
    required this.formArgs,
    required this.strings,
  });

  final AsyncValue<List<Category>> categoriesAsync;
  final TransactionFormArgs formArgs;
  final AppLocalizations strings;

  @override
  ConsumerState<_CategoryDropdownField> createState() =>
      _CategoryDropdownFieldState();
}

class _CategoryDropdownFieldState
    extends ConsumerState<_CategoryDropdownField> {
  bool _showAll = false;
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text;
      _showAll = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleShowAll() {
    setState(() {
      _showAll = !_showAll;
    });
  }

  void _selectCategory(String? categoryId) {
    ref
        .read(transactionFormControllerProvider(widget.formArgs).notifier)
        .updateCategory(categoryId);
    setState(() {
      _showAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.categoriesAsync.when(
      data: (List<Category> categories) =>
          _buildCategoryPanel(context, categories),
      loading: () => _buildStatus(
        context,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, _) =>
          _buildStatus(context, child: Text(error.toString())),
    );
  }

  Widget _buildCategoryPanel(BuildContext context, List<Category> categories) {
    final AppLocalizations strings = widget.strings;
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final double containerRadius = layout.radius.xxl;
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(widget.formArgs);
    final String? selectedCategoryId = ref.watch(
      transactionProvider.select((TransactionFormState state) => state.categoryId),
    );
    final TransactionType type = ref.watch(
      transactionProvider.select((TransactionFormState state) => state.type),
    );
    final String normalizedQuery = _query.trim().toLowerCase();
    final List<Category> filtered = categories
        .where(
          (Category category) =>
              category.type.toLowerCase() == type.storageValue &&
              (normalizedQuery.isEmpty ||
                  category.name.toLowerCase().contains(normalizedQuery)),
        )
        .toList(growable: false);
    final List<Category> favoriteCategories = filtered
        .where((Category category) => category.isFavorite)
        .toList(growable: false);
    Category? selectedCategory;
    if (selectedCategoryId != null) {
      for (final Category category in filtered) {
        if (category.id == selectedCategoryId) {
          selectedCategory = category;
          break;
        }
      }
    }
    final bool hasSelection = selectedCategory != null;
    final bool showFavoritesInHeader = !hasSelection || _showAll;
    final List<Category> headerFavorites = <Category>[
      for (final Category category in favoriteCategories)
        if (!hasSelection || category.id != selectedCategoryId) category,
    ];
    final List<Category> otherCategories = filtered.where((Category category) {
      if (category.isFavorite) {
        return false;
      }
      if (!hasSelection) {
        return true;
      }
      return category.id != selectedCategory!.id;
    }).toList(growable: false);
    final String buttonLabel = _showAll
        ? strings.addTransactionHideCategories
        : strings.addTransactionShowAllCategories;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _searchController,
            decoration: _transactionTextFieldDecoration(
              context,
              hintText: strings.addTransactionCategorySearchHint,
              suffixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed:
                  otherCategories.isEmpty && favoriteCategories.isEmpty
                      ? null
                      : _toggleShowAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(126, 20),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                buttonLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: spacing.between,
            runSpacing: spacing.between,
            children: <Widget>[
              if (hasSelection && selectedCategory != null)
                _buildCategoryChip(
                  category: selectedCategory,
                  selected: true,
                ),
              if (showFavoritesInHeader)
                for (final Category category in headerFavorites)
                  _buildCategoryChip(
                    category: category,
                    selected: category.id == selectedCategoryId,
                  ),
            ],
          ),
          if (_showAll && otherCategories.isNotEmpty) ...<Widget>[
            SizedBox(height: spacing.between),
            Wrap(
              spacing: spacing.between,
              runSpacing: spacing.between,
              children: <Widget>[
                for (final Category category in otherCategories)
                  _buildCategoryChip(
                    category: category,
                    selected: category.id == selectedCategoryId,
                  ),
              ],
            ),
          ],
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                strings.addTransactionCategoryNone,
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context, {required Widget child}) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius:
            BorderRadius.circular(context.kopimLayout.radius.xxl),
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }

  Widget _buildCategoryChip({
    required Category category,
    required bool selected,
  }) {
    final IconData? iconData = resolvePhosphorIconData(category.icon);
    final Color? backgroundColor = parseHexColor(category.color);
    return _CategoryChip(
      label: category.name,
      icon: iconData,
      baseColor: backgroundColor,
      selected: selected,
      onTap: () => _selectCategory(category.id),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.baseColor,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color? baseColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color circleBackground =
        baseColor ?? theme.colorScheme.surfaceContainerHigh;
    final Color textColor = theme.colorScheme.onSurface;
    const Color borderColor = _kTypeSelectedColor;
    final double containerRadius = context.kopimLayout.radius.xxl;
    final BorderRadius borderRadius = BorderRadius.circular(containerRadius);
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius,
          border: selected
              ? Border.all(color: borderColor, width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: circleBackground,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon ?? Icons.category_outlined,
                size: 18,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends ConsumerWidget {
  const _SubmitButton({
    super.key,
    required this.formArgs,
    required this.formKey,
    required this.isSubmitting,
    required this.submitLabel,
  });

  final TransactionFormArgs formArgs;
  final GlobalKey<FormState> formKey;
  final bool isSubmitting;
  final String submitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(formArgs);
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        key: key,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimaryButtonBackground,
          foregroundColor: _kPrimaryButtonForeground,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 0,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
        ),
        onPressed: isSubmitting
            ? null
            : () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await Future<void>.delayed(Duration.zero);
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                await ref.read(transactionProvider.notifier).submit();
              },
        child: isSubmitting
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _kPrimaryButtonForeground,
                  semanticsLabel: submitLabel,
                ),
              )
            : Text(
                submitLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                  color: _kPrimaryButtonForeground,
                ),
              ),
      ),
    );
  }
}

class _AmountField extends ConsumerStatefulWidget {
  const _AmountField({required this.formArgs, required this.strings});

  final TransactionFormArgs formArgs;
  final AppLocalizations strings;

  @override
  ConsumerState<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends ConsumerState<_AmountField> {
  late final TextEditingController _controller;
  ProviderSubscription<String>? _subscription;
  Timer? _debounce;
  String _lastSyncedValue = '';
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final TransactionFormState initialState = ref.read(
      transactionFormControllerProvider(widget.formArgs),
    );
    _controller = TextEditingController(text: initialState.amount);
    _lastSyncedValue = initialState.amount;
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    if (!initialState.isEditing && initialState.amount.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
    _subscription = ref.listenManual<String>(
      transactionFormControllerProvider(
        widget.formArgs,
      ).select((TransactionFormState state) => state.amount),
      (String? previous, String next) {
        if (next == _controller.text) {
          _lastSyncedValue = next;
          return;
        }
        _lastSyncedValue = next;
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _subscription?.close();
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      _pushUpdate(value);
    });
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _flushPendingUpdate();
    }
  }

  void _pushUpdate(String value) {
    final String normalized = value.replaceAll(',', '.');
    if (_lastSyncedValue == normalized) {
      return;
    }
    _lastSyncedValue = normalized;
    ref
        .read(transactionFormControllerProvider(widget.formArgs).notifier)
        .updateAmount(normalized);
  }

  void _flushPendingUpdate() {
    _debounce?.cancel();
    final String normalized = _controller.text.replaceAll(',', '.');
    if (_controller.text != normalized) {
      _controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
    _pushUpdate(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSubmitting = ref.watch(
      transactionFormControllerProvider(
        widget.formArgs,
      ).select((TransactionFormState state) => state.isSubmitting),
    );

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: !isSubmitting,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: _transactionTextFieldDecoration(
        context,
        hintText: widget.strings.addTransactionAmountHint,
      ),
      onChanged: _handleChanged,
      onEditingComplete: () {
        _flushPendingUpdate();
        FocusScope.of(context).nextFocus();
      },
      onTapOutside: (_) => _flushPendingUpdate(),
      validator: (_) {
        final double? value = ref
            .read(transactionFormControllerProvider(widget.formArgs))
            .parsedAmount;
        if (value == null) {
          return widget.strings.addTransactionAmountInvalid;
        }
        return null;
      },
    );
  }
}

class _NoteField extends ConsumerWidget {
  const _NoteField({required this.formArgs});

  final TransactionFormArgs formArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final String note = ref.watch(
      transactionFormControllerProvider(
        formArgs,
      ).select((TransactionFormState state) => state.note),
    );

    return TextFormField(
      initialValue: note,
      minLines: 3,
      maxLines: 3,
      decoration: _transactionTextFieldDecoration(
        context,
        labelText: strings.addTransactionNoteLabel,
      ),
      onChanged: ref
          .read(transactionFormControllerProvider(formArgs).notifier)
          .updateNote,
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.labelStyle,
    this.helper,
    this.helperStyle,
  });

  final String label;
  final String? helper;
  final TextStyle labelStyle;
  final TextStyle? helperStyle;

  @override
  Widget build(BuildContext context) {
    final TextStyle resolvedHelperStyle =
        helperStyle ?? labelStyle.copyWith(fontWeight: FontWeight.w400);
    final List<Widget> children = <Widget>[
      Text(label, style: labelStyle),
    ];
    if (helper != null && helper!.isNotEmpty) {
      children
        ..add(const SizedBox(height: 4))
        ..add(Text(helper!, style: resolvedHelperStyle));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.highlightColor,
    required this.selectedTextColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color highlightColor;
  final Color selectedTextColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = selected
        ? selectedTextColor
        : theme.colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? highlightColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTimeSelectorRow extends ConsumerWidget {
  const _DateTimeSelectorRow({required this.formArgs});

  final TransactionFormArgs formArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(formArgs);
    final DateTime selectedDate = ref.watch(
      transactionProvider.select((TransactionFormState state) => state.date),
    );
    final TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    final ThemeData theme = Theme.of(context);
    final double containerRadius = context.kopimLayout.radius.xxl;

    Future<void> handleDateSelection() async {
      final DateTime initial = selectedDate;
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        ref
            .read(transactionProvider.notifier)
            .updateDate(
              DateTime(
                picked.year,
                picked.month,
                picked.day,
                initial.hour,
                initial.minute,
              ),
            );
      }
    }

    Future<void> handleTimeSelection() async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.input,
      );
      if (picked != null) {
        ref
            .read(transactionProvider.notifier)
            .updateTime(hour: picked.hour, minute: picked.minute);
      }
    }

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(containerRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                strings.addTransactionChangeDateTimeHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.event),
              color: theme.colorScheme.onSurface,
              onPressed: handleDateSelection,
              tooltip: strings.addTransactionDateLabel,
            ),
            IconButton(
              icon: const Icon(Icons.schedule),
              color: theme.colorScheme.onSurface,
              onPressed: handleTimeSelection,
              tooltip: strings.addTransactionTimeLabel,
            ),
          ],
        ),
      ),
    );
  }
}
