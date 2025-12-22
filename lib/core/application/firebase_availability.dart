import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class FirebaseAvailabilityState {
  const FirebaseAvailabilityState._(this.isAvailable, this.warningMessage);

  const FirebaseAvailabilityState.available()
    : this._(true, null);

  const FirebaseAvailabilityState.unavailable(String warningMessage)
    : this._(false, warningMessage);

  const FirebaseAvailabilityState.unknown()
    : this._(null, null);

  final bool? isAvailable;
  final String? warningMessage;
}

class FirebaseAvailabilityNotifier
    extends Notifier<FirebaseAvailabilityState> {
  @override
  FirebaseAvailabilityState build() =>
      const FirebaseAvailabilityState.unknown();

  void setUnknown() {
    state = const FirebaseAvailabilityState.unknown();
  }

  void setAvailable() {
    state = const FirebaseAvailabilityState.available();
  }

  void setUnavailable(String warningMessage) {
    state = FirebaseAvailabilityState.unavailable(warningMessage);
  }
}

final NotifierProvider<FirebaseAvailabilityNotifier, FirebaseAvailabilityState>
    firebaseAvailabilityProvider =
    NotifierProvider<FirebaseAvailabilityNotifier, FirebaseAvailabilityState>(
      FirebaseAvailabilityNotifier.new,
    );
