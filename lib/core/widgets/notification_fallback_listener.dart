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
  ProviderSubscription<NotificationFallbackPresenter>? _presenterSubscription;
  ScaffoldMessengerState? _messenger;

  @override
  void initState() {
    super.initState();
    _listenPresenter();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _presenterSubscription?.close();
    super.dispose();
  }

  void _listenPresenter() {
    // Manually handle the initial subscription, which is what `fireImmediately: true`
    // used to accomplish.
    final NotificationFallbackPresenter initialPresenter = ref.read(
      notificationFallbackPresenterProvider,
    );
    _subscription = initialPresenter.events.listen(_handleEvent);

    // Then, listen for changes to the provider itself. If the presenter instance
    // is replaced, we cancel the old subscription and create a new one.
    _presenterSubscription = ref.listenManual<NotificationFallbackPresenter>(
      notificationFallbackPresenterProvider,
      (
        NotificationFallbackPresenter? previous,
        NotificationFallbackPresenter next,
      ) {
        _subscription?.cancel();
        _subscription = next.events.listen(_handleEvent);
      },
    );
  }

  void _handleEvent(NotificationFallbackEvent event) {
    final ScaffoldMessengerState? messenger =
        _messenger ?? ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ScaffoldMessengerState? postFrameMessenger =
            _messenger ?? ScaffoldMessenger.maybeOf(context);
        if (postFrameMessenger == null || !mounted) {
          return;
        }
        _showSnackBar(postFrameMessenger, event);
      });
      return;
    }
    _showSnackBar(messenger, event);
  }

  void _showSnackBar(
    ScaffoldMessengerState messenger,
    NotificationFallbackEvent event,
  ) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${event.title}: ${event.body}'),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    _messenger = ScaffoldMessenger.maybeOf(context);
    return widget.child ?? const SizedBox.shrink();
  }
}
