import 'dart:math';

abstract class LevelPolicy {
  int levelFor(int xp);

  String titleFor(int level);

  int nextThreshold(int xp);

  int previousThreshold(int level);
}

class SimpleLevelPolicy implements LevelPolicy {
  const SimpleLevelPolicy();

  static const List<int> _thresholds = <int>[0, 100, 500, 2000, 5000];
  static const Map<int, String> _titles = <int, String>{
    1: 'Птенец Тоторо',
    2: 'Ученик Кодамы',
    3: 'Путник по Небу Лапуты',
    4: 'Ходящий по Замкам',
    5: 'Дракон Реки',
  };

  @override
  int levelFor(int xp) {
    final int safeXp = max(0, xp);
    if (safeXp >= 5000) return 5;
    if (safeXp >= 2000) return 4;
    if (safeXp >= 500) return 3;
    if (safeXp >= 100) return 2;
    return 1;
  }

  @override
  String titleFor(int level) {
    return _titles[level] ?? _titles[1]!;
  }

  @override
  int nextThreshold(int xp) {
    final int safeXp = max(0, xp);
    for (final int threshold in _thresholds.skip(1)) {
      if (safeXp < threshold) {
        return threshold;
      }
    }
    return safeXp;
  }

  @override
  int previousThreshold(int level) {
    switch (level) {
      case 5:
        return 5000;
      case 4:
        return 2000;
      case 3:
        return 500;
      case 2:
        return 100;
      default:
        return 0;
    }
  }
}
