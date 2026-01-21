import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/utils/platform_support.dart';
import 'package:kopim/core/utils/text_input_formatters.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/upcoming_payments/application/upcoming_notifications_controller.dart';
import 'package:kopim/features/upcoming_payments/data/services/upcoming_payments_work_scheduler.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/models/value_update.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/create_upcoming_payment_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/update_upcoming_payment_uc.dart';
import 'package:kopim/features/upcoming_payments/presentation/providers/upcoming_payment_lookup_providers.dart';
import 'package:kopim/features/upcoming_payments/presentation/providers/upcoming_payment_selection_providers.dart';
import 'package:kopim/l10n/app_localizations.dart';

class EditUpcomingPaymentScreenArgs {
  const EditUpcomingPaymentScreenArgs({
    this.paymentId,
    this.initialPayment,
    this.initialTitle,
    this.initialAmount,
    this.initialAccountId,
    this.initialCategoryId,
    this.initialDayOfMonth,
  });

  final String? paymentId;
  final UpcomingPayment? initialPayment;
  final String? initialTitle;
  final double? initialAmount;
  final String? initialAccountId;
  final String? initialCategoryId;
  final int? initialDayOfMonth;

  static EditUpcomingPaymentScreenArgs fromState(GoRouterState state) {
    final Object? extra = state.extra;
    if (extra is EditUpcomingPaymentScreenArgs) {
      return extra;
    }
    final String? paymentId = state.uri.queryParameters['paymentId'];
    return EditUpcomingPaymentScreenArgs(paymentId: paymentId);
  }

  String get location {
    final Map<String, String> params = <String, String>{};
    if (paymentId != null && paymentId!.isNotEmpty) {
      params['paymentId'] = paymentId!;
    }
    return Uri(
      path: EditUpcomingPaymentScreen.routeName,
      queryParameters: params.isEmpty ? null : params,
    ).toString();
  }
}

class EditUpcomingPaymentScreen extends ConsumerStatefulWidget {
  const EditUpcomingPaymentScreen({
    super.key,
    this.args = const EditUpcomingPaymentScreenArgs(),
  });

  static const String routeName = '/upcoming-payments/edit-payment';

  final EditUpcomingPaymentScreenArgs args;

  @override
  ConsumerState<EditUpcomingPaymentScreen> createState() =>
      _EditUpcomingPaymentScreenState();
}

