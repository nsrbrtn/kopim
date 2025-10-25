import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/notification_fallback_presenter.dart';

class NotificationFallbackListener extends ConsumerStatefulWidget {
  const NotificationFallbackListener({super.key, this.child});

  final Widget? child;

  @override
  ConsumerState<NotificationFallbackListener> createState() =>
      _NotificationFallbackListenerState();
}

class _NotificationFallbackListenerState
    extends ConsumerState<NotificationFallbackListener> {
  StreamSubscription<NotificationFallbackEvent>? _subscription;
  ScaffoldMessengerState? _messenger;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribe() {
    final NotificationFallbackPresenter presenter = ref.read(
      notificationFallbackPresenterProvider,
    );
    _subscription = presenter.events.listen((NotificationFallbackEvent event) {
      final ScaffoldMessengerState? messenger = _messenger;
      if (messenger == null) {
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${event.title}: ${event.body}'),
            duration: const Duration(seconds: 4),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    _messenger = ScaffoldMessenger.maybeOf(context);
    return widget.child ?? const SizedBox.shrink();
  }
}
