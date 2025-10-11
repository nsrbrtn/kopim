import 'dart:collection';

import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';

class ProfileCommandResult<T> {
  ProfileCommandResult({
    required T value,
    List<ProfileDomainEvent> events = const <ProfileDomainEvent>[],
  }) : _value = value,
       _events = List<ProfileDomainEvent>.unmodifiable(events);

  final T _value;
  final List<ProfileDomainEvent> _events;

  T get value => _value;

  UnmodifiableListView<ProfileDomainEvent> get events =>
      UnmodifiableListView<ProfileDomainEvent>(_events);

  ProfileCommandResult<T> copyWith({
    T? value,
    List<ProfileDomainEvent>? events,
  }) {
    return ProfileCommandResult<T>(
      value: value ?? _value,
      events: events ?? _events,
    );
  }
}
