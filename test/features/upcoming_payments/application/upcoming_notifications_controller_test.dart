import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/src/framework.dart' show Override;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notifications_gateway.dart';
import 'package:kopim/features/upcoming_payments/application/upcoming_notifications_controller.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/mark_reminder_done_uc.dart';

class _MockNotificationsGateway extends Mock implements NotificationsGateway {}

class _MockLoggerService extends Mock implements LoggerService {}

class _MockMarkReminderDoneUC extends Mock implements MarkReminderDoneUC {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(
      const MarkReminderDoneInput(id: 'fallback', isDone: true),
    );
    registerFallbackValue(tz.TZDateTime.utc(2024));
    registerFallbackValue(<AndroidNotificationAction>[]);
  });

  late ProviderContainer container;
  late _MockNotificationsGateway notifications;
  late _MockLoggerService logger;
  late _MockMarkReminderDoneUC markReminderDone;
  late StreamController<NotificationResponse> responses;

  setUp(() {
    notifications = _MockNotificationsGateway();
    logger = _MockLoggerService();
    markReminderDone = _MockMarkReminderDoneUC();
    responses = StreamController<NotificationResponse>.broadcast();

    when(() => notifications.responses).thenAnswer((_) => responses.stream);
    when(() => notifications.ensurePermission()).thenAnswer((_) async {});
    when(
      () => notifications.scheduleAt(
        id: any<int>(named: 'id'),
        when: any<tz.TZDateTime>(named: 'when'),
        title: any<String>(named: 'title'),
        body: any<String>(named: 'body'),
        payload: any<String?>(named: 'payload'),
        androidActions: any<List<AndroidNotificationAction>?>(
          named: 'androidActions',
        ),
      ),
    ).thenAnswer((_) async {});
    when(() => notifications.cancel(any())).thenAnswer((_) async {});
    when(() => notifications.cancelAll()).thenAnswer((_) async {});

    when(() => logger.logInfo(any())).thenReturn(null);
    when(() => logger.logError(any(), any())).thenReturn(null);

    final PaymentReminder reminder = PaymentReminder(
      id: 'rem-1',
      title: 'Pay the bill',
      amount: 500,
      whenAtMs: DateTime.now()
          .add(const Duration(days: 1))
          .millisecondsSinceEpoch,
      note: null,
      isDone: false,
      lastNotifiedAtMs: null,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    when(() => markReminderDone.call(any())).thenAnswer(
      (_) async => reminder.copyWith(
        isDone: true,
        updatedAtMs: reminder.updatedAtMs + 1,
      ),
    );

    container = ProviderContainer(
      overrides: <Override>[
        notificationsGatewayProvider.overrideWithValue(notifications),
        loggerServiceProvider.overrideWithValue(logger),
        markReminderDoneUCProvider.overrideWithValue(markReminderDone),
        watchUpcomingPaymentsProvider.overrideWith(
          (Ref ref) => Stream<List<UpcomingPayment>>.value(<UpcomingPayment>[]),
        ),
        watchPaymentRemindersProvider.overrideWith(
          (Ref ref, int? limit) =>
              Stream<List<PaymentReminder>>.value(<PaymentReminder>[reminder]),
        ),
        appLocaleProvider.overrideWithValue(const Locale('en')),
      ],
    );
  });

  tearDown(() async {
    await responses.close();
    await pumpEventQueue();
    container.dispose();
  });

  test('marks reminder done when notification action received', () async {
    await container.read(upcomingNotificationsControllerProvider.future);
    final UpcomingNotificationsController controller = container.read(
      upcomingNotificationsControllerProvider.notifier,
    );

    const NotificationResponse response = NotificationResponse(
      notificationResponseType:
          NotificationResponseType.selectedNotificationAction,
      actionId: NotificationsGateway.actionMarkReminderPaid,
      payload: 'reminder:rem-1',
    );

    await controller.handleNotificationResponse(response);

    verify(
      () => markReminderDone.call(
        const MarkReminderDoneInput(id: 'rem-1', isDone: true),
      ),
    ).called(1);
  });

  test('ignores responses for other actions', () async {
    await container.read(upcomingNotificationsControllerProvider.future);
    final UpcomingNotificationsController controller = container.read(
      upcomingNotificationsControllerProvider.notifier,
    );

    const NotificationResponse response = NotificationResponse(
      notificationResponseType:
          NotificationResponseType.selectedNotificationAction,
      actionId: 'other_action',
      payload: 'reminder:rem-1',
    );

    await controller.handleNotificationResponse(response);

    verifyNever(() => markReminderDone.call(any()));
  });
}
