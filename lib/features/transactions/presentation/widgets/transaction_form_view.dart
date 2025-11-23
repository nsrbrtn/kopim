import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/widgets/category_chip.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

const EdgeInsets _kFormOuterPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 16,
);
const EdgeInsets _kAccountSectionPadding = EdgeInsets.all(16);
const EdgeInsets _kCategorySectionPadding = EdgeInsets.all(16);
const EdgeInsets _kDateTimeSectionPadding = EdgeInsets.symmetric(
  vertical: 12,
  horizontal: 16,
);
const SizedBox _kGap8 = SizedBox(height: 8);

AccountEntity _resolveSummaryAccount(
  List<AccountEntity> accounts,
  String? selectedAccountId,
  String? preferredAccountId,
) {
  final String? resolvedId =
      selectedAccountId ??
      _resolveDefaultAccountId(accounts, preferredAccountId);
  final AccountEntity? resolved = accounts.firstWhereOrNull(
    (AccountEntity account) => account.id == resolvedId,
  );
  if (resolved != null) {
    return resolved;
  }
  return accounts.firstWhereOrNull(
        (AccountEntity account) => account.isPrimary,
      ) ??
      accounts.first;
}

String? _resolveDefaultAccountId(
  List<AccountEntity> accounts,
  String? preferredId,
) {
  if (preferredId != null &&
      accounts.any((AccountEntity account) => account.id == preferredId)) {
    return preferredId;
  }
  final AccountEntity? primary = accounts.firstWhereOrNull(
    (AccountEntity account) => account.isPrimary,
  );
  if (primary != null) {
    return primary.id;
  }
  return accounts.isNotEmpty ? accounts.first.id : null;
}

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
    fillColor: fillColor ?? theme.colorScheme.surfaceContainerHigh,
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

class _TransactionForm extends ConsumerStatefulWidget {
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
  ConsumerState<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<_TransactionForm> {
  bool _isAmountSectionCollapsed = false;
  final Map<String, NumberFormat> _formatterCache = <String, NumberFormat>{};

  void _handleAmountCommitted(bool hasValidAmount) {
    if (hasValidAmount && !_isAmountSectionCollapsed) {
      setState(() {
        _isAmountSectionCollapsed = true;
      });
    } else if (!hasValidAmount && _isAmountSectionCollapsed) {
      setState(() {
        _isAmountSectionCollapsed = false;
      });
    }
  }

  void _expandAmountSection() {
    if (_isAmountSectionCollapsed) {
      setState(() {
        _isAmountSectionCollapsed = false;
      });
    }
  }

  NumberFormat _formatterForCurrency(String currency, String locale) {
    final String symbol = resolveCurrencySymbol(currency, locale: locale);
    return _formatterCache.putIfAbsent(
      symbol,
      () => NumberFormat.currency(locale: locale, symbol: symbol),
    );
  }

  String _formatAmount(double amount, String currency, String locale) {
    final NumberFormat formatter = _formatterForCurrency(currency, locale);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(widget.formArgs);
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final TextStyle labelStyle =
        theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: theme.colorScheme.onSurfaceVariant,
        ) ??
        theme.textTheme.bodyLarge!;
    final TextStyle helperStyle =
        theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.surfaceContainerHighest,
        ) ??
        theme.textTheme.bodySmall!;

    final bool isSubmitting = ref.watch(
      transactionProvider.select(
        (TransactionFormState state) => state.isSubmitting,
      ),
    );
    final double? parsedAmount = ref.watch(
      transactionProvider.select(
        (TransactionFormState state) => state.parsedAmount,
      ),
    );
    final bool hasValidAmount = parsedAmount != null;
    final String? selectedAccountId = ref.watch(
      transactionProvider.select(
        (TransactionFormState state) => state.accountId,
      ),
    );

    final AccountEntity summaryAccount = _resolveSummaryAccount(
      widget.accounts,
      selectedAccountId,
      widget.formArgs.defaultAccountId,
    );
    final String formattedAmount = hasValidAmount && parsedAmount != null
        ? _formatAmount(
            parsedAmount,
            summaryAccount.currency,
            strings.localeName,
          )
        : '';
    final bool showCollapsed = _isAmountSectionCollapsed && hasValidAmount;

