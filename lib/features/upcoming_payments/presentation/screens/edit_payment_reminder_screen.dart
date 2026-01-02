import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/utils/text_input_formatters.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/upcoming_payments/application/upcoming_notifications_controller.dart';
import 'package:kopim/features/upcoming_payments/data/services/upcoming_payments_work_scheduler.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/create_payment_reminder_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/update_payment_reminder_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/models/value_update.dart';
import 'package:kopim/features/upcoming_payments/presentation/providers/upcoming_payment_lookup_providers.dart';
import 'package:kopim/l10n/app_localizations.dart';

class EditPaymentReminderScreenArgs {
  const EditPaymentReminderScreenArgs({
    this.reminderId,
    this.initialReminder,
    this.initialTitle,
    this.initialAmount,
    this.initialWhenLocal,
    this.initialNote,
  });

  final String? reminderId;
  final PaymentReminder? initialReminder;
  final String? initialTitle;
  final double? initialAmount;
  final DateTime? initialWhenLocal;
  final String? initialNote;

  bool get hasInitialData =>
      initialTitle != null ||
      initialAmount != null ||
      initialWhenLocal != null ||
      initialNote != null;

  static EditPaymentReminderScreenArgs fromState(GoRouterState state) {
    final Object? extra = state.extra;
    if (extra is EditPaymentReminderScreenArgs) {
      return extra;
    }
    final String? reminderId = state.uri.queryParameters['reminderId'];
    return EditPaymentReminderScreenArgs(reminderId: reminderId);
  }

  String get location {
    final Map<String, String> params = <String, String>{};
    if (reminderId != null && reminderId!.isNotEmpty) {
      params['reminderId'] = reminderId!;
    }
    return Uri(
      path: EditPaymentReminderScreen.routeName,
      queryParameters: params.isEmpty ? null : params,
    ).toString();
  }
}

class EditPaymentReminderScreen extends ConsumerStatefulWidget {
  const EditPaymentReminderScreen({
    super.key,
    this.args = const EditPaymentReminderScreenArgs(),
  });

  static const String routeName = '/upcoming-payments/edit-reminder';

  final EditPaymentReminderScreenArgs args;

  @override
  ConsumerState<EditPaymentReminderScreen> createState() =>
      _EditPaymentReminderScreenState();
}