class _EditUpcomingPaymentScreenState
    extends ConsumerState<EditUpcomingPaymentScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _dayController;
  late final TextEditingController _notifyDaysController;
  late final TextEditingController _notifyTimeController;
  late final TextEditingController _noteController;

  bool _autoPost = true;
  String? _selectedAccountId;
  int _selectedAccountScale = 2;
  String? _selectedCategoryId;
  bool _isSubmitting = false;
  bool _appliedInitial = false;
  bool _titleHasError = false;
  bool _amountHasError = false;
  bool _dayHasError = false;
  bool _notifyDaysHasError = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _dayController = TextEditingController();
    _notifyDaysController = TextEditingController();
    _notifyTimeController = TextEditingController();
    _noteController = TextEditingController();
    if (widget.args.initialPayment != null) {
      _applyInitial(widget.args.initialPayment!);
    } else if (widget.args.paymentId == null) {
      // Предзаполнение для нового платежа
      if (widget.args.initialTitle != null) {
        _titleController.text = widget.args.initialTitle!;
      }
      if (widget.args.initialAmount != null) {
        _amountController.text = widget.args.initialAmount!.toStringAsFixed(2);
      }
      if (widget.args.initialAccountId != null) {
        _selectedAccountId = widget.args.initialAccountId;
      }
      if (widget.args.initialCategoryId != null) {
        _selectedCategoryId = widget.args.initialCategoryId;
      }
      final DateTime now = DateTime.now();
      final int resolvedDay = widget.args.initialDayOfMonth ?? now.day;
      _dayController.text = resolvedDay.toString();
      _notifyDaysController.text = '1';
      _notifyTimeController.text = '10:00';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    _notifyDaysController.dispose();
    _notifyTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      upcomingPaymentAccountsProvider,
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      upcomingPaymentCategoriesProvider,
    );

    final AsyncValue<UpcomingPayment?> paymentAsync;
    if (widget.args.initialPayment != null || widget.args.paymentId == null) {
      paymentAsync = const AsyncValue<UpcomingPayment?>.data(null);
    } else {
      paymentAsync = ref.watch(
        upcomingPaymentByIdProvider(widget.args.paymentId!),
      );
    }

    return paymentAsync.when(
      data: (UpcomingPayment? loaded) {
        if (!_appliedInitial && loaded != null) {
          _applyInitial(loaded);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.args.initialPayment != null || loaded != null
                  ? strings.upcomingPaymentsEditPaymentTitle
                  : strings.upcomingPaymentsNewPaymentTitle,
            ),
          ),
          body: accountsAsync.when(
            data: (List<AccountEntity> accounts) {
              if (accounts.isEmpty) {
                return _buildMessage(
                  context,
                  strings.upcomingPaymentsNoAccounts,
                );
              }
              return categoriesAsync.when(
                data: (List<Category> categories) {
                  if (categories.isEmpty) {
                    return _buildMessage(
                      context,
                      strings.upcomingPaymentsNoCategories,
                    );
                  }
                  return _buildForm(
                    context: context,
                    theme: theme,
                    strings: strings,
                    accounts: accounts,
                    categories: categories,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, _) => _buildMessage(
                  context,
                  strings.upcomingPaymentsListError(error.toString()),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, _) => _buildMessage(
              context,
              strings.upcomingPaymentsListError(error.toString()),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (Object error, _) => Scaffold(
        appBar: AppBar(title: Text(strings.upcomingPaymentsEditPaymentTitle)),
        body: _buildMessage(
          context,
          strings.upcomingPaymentsListError(error.toString()),
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, String message) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildForm({
    required BuildContext context,
    required ThemeData theme,
    required AppLocalizations strings,
    required List<AccountEntity> accounts,
    required List<Category> categories,
  }) {
    _selectedAccountId ??= accounts
        .firstWhere(
          (AccountEntity a) => a.isPrimary,
          orElse: () => accounts.first,
        )
        .id;
    _syncSelectedAccountScale(accounts);
    _selectedCategoryId ??= categories.first.id;
    final ColorScheme colors = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _LabeledField(
              label: strings.upcomingPaymentsFieldTitle,
              theme: theme,
              colors: colors,
              layout: layout,
              errorText: _titleHasError
                  ? strings.upcomingPaymentsValidationTitle
                  : null,
              field: KopimTextField(
                controller: _titleController,
                placeholder: strings.upcomingPaymentsFieldTitle,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_titleHasError) {
                    setState(() => _titleHasError = false);
                  }
                },
                fillColor: colors.surfaceContainerHigh,
                placeholderColor: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: layout.spacing.section),
            DropdownButtonFormField<String>(
              initialValue: _selectedAccountId,
              items: accounts
                  .map(
                    (AccountEntity account) => DropdownMenuItem<String>(
                      value: account.id,
                      child: Text(account.name),
                    ),
                  )
                  .toList(growable: false),
              decoration: InputDecoration(
                labelText: strings.upcomingPaymentsFieldAccount,
              ),
              onChanged: (String? value) {
                setState(() {
                  _selectedAccountId = value;
                  _syncSelectedAccountScale(accounts);
                });
              },
            ),
            SizedBox(height: layout.spacing.section),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              items: categories
                  .map(
                    (Category category) => DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  )
                  .toList(growable: false),
              decoration: InputDecoration(
                labelText: strings.upcomingPaymentsFieldCategory,
              ),
              onChanged: (String? value) {
                setState(() => _selectedCategoryId = value);
              },
            ),
            SizedBox(height: layout.spacing.section),
            _LabeledField(
              label: strings.upcomingPaymentsFieldAmount,
              theme: theme,
              colors: colors,
              layout: layout,
              errorText: _amountHasError
                  ? strings.upcomingPaymentsValidationAmount
                  : null,
              field: KopimTextField(
                controller: _amountController,
                placeholder: strings.upcomingPaymentsFieldAmount,
                enabled: !_isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  digitsAndSeparatorsFormatter(),
                ],
                onChanged: (_) {
                  if (_amountHasError) {
                    setState(() => _amountHasError = false);
                  }
                },
                fillColor: colors.surfaceContainerHigh,
                placeholderColor: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: layout.spacing.section),
            _LabeledField(
              label: strings.upcomingPaymentsFieldDayOfMonth,
              theme: theme,
              colors: colors,
              layout: layout,
              errorText: _dayHasError
                  ? strings.upcomingPaymentsValidationDay
                  : null,
              field: KopimTextField(
                controller: _dayController,
                placeholder: strings.upcomingPaymentsFieldDayOfMonth,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) {
                  if (_dayHasError) {
                    setState(() => _dayHasError = false);
                  }
                },
                fillColor: colors.surfaceContainerHigh,
                placeholderColor: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: layout.spacing.section),
            _LabeledField(
              label: strings.upcomingPaymentsFieldNotifyDaysBefore,
              theme: theme,
              colors: colors,
              layout: layout,
              errorText: _notifyDaysHasError
                  ? strings.upcomingPaymentsValidationNotifyDays
                  : null,
              field: KopimTextField(
                controller: _notifyDaysController,
                placeholder: strings.upcomingPaymentsFieldNotifyDaysBefore,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) {
                  if (_notifyDaysHasError) {
                    setState(() => _notifyDaysHasError = false);
                  }
                },
                fillColor: colors.surfaceContainerHigh,
                placeholderColor: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: layout.spacing.section),
            _LabeledField(
              label: strings.upcomingPaymentsFieldNotifyTime,
              theme: theme,
              colors: colors,
              layout: layout,
              field: KopimTextField(
                controller: _notifyTimeController,
                placeholder: strings.upcomingPaymentsFieldNotifyTime,
                enabled: !_isSubmitting,
                readOnly: true,
                onTap: () async {
                  final TimeOfDay initialTime = _parseTime(
                    _notifyTimeController.text,
                  );
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                  );
                  if (picked != null) {
                    setState(() {
                      _notifyTimeController.text = _formatTime(picked);
                    });
                  }
                },
                fillColor: colors.surfaceContainerHigh,
                placeholderColor: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: layout.spacing.section),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _autoPost,
              onChanged: (bool value) => setState(() => _autoPost = value),
              title: Text(strings.upcomingPaymentsFieldAutoPost),
            ),
            SizedBox(height: layout.spacing.between),
            _LabeledField(
              label: strings.upcomingPaymentsFieldNote,
              theme: theme,
              colors: colors,
              layout: layout,
              field: KopimTextField(
                controller: _noteController,
                placeholder: strings.upcomingPaymentsFieldNote,
                enabled: !_isSubmitting,
                maxLines: 3,
                fillColor: colors.surfaceContainerHigh,
                placeholderColor: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: layout.spacing.sectionLarge),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : () => _onSubmit(strings),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(strings.upcomingPaymentsSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyInitial(UpcomingPayment payment) {
    _titleController.text = payment.title;
    _amountController.text = _formatAmountInput(payment.amountValue.abs());
    _dayController.text = payment.dayOfMonth.toString();
    _notifyDaysController.text = payment.notifyDaysBefore.toString();
    _notifyTimeController.text = payment.notifyTimeHhmm;
    _noteController.text = payment.note ?? '';
    _autoPost = payment.autoPost;
    _selectedAccountId = payment.accountId;
    _selectedCategoryId = payment.categoryId;
    _appliedInitial = true;
  }

  void _onSubmit(AppLocalizations strings) async {
    if (!_validateForm()) {
      return;
    }
    final MoneyAmount amount = _parseAmount(
      _amountController.text,
      _selectedAccountScale,
    )!;
    final int dayOfMonth = int.parse(_dayController.text);
    final int notifyDays = int.parse(_notifyDaysController.text);
    final String notifyTime = _notifyTimeController.text;
    final String? note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();
    final String accountId = _selectedAccountId!;
    final String categoryId = _selectedCategoryId!;

    setState(() => _isSubmitting = true);
    final AnalyticsService analytics = ref.read(analyticsServiceProvider);
    final LoggerService logger = ref.read(loggerServiceProvider);

    try {
      final bool isEditing =
          widget.args.initialPayment != null || widget.args.paymentId != null;
      UpcomingPayment result;
      if (isEditing) {
        final String id =
            widget.args.initialPayment?.id ?? widget.args.paymentId!;
        final UpdateUpcomingPaymentUC updateUc = ref.read(
          updateUpcomingPaymentUCProvider,
        );
        result = await updateUc(
          UpdateUpcomingPaymentInput(
            id: id,
            title: _titleController.text.trim(),
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            dayOfMonth: dayOfMonth,
            notifyDaysBefore: notifyDays,
            notifyTimeHhmm: notifyTime,
            note: ValueUpdate<String?>.present(note),
            autoPost: _autoPost,
          ),
        );
        await analytics.logEvent(
          'upcoming_payment_updated',
          _buildAnalyticsPayload(result, success: true),
        );
      } else {
        final CreateUpcomingPaymentUC createUc = ref.read(
          createUpcomingPaymentUCProvider,
        );
        result = await createUc(
          CreateUpcomingPaymentInput(
            title: _titleController.text.trim(),
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            dayOfMonth: dayOfMonth,
            notifyDaysBefore: notifyDays,
            notifyTimeHhmm: notifyTime,
            note: note,
            autoPost: _autoPost,
          ),
        );
        await analytics.logEvent(
          'upcoming_payment_created',
          _buildAnalyticsPayload(result, success: true),
        );
      }

      await _refreshSchedulers(result, analytics);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(
              '${strings.upcomingPaymentsSaveSuccess}\n${strings.upcomingPaymentsScheduleTriggered}',
            ),
          ),
        );
      Navigator.of(context).pop(result);
    } catch (error, stackTrace) {
      logger.logError('Failed to save upcoming payment', error);
      analytics.reportError(error, stackTrace);
      final bool isEditing =
          widget.args.initialPayment != null || widget.args.paymentId != null;
      final String eventName = isEditing
          ? 'upcoming_payment_updated'
          : 'upcoming_payment_created';
      await analytics.logEvent(eventName, <String, dynamic>{
        'result': 'error',
        'message': error.toString(),
        if (_selectedAccountId != null)
          'account': _shortId(_selectedAccountId!),
        if (_selectedCategoryId != null)
          'category': _shortId(_selectedCategoryId!),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(strings.upcomingPaymentsSaveError(error.toString())),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _validateForm() {
    final bool titleValid = _titleController.text.trim().isNotEmpty;
    final MoneyAmount? parsedAmount = _parseAmount(
      _amountController.text,
      _selectedAccountScale,
    );
    final bool amountValid =
        parsedAmount != null && parsedAmount.minor > BigInt.zero;
    final int? day = int.tryParse(_dayController.text);
    final bool dayValid = day != null && day >= 1 && day <= 31;
    final int? notifyDays = int.tryParse(_notifyDaysController.text);
    final bool notifyDaysValid = notifyDays != null && notifyDays >= 0;
    setState(() {
      _titleHasError = !titleValid;
      _amountHasError = !amountValid;
      _dayHasError = !dayValid;
      _notifyDaysHasError = !notifyDaysValid;
    });
    return titleValid && amountValid && dayValid && notifyDaysValid;
  }

  Future<void> _refreshSchedulers(
    UpcomingPayment payment,
    AnalyticsService analytics,
  ) async {
    if (!supportsUpcomingPaymentsBackgroundWork()) {
      return;
    }
    ref.invalidate(upcomingNotificationsControllerProvider);
    final UpcomingPaymentsWorkScheduler scheduler = ref.read(
      upcomingPaymentsWorkSchedulerProvider,
    );
    await scheduler.triggerOneOffCatchUp();
    await analytics.logEvent('notification_scheduled', <String, dynamic>{
      'source': 'upcoming_payment_form',
      'type': 'payment',
      'id': _shortId(payment.id),
    });
  }

  Map<String, dynamic> _buildAnalyticsPayload(
    UpcomingPayment payment, {
    required bool success,
  }) {
    return <String, dynamic>{
      'id': _shortId(payment.id),
      'account': _shortId(payment.accountId),
      'category': _shortId(payment.categoryId),
      'amount': payment.amountValue.toDouble(),
      'autoPost': payment.autoPost ? 1 : 0,
      'result': success ? 'success' : 'error',
    };
  }

  MoneyAmount? _parseAmount(String? value, int scale) {
    if (value == null) {
      return null;
    }
    final String normalized = value.replaceAll(',', '.');
    return tryParseMoneyAmount(input: normalized, scale: scale);
  }

  String _formatAmountInput(MoneyAmount amount) {
    final Money money = Money(
      minor: amount.minor,
      currency: 'XXX',
      scale: amount.scale,
    );
    return money.toDecimalString();
  }

  void _syncSelectedAccountScale(List<AccountEntity> accounts) {
    final String? accountId = _selectedAccountId;
    final AccountEntity? account = accountId == null
        ? null
        : accounts.firstWhere(
            (AccountEntity item) => item.id == accountId,
            orElse: () => accounts.first,
          );
    _selectedAccountScale = account?.currencyScale ?? 2;
  }

  TimeOfDay _parseTime(String value) {
    final List<String> parts = value.split(':');
    if (parts.length != 2) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
    final int hour = int.tryParse(parts[0]) ?? 9;
    final int minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final NumberFormat formatter = NumberFormat('00');
    return '${formatter.format(time.hour)}:${formatter.format(time.minute)}';
  }

  String _shortId(String value) {
    return value.length <= 8 ? value : value.substring(0, 8);
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.field,
    required this.theme,
    required this.colors,
    required this.layout,
    this.errorText,
  });

  final String label;
  final Widget field;
  final ThemeData theme;
  final ColorScheme colors;
  final KopimLayout layout;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(color: colors.onSurface),
        ),
        SizedBox(height: layout.spacing.between),
        field,
        if (errorText != null) ...<Widget>[
          SizedBox(height: layout.spacing.between),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }
}