    return Form(
      key: widget.formKey,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final double maxWidth = math.max(
            availableWidth - spacing.screen * 2,
            0,
          );
          final double formWidth = math.min(maxWidth, 412);

          final List<Widget> sections = <Widget>[
            RepaintBoundary(
              child: _buildAccountAmountSection(
                context: context,
                strings: strings,
                labelStyle: labelStyle,
                helperStyle: helperStyle,
                spacing: spacing,
                transactionProvider: transactionProvider,
                formattedAmount: formattedAmount,
                summaryAccount: summaryAccount,
                showCollapsed: showCollapsed,
              ),
            ),
            RepaintBoundary(
              child: _CategoryDropdownField(
                key: const ValueKey<String>('transaction_category_field'),
                categoriesAsync: widget.categoriesAsync,
                formArgs: widget.formArgs,
                strings: strings,
              ),
            ),
            RepaintBoundary(
              child: _DateTimeSelectorRow(formArgs: widget.formArgs),
            ),
            RepaintBoundary(child: _NoteField(formArgs: widget.formArgs)),
          ];

          if (widget.showSubmitButton) {
            sections.add(
              RepaintBoundary(
                child: Center(
                  child: _SubmitButton(
                    key: const ValueKey<String>('transaction_submit_button'),
                    formArgs: widget.formArgs,
                    formKey: widget.formKey,
                    isSubmitting: isSubmitting,
                    submitLabel: widget.submitLabel,
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: _kFormOuterPadding,
            child: Center(
              child: SizedBox(
                width: formWidth,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  cacheExtent: MediaQuery.sizeOf(context).height,
                  itemCount: sections.length,
                  itemBuilder: (BuildContext context, int index) {
                    return sections[index];
                  },
                  separatorBuilder: (BuildContext _, int index) => _kGap8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountAmountSection({
    required BuildContext context,
    required AppLocalizations strings,
    required TextStyle labelStyle,
    required TextStyle helperStyle,
    required KopimSpacingScale spacing,
    required TransactionFormControllerProvider transactionProvider,
    required String formattedAmount,
    required AccountEntity summaryAccount,
    required bool showCollapsed,
  }) {
    final ThemeData theme = Theme.of(context);
    final double containerRadius = context.kopimLayout.radius.xxl;
    final Widget expanded = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      padding: _kAccountSectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SectionHeader(
            label: 'Выбери счёт',
            labelStyle: labelStyle,
          ),
          SizedBox(height: spacing.between / 2),
          _AccountDropdownField(
            key: const ValueKey<String>('transaction_account_field'),
            accounts: widget.accounts,
            formArgs: widget.formArgs,
            strings: strings,
          ),
          SizedBox(height: spacing.between),
          _SectionHeader(
            label: strings.addTransactionAmountLabel,
            labelStyle: labelStyle,
          ),
          SizedBox(height: spacing.between),
          _AmountField(
            formArgs: widget.formArgs,
            strings: strings,
            onAmountCommitted: _handleAmountCommitted,
          ),
        ],
      ),
    );

    final Widget collapsed = _buildCollapsedAccountSummary(
      context: context,
      account: summaryAccount,
      amountLabel: formattedAmount,
      onTap: _expandAmountSection,
    );

    return AnimatedCrossFade(
      firstChild: expanded,
      secondChild: collapsed,
      crossFadeState: showCollapsed
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 260),
      firstCurve: Curves.easeOut,
      secondCurve: Curves.easeOut,
      sizeCurve: Curves.easeInOut,
    );
  }

  Widget _buildCollapsedAccountSummary({
    required BuildContext context,
    required AccountEntity account,
    required String amountLabel,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final Color? accent = parseHexColor(account.color);
    final double radius = layout.radius.xxl;
    final double spacing = layout.spacing.section;
    final String initials = account.name.isNotEmpty
        ? account.name.substring(0, 1)
        : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: EdgeInsets.all(spacing),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent ?? theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                initials.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    account.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: layout.spacing.section / 2),
                  Text(
                    amountLabel,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: layout.spacing.section / 4),
                ],
              ),
            ),
          ],
        ),
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
            left: 2,
            right: index == accounts.length - 1 ? 2 : spacing.between / 2 + 2,
          ),
          child: _AccountSelectionCard(
            account: accounts[index],
            formatter: _resolveFormatter(
              cache,
              accounts[index].currency,
              strings.localeName,
            ),
            isSelected:
                resolvedAccountId != null &&
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
        child: Row(children: accountCards),
      ),
    );
  }

  NumberFormat _resolveFormatter(
    Map<String, NumberFormat> cache,
    String currency,
    String locale,
  ) {
    final String symbol = resolveCurrencySymbol(currency, locale: locale);
    return cache.putIfAbsent(
      symbol,
      () => NumberFormat.currency(locale: locale, symbol: symbol),
    );
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
    final Color? accountColor = parseHexColor(account.color);
    final _AccountSelectionCardPalette palette =
        _AccountSelectionCardPalette.fromTheme(
          theme.colorScheme,
          accountColor: accountColor,
        );
    const double cardRadius = 16;
    final BorderRadius borderRadius = BorderRadius.circular(cardRadius);
    final TextStyle labelStyle =
        (theme.textTheme.labelSmall ??
                const TextStyle(fontSize: 11, height: 1.45))
            .copyWith(
              color: palette.support,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            );
    final TextStyle balanceStyle =
        (theme.textTheme.titleMedium ??
                const TextStyle(fontSize: 16, height: 20 / 16))
            .copyWith(color: palette.emphasis, fontWeight: FontWeight.w600);

    const double cardHeight = 72;
    const double cardWidth = 160;
    final EdgeInsets outerPadding =
        isSelected ? const EdgeInsets.all(4) : EdgeInsets.zero;
    final double paddedWidth = cardWidth + outerPadding.horizontal;
    final double paddedHeight = cardHeight + outerPadding.vertical;

    return SizedBox(
      width: paddedWidth,
      height: paddedHeight,
      child: GlowingAccountCard(
        glowColor: accountColor ?? theme.colorScheme.primary,
        borderRadius: cardRadius.toDouble(),
        enabled: isSelected,
        child: Padding(
          padding: outerPadding,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: SizedBox(
                width: cardWidth,
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
          ),
        ),
      ),
    );
  }
}

