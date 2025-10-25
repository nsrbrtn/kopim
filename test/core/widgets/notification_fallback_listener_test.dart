// ignore_for_file: always_specify_types
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/notification_fallback_presenter.dart';
import 'package:kopim/core/widgets/notification_fallback_listener.dart';

void main() {
  testWidgets('shows SnackBar when fallback event arrives', (
    WidgetTester tester,
  ) async {
    final StreamNotificationFallbackPresenter presenter =
        StreamNotificationFallbackPresenter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationFallbackPresenterProvider.overrideWithValue(presenter),
        ],
        child: const MaterialApp(
          home: NotificationFallbackListener(child: Scaffold(body: SizedBox())),
        ),
      ),
    );

    presenter.show(
      const NotificationFallbackEvent(title: 'Reminder', body: 'Test body'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Reminder: Test body'), findsOneWidget);
  });
}