class _EditPaymentReminderScreenState
    extends ConsumerState<EditPaymentReminderScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _whenController;
  late DateTime _whenLocal;
  bool _appliedInitial = false;
  bool _isSubmitting = false;
  bool _titleHasError = false;
  bool _amountHasError = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _whenController = TextEditingController();
    _whenLocal = DateTime.now().add(const Duration(days: 1));
    if (widget.args.initialReminder != null) {
      _applyInitial(widget.args.initialReminder!);
    } else if (widget.args.hasInitialData) {
      _applyInitialFromArgs(widget.args);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _whenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;

    _syncWhenController(strings.localeName);

    final AsyncValue<PaymentReminder?> reminderAsync;
    if (widget.args.initialReminder != null || widget.args.reminderId == null) {
      reminderAsync = const AsyncValue<PaymentReminder?>.data(null);
    } else {
      reminderAsync = ref.watch(
        paymentReminderByIdProvider(widget.args.reminderId!),
      );
    }

    return reminderAsync.when(
      data: (PaymentReminder? loaded) {
        if (!_appliedInitial && loaded != null) {
          _applyInitial(loaded);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.args.initialReminder != null || loaded != null
                  ? strings.upcomingPaymentsEditReminderTitle
                  : strings.upcomingPaymentsNewReminderTitle,
            ),
          ),
          body: SafeArea(
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
                    errorText:
                        _titleHasError
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
                  _LabeledField(
                    label: strings.upcomingPaymentsFieldAmount,
                    theme: theme,
                    colors: colors,
                    layout: layout,
                    errorText:
                        _amountHasError
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
                    label: strings.upcomingPaymentsFieldReminderWhen,
                    theme: theme,
                    colors: colors,
                    layout: layout,
                    field: KopimTextField(
                      controller: _whenController,
                      placeholder: strings.upcomingPaymentsFieldReminderWhen,
                      enabled: !_isSubmitting,
                      readOnly: true,
                      onTap: _onSelectDate,
                      fillColor: colors.surfaceContainerHigh,
                      placeholderColor: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: layout.spacing.section),
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
                      onPressed:
                          _isSubmitting ? null : () => _onSubmit(strings),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(strings.upcomingPaymentsSubmit),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (Object error, _) => Scaffold(
        appBar: AppBar(title: Text(strings.upcomingPaymentsEditReminderTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              strings.upcomingPaymentsReminderSaveError(error.toString()),
            ),
          ),
        ),
      ),
    );
  }

  void _applyInitial(PaymentReminder reminder) {
    _titleController.text = reminder.title;
    _amountController.text = reminder.amount.abs().toStringAsFixed(2);
    _noteController.text = reminder.note ?? '';
    _whenLocal = ref.read(timeServiceProvider).toLocal(reminder.whenAtMs);
    _appliedInitial = true;
  }

  void _applyInitialFromArgs(EditPaymentReminderScreenArgs args) {
    if (args.initialTitle != null) {
      _titleController.text = args.initialTitle!;
    }
    if (args.initialAmount != null) {
      _amountController.text = args.initialAmount!.toStringAsFixed(2);
    }
    if (args.initialNote != null) {
      _noteController.text = args.initialNote!;
    }
    if (args.initialWhenLocal != null) {
      _whenLocal = args.initialWhenLocal!;
    }
    _appliedInitial = true;
  }

  void _onSelectDate() async {
    final DateTime initialDateTime = _whenLocal;
    final DateTime initialDate = DateTime(
      initialDateTime.year,
      initialDateTime.month,
      initialDateTime.day,
    );
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime fallbackFirstDate = today.subtract(const Duration(days: 1));
    final DateTime firstDate = initialDate.isBefore(fallbackFirstDate)
        ? initialDate
        : fallbackFirstDate;
    final DateTime maxAllowedDate = today.add(const Duration(days: 365 * 5));
    final DateTime lastDate = initialDate.isAfter(maxAllowedDate)
        ? initialDate
        : maxAllowedDate;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    final TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _whenLocal = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _onSubmit(AppLocalizations strings) async {
    if (!_validateForm()) {
      return;
    }
    final double amount = _parseAmount(_amountController.text)!;
    final String? note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    setState(() => _isSubmitting = true);

    final AnalyticsService analytics = ref.read(analyticsServiceProvider);
    final LoggerService logger = ref.read(loggerServiceProvider);

    try {
      final bool isEditing =
          widget.args.initialReminder != null || widget.args.reminderId != null;
      PaymentReminder result;
      if (isEditing) {
        final String id =
            widget.args.initialReminder?.id ?? widget.args.reminderId!;
        final UpdatePaymentReminderUC updateUc = ref.read(
          updatePaymentReminderUCProvider,
        );
        result = await updateUc(
          UpdatePaymentReminderInput(
            id: id,
            title: _titleController.text.trim(),
            amount: amount,
            whenLocal: _whenLocal,
            note: ValueUpdate<String?>.present(note),
          ),
        );
        await analytics.logEvent(
          'reminder_updated',
          _buildAnalyticsPayload(result, success: true),
        );
      } else {
        final CreatePaymentReminderUC createUc = ref.read(
          createPaymentReminderUCProvider,
        );
        result = await createUc(
          CreatePaymentReminderInput(
            title: _titleController.text.trim(),
            amount: amount,
            whenLocal: _whenLocal,
            note: note,
          ),
        );
        await analytics.logEvent(
          'reminder_created',
          _buildAnalyticsPayload(result, success: true),
        );
      }

      await _refreshSchedulers(result, analytics);

      if (!mounted) return;
      final String message = widget.args.initialReminder != null
          ? strings.upcomingPaymentsReminderSaveSuccess
          : strings.upcomingPaymentsReminderSaveSuccess;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '$message\n${strings.upcomingPaymentsScheduleTriggered}',
            ),
          ),
        );
      Navigator.of(context).pop(result);
    } catch (error, stackTrace) {
      logger.logError('Failed to save payment reminder', error);
      analytics.reportError(error, stackTrace);
      final bool isEditing =
          widget.args.initialReminder != null || widget.args.reminderId != null;
      final String eventName = isEditing
          ? 'reminder_updated'
          : 'reminder_created';
      await analytics.logEvent(eventName, <String, dynamic>{
        'result': 'error',
        'message': error.toString(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              strings.upcomingPaymentsReminderSaveError(error.toString()),
            ),
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
    final double? parsedAmount = _parseAmount(_amountController.text);
    final bool amountValid = parsedAmount != null && parsedAmount > 0;
    setState(() {
      _titleHasError = !titleValid;
      _amountHasError = !amountValid;
    });
    return titleValid && amountValid;
  }

  Future<void> _refreshSchedulers(
    PaymentReminder reminder,
    AnalyticsService analytics,
  ) async {
    ref.invalidate(upcomingNotificationsControllerProvider);
    final UpcomingPaymentsWorkScheduler scheduler = ref.read(
      upcomingPaymentsWorkSchedulerProvider,
    );
    await scheduler.triggerOneOffCatchUp();
    await analytics.logEvent('notification_scheduled', <String, dynamic>{
      'source': 'payment_reminder_form',
      'type': 'reminder',
      'id': _shortId(reminder.id),
    });
  }

  Map<String, dynamic> _buildAnalyticsPayload(
    PaymentReminder reminder, {
    required bool success,
  }) {
    return <String, dynamic>{
      'id': _shortId(reminder.id),
      'amount': reminder.amount,
      'isDone': reminder.isDone ? 1 : 0,
      'result': success ? 'success' : 'error',
    };
  }

  double? _parseAmount(String? value) {
    if (value == null) {
      return null;
    }
    final String normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String _shortId(String value) {
    return value.length <= 8 ? value : value.substring(0, 8);
  }

  void _syncWhenController(String locale) {
    final String formatted = _formatWhenLocal(_whenLocal, locale);
    if (_whenController.text != formatted) {
      _whenController.text = formatted;
    }
  }

  String _formatWhenLocal(DateTime value, String locale) {
    final DateFormat dateFormat = DateFormat.yMMMMd(locale);
    final DateFormat timeFormat = DateFormat.Hm(locale);
    return '${dateFormat.format(value)} - ${timeFormat.format(value)}';
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
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.onSurface,
          ),
        ),
        SizedBox(height: layout.spacing.between),
        field,
        if (errorText != null) ...<Widget>[
          SizedBox(height: layout.spacing.between),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.error,
            ),
          ),
        ],
      ],
    );
  }
}