/// Карточка счета с анимированным «змейкой»-свечением.
///
/// Параметры анимации:
/// * `duration` — полный круг змейки (по умолчанию 4400 мс).
/// * `glowColor` — цвет змейки и направляющей обводки.
/// * `borderRadius` — радиус скругления траектории (совпадает с карточкой).
/// * `enabled` — когда `false`, свечение полностью отключено.
class GlowingAccountCard extends StatefulWidget {
  const GlowingAccountCard({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF00F7FF),
    this.duration = const Duration(milliseconds: 4400),
    this.borderRadius = 24.0,
    this.enabled,
  });

  final Widget child;
  final Color glowColor;
  final Duration duration;
  final double borderRadius;
  final bool? enabled;

  @override
  State<GlowingAccountCard> createState() => _GlowingAccountCardState();
}

class _GlowingAccountCardState extends State<GlowingAccountCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  bool get _isEnabled => widget.enabled ?? true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isEnabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant GlowingAccountCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isEnabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!_isEnabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEnabled) {
      return widget.child;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _curve,
        child: widget.child,
        builder: (BuildContext context, Widget? child) {
          final double t = _curve.value;
          const double strokeWidth = 4.0;

          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GlowBorderPainter(
                      color: widget.glowColor,
                      progress: t,
                      thickness: strokeWidth,
                      borderRadius: widget.borderRadius,
                    ),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
      ),
    );
  }
}

class _GlowBorderPainter extends CustomPainter {
  const _GlowBorderPainter({
    required this.color,
    required this.progress,
    required this.thickness,
    required this.borderRadius,
  });

