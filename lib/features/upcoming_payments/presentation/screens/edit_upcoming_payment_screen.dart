import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
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
  const EditUpcomingPaymentScreenArgs({this.paymentId, this.initialPayment});

  final String? paymentId;
  final UpcomingPayment? initialPayment;
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _dayController;
  late final TextEditingController _notifyDaysController;
  late final TextEditingController _notifyTimeController;
  late final TextEditingController _noteController;

  bool _autoPost = true;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  bool _isSubmitting = false;
  bool _appliedInitial = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _dayController = TextEditingController(text: '1');
    _notifyDaysController = TextEditingController(text: '0');
    _notifyTimeController = TextEditingController(text: '09:00');
    _noteController = TextEditingController();
    if (widget.args.initialPayment != null) {
      _applyInitial(widget.args.initialPayment!);
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
    _selectedAccountId ??= accounts.first.id;
    _selectedCategoryId ??= categories.first.id;
    return SafeArea(
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
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.upcomingPaymentsValidationTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                  setState(() => _selectedAccountId = value);
                },
              ),
              const SizedBox(height: 16),
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
              TextFormField(
                controller: _dayController,
                decoration: InputDecoration(
                  labelText: strings.upcomingPaymentsFieldDayOfMonth,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (String? value) {
                  final int? day = int.tryParse(value ?? '');
                  if (day == null || day < 1 || day > 31) {
                    return strings.upcomingPaymentsValidationDay;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notifyDaysController,
                decoration: InputDecoration(
                  labelText: strings.upcomingPaymentsFieldNotifyDaysBefore,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (String? value) {
                  final int? days = int.tryParse(value ?? '');
                  if (days == null || days < 0) {
                    return strings.upcomingPaymentsValidationNotifyDays;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notifyTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: strings.upcomingPaymentsFieldNotifyTime,
                ),
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
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _autoPost,
                onChanged: (bool value) => setState(() => _autoPost = value),
                title: Text(strings.upcomingPaymentsFieldAutoPost),
              ),
              const SizedBox(height: 8),
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
      ),
    );
  }

  void _applyInitial(UpcomingPayment payment) {
    _titleController.text = payment.title;
    _amountController.text = payment.amount.abs().toStringAsFixed(2);
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final double amount = _parseAmount(_amountController.text)!;
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
            content: Text(strings.upcomingPaymentsSaveError(error.toString())),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _refreshSchedulers(
    UpcomingPayment payment,
    AnalyticsService analytics,
  ) async {
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
      'amount': payment.amount,
      'autoPost': payment.autoPost ? 1 : 0,
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
