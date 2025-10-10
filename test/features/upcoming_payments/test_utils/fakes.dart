import 'dart:async';

import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/id_service.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';

class FixedTimeService implements TimeService {
  FixedTimeService(DateTime initial) : _state = _MutableDateTime(initial);

  final _MutableDateTime _state;

  set now(DateTime value) => _state.value = value;

  DateTime get _current => _state.value;

  @override
  int nowMs() => _current.toUtc().millisecondsSinceEpoch;

  @override
  DateTime nowLocal() => _current;

  @override
  DateTime toLocal(int epochMs) {
    return DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toLocal();
  }

  @override
  int toEpochMs(DateTime dt) => dt.toUtc().millisecondsSinceEpoch;

  @override
  DateTime atLocalDateTime(int year, int month, int day, int hour, int minute) {
    return DateTime(year, month, day, hour, minute);
  }

  @override
  int parseHhmmToMinutes(String hhmm) {
    return const SystemTimeService().parseHhmmToMinutes(hhmm);
  }
}

class _MutableDateTime {
  _MutableDateTime(this.value);

  DateTime value;
}

class TestIdService implements IdService {
  TestIdService({Iterable<String> values = const <String>[]})
    : _queue = List<String>.of(values);

  final List<String> _queue;
  int _counter = 0;

  @override
  String generate() {
    if (_queue.isNotEmpty) {
      return _queue.removeAt(0);
    }
    _counter += 1;
    return 'test-id-$_counter';
  }
}

class InMemoryUpcomingPaymentsRepository implements UpcomingPaymentsRepository {
  final Map<String, UpcomingPayment> _store = <String, UpcomingPayment>{};
  final StreamController<List<UpcomingPayment>> _controller =
      StreamController<List<UpcomingPayment>>.broadcast();

  void dispose() {
    _controller.close();
  }

  void emitAll(Iterable<UpcomingPayment> payments) {
    _store
      ..clear()
      ..addEntries(
        payments.map(
          (UpcomingPayment payment) =>
              MapEntry<String, UpcomingPayment>(payment.id, payment),
        ),
      );
    _notify();
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
    _notify();
  }

  @override
  Future<UpcomingPayment?> getById(String id) async => _store[id];

  @override
  Future<void> upsert(UpcomingPayment payment) async {
    _store[payment.id] = payment;
    _notify();
  }

  @override
  Stream<List<UpcomingPayment>> watchAll() {
    return Stream<List<UpcomingPayment>>.multi((
      StreamController<List<UpcomingPayment>> controller,
    ) {
      controller.add(_snapshot());
      final StreamSubscription<List<UpcomingPayment>> sub = _controller.stream
          .listen(
            controller.add,
            onError: controller.addError,
            onDone: controller.close,
          );
      controller.onCancel = sub.cancel;
    });
  }

  List<UpcomingPayment> _snapshot() {
    return List<UpcomingPayment>.unmodifiable(_store.values);
  }

  void _notify() {
    if (!_controller.isClosed) {
      _controller.add(_snapshot());
    }
  }
}

class InMemoryPaymentRemindersRepository implements PaymentRemindersRepository {
  final Map<String, PaymentReminder> _store = <String, PaymentReminder>{};
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  void dispose() {
    _changes.close();
  }

  void emitAll(Iterable<PaymentReminder> reminders) {
    _store
      ..clear()
      ..addEntries(
        reminders.map(
          (PaymentReminder reminder) =>
              MapEntry<String, PaymentReminder>(reminder.id, reminder),
        ),
      );
    _changes.add(null);
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
    _changes.add(null);
  }

  @override
  Future<PaymentReminder?> getById(String id) async => _store[id];

  @override
  Future<void> upsert(PaymentReminder reminder) async {
    _store[reminder.id] = reminder;
    _changes.add(null);
  }

  @override
  Stream<List<PaymentReminder>> watchAll() {
    return Stream<List<PaymentReminder>>.multi((
      StreamController<List<PaymentReminder>> controller,
    ) {
      controller.add(_store.values.toList(growable: false));
      final StreamSubscription<void> sub = _changes.stream.listen(
        (_) => controller.add(_store.values.toList(growable: false)),
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = sub.cancel;
    });
  }

  @override
  Stream<List<PaymentReminder>> watchUpcoming({int? limit}) {
    return Stream<List<PaymentReminder>>.multi((
      StreamController<List<PaymentReminder>> controller,
    ) {
      controller.add(_upcoming(limit));
      final StreamSubscription<void> sub = _changes.stream.listen(
        (_) => controller.add(_upcoming(limit)),
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = sub.cancel;
    });
  }

  List<PaymentReminder> _upcoming(int? limit) {
    final List<PaymentReminder> reminders =
        _store.values
            .where((PaymentReminder reminder) => !reminder.isDone)
            .toList(growable: false)
          ..sort(
            (PaymentReminder a, PaymentReminder b) =>
                a.whenAtMs.compareTo(b.whenAtMs),
          );
    if (limit != null && reminders.length > limit) {
      return List<PaymentReminder>.unmodifiable(reminders.take(limit));
    }
    return List<PaymentReminder>.unmodifiable(reminders);
  }
}