  final Color color;
  final double progress;
  final double thickness;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final Rect rect = Offset.zero & size;
    final double guideThickness = math.min(thickness, 2.0);
    final RRect waveRrect = RRect.fromRectAndRadius(
      rect.deflate(thickness / 2),
      Radius.circular(borderRadius),
    );
    final RRect guideRrect = RRect.fromRectAndRadius(
      rect.deflate(guideThickness / 2),
      Radius.circular(borderRadius),
    );
    final SweepGradient gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: math.pi * 2,
      transform: GradientRotation(progress * math.pi * 2),
      colors: <Color>[
        _colorWithOpacity(color, 0.0),
        _colorWithOpacity(color, 0.0),
        _colorWithOpacity(color, 0.75),
        _colorWithOpacity(color, 0.0),
        _colorWithOpacity(color, 0.0),
      ],
      stops: const <double>[0.0, 0.08, 0.14, 0.20, 1.0],
    );

    final Paint guidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideThickness
      ..color = _colorWithOpacity(color, 0.30);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..shader = gradient.createShader(rect);

    canvas
      ..drawRRect(guideRrect, guidePaint)
      ..drawRRect(waveRrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.progress != progress ||
        oldDelegate.thickness != thickness ||
        oldDelegate.borderRadius != borderRadius;
  }
}

Color _colorWithOpacity(Color color, double opacity) =>
    color.withValues(alpha: opacity.clamp(0.0, 1.0));

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
    final Color background = accountColor ?? colorScheme.surfaceContainerHigh;
    final Brightness brightness = ThemeData.estimateBrightnessForColor(
      background,
    );
    final Color emphasis = brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final Color support = brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
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

