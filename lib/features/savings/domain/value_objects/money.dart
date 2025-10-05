import 'dart:math';

import 'package:equatable/equatable.dart';

class Money extends Equatable {
  const Money._(this.minorUnits);

  factory Money.fromMinorUnits(int value) {
    return Money._(max(0, value));
  }

  factory Money.fromDouble(double value, {int fractionDigits = 2}) {
    final int factor = pow(10, fractionDigits).toInt();
    final int minor = (value * factor).round();
    return Money.fromMinorUnits(minor);
  }

  final int minorUnits;

  double toDouble({int fractionDigits = 2}) {
    final int factor = pow(10, fractionDigits).toInt();
    return minorUnits / factor;
  }

  Money operator +(Money other) =>
      Money.fromMinorUnits(minorUnits + other.minorUnits);

  Money operator -(Money other) =>
      Money.fromMinorUnits(minorUnits - other.minorUnits);

  @override
  List<Object?> get props => <Object?>[minorUnits];
}
