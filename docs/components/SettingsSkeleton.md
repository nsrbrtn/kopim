# SettingsSkeleton

## Назначение
Виджет-заглушка (скелетон) для экрана настроек. Показывается во время загрузки данных пользователя.

> **Примечание**: Это приватный виджет (`_SettingsSkeleton`), используемый внутри экрана меню/настроек.

## Параметры

Виджет не принимает параметров.

## Особенности поведения

- **Индикатор загрузки**: отображает стандартный `CircularProgressIndicator`
- **Центрированная компоновка**: индикатор размещается по центру доступного пространства
- **Фиксированные отступы**: вертикальные отступы 24px сверху и снизу
- **Простая анимация**: стандартная круговая анимация загрузки

## Пример использования

```dart
// Используется внутри экрана настроек
if (isLoading) {
  return _SettingsSkeleton();
}

// Обычно в контексте AsyncValue
profileState.when(
  loading: () => _SettingsSkeleton(),
  data: (profile) => ProfileContent(profile),
  error: (err, _) => ErrorWidget(err),
)
```

## Связанные файлы

- Исходный код: [`menu_screen.dart`](file:///home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/menu_screen.dart#L292-L302)
- Родительский экран: `MenuScreen`