/// Сегментированный переключатель «Расход/Доход» в стиле Kopim.
///
/// Стиль и анимация (для повторного использования):
/// - Трек: `surfaceContainerHigh`, скругление 999.
/// - Активная таблетка: цвет `primary` без прозрачности, скругление 999,
///   анимация смещения `AnimatedPositioned` + `AnimatedContainer`
///   с `Curves.easeOutBack` и длительностью 260 мс.
/// - Текст: `labelLarge`, анимированное изменение толщины и масштаба
///   (`AnimatedDefaultTextStyle` + `AnimatedScale`), выбранный цвет — `onPrimary`,
///   невыбранный — `onSurface` c 80% прозрачностью.
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
    final double containerRadius = layout.radius.xxl;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double segmentWidth = constraints.maxWidth / 2;
          final Color accent = theme.colorScheme.primary;
          const Duration duration = Duration(milliseconds: 260);

          return SizedBox(
            height: 48,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: duration,
                  curve: Curves.easeOutBack,
                  left: (type == TransactionType.expense ? 0 : 1) *
                      segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: Curves.easeOutBack,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: accent,
                      boxShadow: const <BoxShadow>[],
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _TypeSegmentItem(
                        label: strings.addTransactionTypeExpense,
                        selected: type == TransactionType.expense,
                        onTap: () => ref
                            .read(transactionProvider.notifier)
                            .updateType(TransactionType.expense),
                        selectedTextColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                    Expanded(
                      child: _TypeSegmentItem(
                        label: strings.addTransactionTypeIncome,
                        selected: type == TransactionType.income,
                        onTap: () => ref
                            .read(transactionProvider.notifier)
                            .updateType(TransactionType.income),
                        selectedTextColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
  List<Category> _cachedHeaderCategories = const <Category>[];
  List<Category> _cachedOtherCategories = const <Category>[];
  List<Widget> _headerChipWidgets = const <Widget>[];
  List<Widget> _otherChipWidgets = const <Widget>[];
  String? _cachedSelectedCategoryId;
  bool _cachedShowFavoritesInHeader = false;

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

  void _updateCategoryChipCache({
    required List<Category> headerCategories,
    required List<Category> otherCategories,
    required String? selectedCategoryId,
    required bool showFavoritesInHeader,
    required bool showOtherCategories,
  }) {
    final bool headerChanged = !_areCategoryListsEqual(
      headerCategories,
      _cachedHeaderCategories,
    );
    final bool otherChanged = showOtherCategories
        ? !_areCategoryListsEqual(otherCategories, _cachedOtherCategories)
        : _cachedOtherCategories.isNotEmpty;
    final bool selectionChanged =
        _cachedSelectedCategoryId != selectedCategoryId;
    final bool favoritesChanged =
        _cachedShowFavoritesInHeader != showFavoritesInHeader;
    if (!headerChanged &&
        !otherChanged &&
        !selectionChanged &&
        !favoritesChanged) {
      return;
    }

    _cachedHeaderCategories = headerCategories;
    _cachedShowFavoritesInHeader = showFavoritesInHeader;
    _cachedSelectedCategoryId = selectedCategoryId;
    _headerChipWidgets = headerCategories
        .map(
          (Category category) =>
              _buildCategoryChip(category, selectedCategoryId),
        )
        .toList(growable: false);

    if (showOtherCategories) {
      _cachedOtherCategories = otherCategories;
      _otherChipWidgets = otherCategories
          .map(
            (Category category) =>
                _buildCategoryChip(category, selectedCategoryId),
          )
          .toList(growable: false);
    } else {
      _cachedOtherCategories = const <Category>[];
      _otherChipWidgets = const <Widget>[];
    }
  }

  bool _areCategoryListsEqual(List<Category> first, List<Category> second) {
    final List<String> firstIds = first
        .map((Category category) => category.id)
        .toList();
    final List<String> secondIds = second
        .map((Category category) => category.id)
        .toList();
    return const ListEquality<String>().equals(firstIds, secondIds);
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
      transactionProvider.select(
        (TransactionFormState state) => state.categoryId,
      ),
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
    final List<Category> otherCategories = filtered
        .where((Category category) {
          if (category.isFavorite) {
            return false;
          }
          if (!hasSelection) {
            return true;
          }
          return category.id != selectedCategory!.id;
        })
        .toList(growable: false);
    final String buttonLabel = _showAll
        ? strings.addTransactionHideCategories
        : strings.addTransactionShowAllCategories;
    final List<Category> headerCategories = <Category>[
      if (selectedCategory != null) selectedCategory,
      if (showFavoritesInHeader) ...headerFavorites,
    ];
    final bool showOtherCategories = _showAll && otherCategories.isNotEmpty;
    final List<Category> otherDisplayCategories = showOtherCategories
        ? otherCategories
        : const <Category>[];
    _updateCategoryChipCache(
      headerCategories: headerCategories,
      otherCategories: otherDisplayCategories,
      selectedCategoryId: selectedCategoryId,
      showFavoritesInHeader: showFavoritesInHeader,
      showOtherCategories: showOtherCategories,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      padding: _kCategorySectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TransactionTypeSelector(
            key: const ValueKey<String>('transaction_type_selector'),
            formArgs: widget.formArgs,
            strings: strings,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: _transactionTextFieldDecoration(
              context,
              hintText: strings.addTransactionCategorySearchHint,
              fillColor: theme.colorScheme.surfaceContainerHigh,
              suffixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: otherCategories.isEmpty && favoriteCategories.isEmpty
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
            children: _headerChipWidgets,
          ),
          if (showOtherCategories) ...<Widget>[
            SizedBox(height: spacing.between),
            Wrap(
              spacing: spacing.between,
              runSpacing: spacing.between,
              children: _otherChipWidgets,
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
        borderRadius: BorderRadius.circular(context.kopimLayout.radius.xxl),
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }

  Widget _buildCategoryChip(Category category, String? selectedCategoryId) {
    final bool selected = category.id == selectedCategoryId;
    final IconData? iconData = resolvePhosphorIconData(category.icon);
    final Color? categoryColor = parseHexColor(category.color);
    final ThemeData theme = Theme.of(context);
    return CategoryChip(
      label: category.name,
      leading: Icon(iconData ?? Icons.category_outlined),
      iconBackgroundColor: categoryColor,
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      selected: selected,
      onTap: () => _selectCategory(category.id),
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
  const _AmountField({
    required this.formArgs,
    required this.strings,
    this.onAmountCommitted,
  });

  final TransactionFormArgs formArgs;
  final AppLocalizations strings;
  final ValueChanged<bool>? onAmountCommitted;

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
    _notifyAmountCommitted();
  }

  void _notifyAmountCommitted() {
    final bool isValid =
        ref
            .read(transactionFormControllerProvider(widget.formArgs))
            .parsedAmount !=
        null;
    widget.onAmountCommitted?.call(isValid);
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
      minLines: 2,
      maxLines: 2,
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
  });

  final String label;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: labelStyle);
  }
}

class _TypeSegmentItem extends StatelessWidget {
  const _TypeSegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedTextColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedTextColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle baseStyle =
        theme.textTheme.labelLarge ?? const TextStyle(fontSize: 16);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          scale: selected ? 1.0 : 0.95,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            style: baseStyle.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected
                  ? selectedTextColor
                  : theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            child: Text(label),
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
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(containerRadius),
      child: Padding(
        padding: _kDateTimeSectionPadding,
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
