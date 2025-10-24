import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
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
  const EditPaymentReminderScreenArgs({this.reminderId, this.initialReminder});

  final String? reminderId;
  final PaymentReminder? initialReminder;

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _whenLocal;
  bool _appliedInitial = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _whenLocal = DateTime.now().add(const Duration(days: 1));
    if (widget.args.initialReminder != null) {
      _applyInitial(widget.args.initialReminder!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;

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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: strings.upcomingPaymentsFieldTitle,
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return strings.upcomingPaymentsValidationTitle;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: strings.upcomingPaymentsFieldAmount,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],
                      validator: (String? value) {
                        final double? parsed = _parseAmount(value);
                        if (parsed == null || parsed <= 0) {
                          return strings.upcomingPaymentsValidationAmount;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _DateField(
                      label: strings.upcomingPaymentsFieldReminderWhen,
                      selected: _whenLocal,
                      onSelect: _onSelectDate,
                      locale: strings.localeName,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: strings.upcomingPaymentsFieldNote,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _onSubmit(strings),
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
    if (!_formKey.currentState!.validate()) {
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
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.selected,
    required this.onSelect,
    required this.locale,
  });

  final String label;
  final DateTime selected;
  final VoidCallback onSelect;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat.yMMMMd(locale);
    final DateFormat timeFormat = DateFormat.Hm(locale);
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              dateFormat.format(selected),
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              timeFormat.format(selected),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
