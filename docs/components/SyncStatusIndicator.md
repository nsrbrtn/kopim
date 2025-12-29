# SyncStatusIndicator

## Назначение
- Отображает текущее состояние синхронизации в AppBar: зелёная точка — всё ок, красная — офлайн, вращающиеся стрелки — идёт синхронизация.
- Используется на домашнем экране как компактный индикатор статуса.

## Параметры
- `double size` — размер индикатора (по умолчанию 10).

## Пример использования
```dart
const SyncStatusIndicator();
```

## Связанные файлы
- `lib/features/home/presentation/widgets/sync_status_indicator.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/home/presentation/widgets/home_gamification_app_bar.dart`
