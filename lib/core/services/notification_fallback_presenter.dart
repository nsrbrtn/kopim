import 'dart:async';

/// Событие веб-фолбэка уведомления, содержащее базовые данные для UI.
class NotificationFallbackEvent {
  const NotificationFallbackEvent({required this.title, required this.body});

  final String title;
  final String body;
}

/// Контракт для показа фолбэк-уведомлений (баннер/Toast).
abstract class NotificationFallbackPresenter {
  Stream<NotificationFallbackEvent> get events;

  void show(NotificationFallbackEvent event);

  void dispose();
}

/// Потоковый презентер, который отправляет события слушателям.
class StreamNotificationFallbackPresenter
    implements NotificationFallbackPresenter {
  StreamNotificationFallbackPresenter()
    : _controller = StreamController<NotificationFallbackEvent>.broadcast(
        sync: true,
      );

  final StreamController<NotificationFallbackEvent> _controller;

  @override
  Stream<NotificationFallbackEvent> get events => _controller.stream;

  @override
  void show(NotificationFallbackEvent event) {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(event);
  }

  @override
  void dispose() {
    if (_controller.isClosed) {
      return;
    }
    _controller.close();
  }
}

/// Презентер-заглушка, который игнорирует запросы на показ уведомлений.
class NullNotificationFallbackPresenter
    implements NotificationFallbackPresenter {
  const NullNotificationFallbackPresenter();

  @override
  Stream<NotificationFallbackEvent> get events =>
      const Stream<NotificationFallbackEvent>.empty();

  @override
  void dispose() {
    // Ничего не делаем — фолбэк не требуется.
  }

  @override
  void show(NotificationFallbackEvent event) {
    // Игнорируем событие.
  }
}
