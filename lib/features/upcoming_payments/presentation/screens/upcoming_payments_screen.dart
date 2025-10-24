import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/edit_payment_reminder_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/edit_upcoming_payment_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/widgets/upcoming_list.dart';
import 'package:kopim/l10n/app_localizations.dart';

class UpcomingPaymentsScreen extends ConsumerStatefulWidget {
  const UpcomingPaymentsScreen({super.key});

  static const String routeName = '/upcoming-payments';

  @override
  ConsumerState<UpcomingPaymentsScreen> createState() =>
      _UpcomingPaymentsScreenState();
}

class _UpcomingPaymentsScreenState extends ConsumerState<UpcomingPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.upcomingPaymentsTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Tab>[
            Tab(text: strings.upcomingPaymentsTabPayments),
            Tab(text: strings.upcomingPaymentsTabReminders),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          UpcomingPaymentsList(onEdit: _openPayment),
          PaymentRemindersList(onEdit: _openReminder),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'upcomingPaymentsFab',
        onPressed: () => _showCreateMenu(context, strings),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateMenu(BuildContext context, AppLocalizations strings) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.event_repeat),
                title: Text(strings.upcomingPaymentsAddPayment),
                onTap: () {
                  Navigator.of(context).pop();
                  _createPayment();
                },
              ),
              ListTile(
                leading: const Icon(Icons.alarm_add),
                title: Text(strings.upcomingPaymentsAddReminder),
                onTap: () {
                  Navigator.of(context).pop();
                  _createReminder();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _createPayment() {
    const EditUpcomingPaymentScreenArgs args = EditUpcomingPaymentScreenArgs();
    context.push(args.location, extra: args);
  }

  void _createReminder() {
    const EditPaymentReminderScreenArgs args = EditPaymentReminderScreenArgs();
    context.push(args.location, extra: args);
  }

  void _openPayment(UpcomingPayment payment) {
    final EditUpcomingPaymentScreenArgs args = EditUpcomingPaymentScreenArgs(
      initialPayment: payment,
    );
    context.push(args.location, extra: args);
  }

  void _openReminder(PaymentReminder reminder) {
    final EditPaymentReminderScreenArgs args = EditPaymentReminderScreenArgs(
      initialReminder: reminder,
    );
    context.push(args.location, extra: args);
  }
}
