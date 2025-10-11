import 'dart:collection';

import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';

class TransactionCommandResult<T> {
  TransactionCommandResult({
    required T value,
    List<ProfileDomainEvent> profileEvents = const <ProfileDomainEvent>[],
  }) : _value = value,
       _profileEvents = List<ProfileDomainEvent>.unmodifiable(profileEvents);

  final T _value;
  final List<ProfileDomainEvent> _profileEvents;

  T get value => _value;

  UnmodifiableListView<ProfileDomainEvent> get profileEvents =>
      UnmodifiableListView<ProfileDomainEvent>(_profileEvents);
}
