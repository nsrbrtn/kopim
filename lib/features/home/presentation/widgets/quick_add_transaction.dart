import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/utils/text_input_formatters.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/accounts_add_screen.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/quick_transaction_controller.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_actions_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class QuickAddTransactionCard extends ConsumerWidget {
  const QuickAddTransactionCard({super.key, required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<Category>> categoriesAsync =
        ref.watch(homeCategoriesProvider);
    final AsyncValue<List<AccountEntity>> accountsAsync =
        ref.watch(homeAccountsProvider);
    final List<AccountEntity>? accounts = accountsAsync.asData?.value;
    final String? defaultAccountId =
        (accounts != null && accounts.isNotEmpty) ? accounts.first.id : null;
    final bool hasAccounts = defaultAccountId != null;
    final KopimLayout layout = context.kopimLayout;

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(layout.radius.xxl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Быстрая операция',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Icon(Icons.flash_on_rounded,
                      color: theme.colorScheme.primary, size: 20),
                ],
              ),
              SizedBox(height: layout.spacing.between),
              categoriesAsync.when(
                data: (List<Category> categories) {
                  final List<Category> available = categories
                      .where((Category category) => !category.isDeleted)
                      .toList(growable: false);
                  if (available.isEmpty) {
                    return _EmptyState(
                      message: strings.addTransactionCategoriesLoading,
                    );
                  }

                  final List<Category> favorites = available
                      .where((Category category) => category.isFavorite)
                      .toList(growable: false);
                  final List<Category> selection =
                      favorites.isNotEmpty ? favorites : available;
                  final Iterable<Category> topSelection =
                      selection.take(12).toList();

                  return SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: topSelection.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(width: layout.spacing.section),
                      itemBuilder: (BuildContext _, int index) {
                        final Category category = topSelection.elementAt(index);
                        return _QuickCategoryIcon(
                          category: category,
                          onTap: hasAccounts
                              ? () => _openQuickForm(
                                    context,
                                    ref,
                                    category,
                                    defaultAccountId,
                                    strings,
                                  )
                              : null,
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 64,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (Object error, _) => _EmptyState(
                  message: strings.addTransactionCategoriesError(
                    error.toString(),
                  ),
                ),
              ),
              if (!hasAccounts)
                Padding(
                  padding: EdgeInsets.only(top: layout.spacing.between),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          strings.addTransactionNoAccounts,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.72),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            context.push(AddAccountScreen.routeName),
                        icon: const Icon(Icons.add),
                        label: Text(strings.homeAccountsAddTooltip),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  TransactionType _mapType(String? value) {
    final String normalized = value?.toLowerCase().trim() ?? '';
    return normalized == TransactionType.income.storageValue
        ? TransactionType.income
        : TransactionType.expense;
  }

  void _openQuickForm(
    BuildContext context,
    WidgetRef ref,
    Category category,
    String? defaultAccountId,
    AppLocalizations strings,
  ) {
    ref.read(quickTransactionControllerProvider.notifier).prepare(
          categoryId: category.id,
          categoryType: _mapType(category.type),
          defaultAccountId: defaultAccountId,
        );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _QuickTransactionSheet(
        category: category,
        strings: strings,
      ),
    );
  }
}

class _QuickCategoryIcon extends StatelessWidget {
  const _QuickCategoryIcon({required this.category, this.onTap});

  final Category category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background =
        parseHexColor(category.color) ?? theme.colorScheme.surfaceContainerHigh;
    const Color iconColor = Color(0xFF101010);
    final PhosphorIconData? iconData = resolvePhosphorIconData(
      category.icon,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(44),
        onTap: onTap,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            iconData ?? Icons.category_outlined,
            color: iconColor,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _QuickTransactionSheet extends ConsumerStatefulWidget {
  const _QuickTransactionSheet({
    required this.category,
    required this.strings,
  });

  final Category category;
  final AppLocalizations strings;

  @override
  ConsumerState<_QuickTransactionSheet> createState() =>
      _QuickTransactionSheetState();
}

class _QuickTransactionSheetState
    extends ConsumerState<_QuickTransactionSheet> {
  late final TextEditingController _amountController;
  late final FocusNode _amountFocusNode;
  ProviderSubscription<QuickTransactionState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    final QuickTransactionState initialState =
        ref.read(quickTransactionControllerProvider);
    _amountController = TextEditingController(text: initialState.amount);
    _amountFocusNode = FocusNode();

    _stateSubscription = ref.listenManual<QuickTransactionState>(
      quickTransactionControllerProvider,
      (QuickTransactionState? _, QuickTransactionState next) {
        if (_amountController.text == next.amount) {
          return;
        }
        _amountController.value = TextEditingValue(
          text: next.amount,
          selection: TextSelection.collapsed(offset: next.amount.length),
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.close();
    _amountFocusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSubmitting = ref.watch(
      quickTransactionControllerProvider.select(
        (QuickTransactionState state) => state.isSubmitting,
      ),
    );
    final QuickTransactionError? error = ref.watch(
      quickTransactionControllerProvider.select(
        (QuickTransactionState state) => state.error,
      ),
    );
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(layout.radius.xxl),
            ),
          ),
          padding: EdgeInsets.all(layout.spacing.section),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: EdgeInsets.only(bottom: layout.spacing.between),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(layout.radius.card),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  _QuickCategoryIcon(category: widget.category),
                  SizedBox(width: layout.spacing.between),
                  Expanded(
                    child: Text(
                      widget.category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: layout.spacing.section),
              KopimTextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                placeholder: widget.strings.addTransactionAmountHint,
                onChanged: (String value) => ref
                    .read(quickTransactionControllerProvider.notifier)
                    .updateAmount(value),
                onSubmitted: (_) => _submit(),
                inputFormatters: <TextInputFormatter>[
                  digitsAndSeparatorsFormatter(),
                ],
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.payments_outlined,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              if (error != null) ...<Widget>[
                SizedBox(height: layout.spacing.between / 2),
                Text(
                  _errorMessage(widget.strings, error),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
              SizedBox(height: layout.spacing.section),
              FilledButton.icon(
                onPressed: isSubmitting ? null : _submit,
                icon: isSubmitting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(widget.strings.addTransactionSubmit),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: layout.spacing.between,
                  ),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _errorMessage(
    AppLocalizations strings,
    QuickTransactionError error,
  ) {
    switch (error) {
      case QuickTransactionError.accountMissing:
        return strings.addTransactionAccountMissingError;
      case QuickTransactionError.invalidInput:
        return strings.addTransactionAmountInvalid;
      case QuickTransactionError.unknown:
        return strings.addTransactionUnknownError;
    }
  }

  Future<void> _submit() async {
    final double? parsedAmount =
        ref.read(quickTransactionControllerProvider).parsedAmount;
    if (parsedAmount == null) {
      ref
          .read(quickTransactionControllerProvider.notifier)
          .updateAmount(_amountController.text);
      ref
          .read(quickTransactionControllerProvider.notifier)
          .submit(); // установит ошибку invalidInput
      return;
    }
    final TransactionEntity? created = await ref
        .read(quickTransactionControllerProvider.notifier)
        .submit();
    if (!mounted) return;
    if (created == null) {
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(widget.strings.addTransactionSuccess),
        action: SnackBarAction(
          label: widget.strings.commonUndo,
          onPressed: () {
            ref
                .read(transactionActionsControllerProvider.notifier)
                .deleteTransaction(created.id)
                .then((bool undone) {
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      undone
                          ? widget.strings.addTransactionUndoSuccess
                          : widget.strings.addTransactionUndoError,
                    ),
                  ),
                );
            });
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68),
        );
    return SizedBox(
      height: 64,
      child: Center(
        child: Text(
          message,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
