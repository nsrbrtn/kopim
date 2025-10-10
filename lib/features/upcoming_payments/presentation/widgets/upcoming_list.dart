import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/presentation/providers/upcoming_payment_selection_providers.dart';
import 'package:kopim/features/upcoming_payments/presentation/widgets/empty_state.dart';
import 'package:kopim/features/upcoming_payments/presentation/widgets/reminder_list_item.dart';
import 'package:kopim/features/upcoming_payments/presentation/widgets/upcoming_list_item.dart';
import 'package:kopim/l10n/app_localizations.dart';

class UpcomingPaymentsList extends ConsumerWidget {
  const UpcomingPaymentsList({super.key, required this.onEdit});

  final void Function(UpcomingPayment payment) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<UpcomingPayment>> paymentsAsync = ref.watch(
      watchUpcomingPaymentsProvider,
    );
    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      upcomingPaymentAccountsProvider,
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      upcomingPaymentCategoriesProvider,
    );
    final TimeService timeService = ref.watch(timeServiceProvider);
    final AppLocalizations strings = AppLocalizations.of(context)!;

    if (accountsAsync.isLoading || categoriesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (accountsAsync.hasError || categoriesAsync.hasError) {
      final Object? error = accountsAsync.error ?? categoriesAsync.error;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(strings.upcomingPaymentsListError(error.toString())),
        ),
      );
    }

    final Map<String, AccountEntity> accounts = <String, AccountEntity>{
      for (final AccountEntity account
          in accountsAsync.value ?? const <AccountEntity>[])
        account.id: account,
    };
    final Map<String, Category> categories = <String, Category>{
      for (final Category category
          in categoriesAsync.value ?? const <Category>[])
        category.id: category,
    };

    return paymentsAsync.when(
      data: (List<UpcomingPayment> payments) {
        if (payments.isEmpty) {
          return UpcomingEmptyState(
            icon: Icons.event_repeat,
            title: strings.upcomingPaymentsEmptyPaymentsTitle,
            message: strings.upcomingPaymentsEmptyPaymentsDescription,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: payments.length,
          itemBuilder: (BuildContext context, int index) {
            final UpcomingPayment payment = payments[index];
            return UpcomingPaymentListItem(
              payment: payment,
              accounts: accounts,
              categories: categories,
              timeService: timeService,
              onTap: () => onEdit(payment),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(strings.upcomingPaymentsListError(error.toString())),
        ),
      ),
    );
  }
}

class PaymentRemindersList extends ConsumerWidget {
  const PaymentRemindersList({super.key, required this.onEdit});

  final void Function(PaymentReminder reminder) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PaymentReminder>> remindersAsync = ref.watch(
      watchPaymentRemindersProvider(limit: null),
    );
    final TimeService timeService = ref.watch(timeServiceProvider);
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return remindersAsync.when(
      data: (List<PaymentReminder> reminders) {
        if (reminders.isEmpty) {
          return UpcomingEmptyState(
            icon: Icons.alarm,
            title: strings.upcomingPaymentsEmptyRemindersTitle,
            message: strings.upcomingPaymentsEmptyRemindersDescription,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: reminders.length,
          itemBuilder: (BuildContext context, int index) {
            final PaymentReminder reminder = reminders[index];
            return ReminderListItem(
              reminder: reminder,
              timeService: timeService,
              onTap: () => onEdit(reminder),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(strings.upcomingPaymentsListError(error.toString())),
        ),
      ),
    );
  }
}
