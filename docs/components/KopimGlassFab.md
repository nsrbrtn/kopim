# KopimGlassFab

## Назначение
Стеклянная капсула для `KopimFloatingActionButton`, объединяющая blur, прозрачность, скругления и тени в одном компоненте без хардкода на экранах. Подходит для плавающих кнопок на главном и бюджетном экранах.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `onPressed` | `VoidCallback?` | Обработчик нажатия | *обязательный* |
| `child` | `Widget?` | Пользовательский контент FAB | `null` |
| `icon` | `Widget?` | Иконка FAB | `null` |
| `label` | `Widget?` | Текстовая метка (включает extended-режим) | `null` |
| `tooltip` | `String?` | Подсказка при долгом тапе | `null` |
| `heroTag` | `Object?` | Тег для hero-анимации | `null` |
| `focusNode` | `FocusNode?` | Узел фокуса | `null` |
| `materialTapTargetSize` | `MaterialTapTargetSize?` | Размер области касания | `null` |
| `autofocus` | `bool` | Автофокус при появлении | `false` |
| `mini` | `bool` | Компактная версия FAB | `false` |
| `clipBehavior` | `Clip` | Поведение обрезки содержимого | `Clip.antiAlias` |
| `foregroundColor` | `Color?` | Цвет иконки/текста | `primary` темы |
| `iconSize` | `double?` | Размер иконки в пикселях | `64` |
| `enableGradientHighlight` | `bool` | Включает подсветку-градиент стекла | `false` |

> Требуется хотя бы один из параметров `child`, `icon` или `label`.

## Особенности

- Единый стеклянный стиль: blur `7`, прозрачность на базе темы (`0.14/0.22`), бордер и тень включены.
- Размер капсулы вычисляется из `KopimFloatingActionButton.defaultSize` и `layout.spacing.section`.
- Внутри всегда используется прозрачный фон у FAB, чтобы проявлялся стеклянный слой.

## Пример

```dart
KopimGlassFab(
  icon: const Icon(Icons.add),
  tooltip: 'Добавить транзакцию',
  onPressed: () => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const AddTransactionScreen(),
    ),
  ),
)
```

## Связанные файлы

- Исходник: `lib/core/widgets/kopim_glass_fab.dart`
- Базовый FAB: `lib/core/widgets/kopim_floating_action_button.dart`
- Стеклянная поверхность: `lib/core/widgets/kopim_glass_surface.dart`
