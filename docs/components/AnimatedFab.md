# AnimatedFab

## Назначение
- Плавно вводит в интерфейс любую кнопку FAB с появлением через масштаб и fade.
- Используется на главном экране для кнопки добавления транзакции, но подходит для любых плавающих кнопок.

## Параметры
- `Widget child` — содержимое FAB (обычно сама кнопка с `onPressed`).
- `Duration duration` — длительность анимации появления (по умолчанию 450 мс).

## Пример использования
```dart
AnimatedFab(
  child: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),
);

// В приложении используется с кастомным KopimGlassFab:
AnimatedFab(
  child: KopimGlassFab(
    icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
    foregroundColor: Theme.of(context).colorScheme.primary,
    onPressed: onPressed,
  ),
);
```

## Связанные файлы
- `lib/core/widgets/animated_fab.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
