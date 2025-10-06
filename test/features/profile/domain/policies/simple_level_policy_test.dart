import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';

void main() {
  const SimpleLevelPolicy policy = SimpleLevelPolicy();

  test('level boundaries are respected', () {
    expect(policy.levelFor(0), 1);
    expect(policy.levelFor(99), 1);
    expect(policy.levelFor(100), 2);
    expect(policy.levelFor(499), 2);
    expect(policy.levelFor(500), 3);
    expect(policy.levelFor(1999), 3);
    expect(policy.levelFor(2000), 4);
    expect(policy.levelFor(4999), 4);
    expect(policy.levelFor(5000), 5);
    expect(policy.levelFor(8000), 5);
  });

  test('titles correspond to levels', () {
    expect(policy.titleFor(1), 'Птенец Тоторо');
    expect(policy.titleFor(2), 'Ученик Кодамы');
    expect(policy.titleFor(3), 'Путник по Небу Лапуты');
    expect(policy.titleFor(4), 'Ходящий по Замкам');
    expect(policy.titleFor(5), 'Дракон Реки');
  });

  test('next threshold returns closest boundary', () {
    expect(policy.nextThreshold(0), 100);
    expect(policy.nextThreshold(150), 500);
    expect(policy.nextThreshold(1200), 2000);
    expect(policy.nextThreshold(3200), 5000);
    expect(policy.nextThreshold(6000), 6000);
  });
}
