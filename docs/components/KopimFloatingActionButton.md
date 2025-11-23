# KopimFloatingActionButton

## Назначение
Кастомная кнопка действия (FAB) с фирменным стилем Kopim. Поддерживает как обычный, так и расширенный режим (с текстовой меткой). Имеет стеклянный эффект с настраиваемыми цветами и скруглениями.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `onPressed` | `VoidCallback?` | Коллбэк при нажатии на кнопку | *обязательный* |
| `child` | `Widget?` | Кастомный дочерний виджет | `null` |
| `icon` | `Widget?` | Иконка кнопки | `null` |
| `label` | `Widget?` | Текстовая метка (включает расширенный режим) | `null` |
| `tooltip` | `String?` | Текст подсказки | `null` |
| `heroTag` | `Object?` | Тег для hero-анимации | `null` |
| `focusNode` | `FocusNode?` | Узел фокуса | `null` |
| `materialTapTargetSize` | `MaterialTapTargetSize?` | Размер области нажатия | `null` |
| `autofocus` | `bool` | Автоматический фокус при появлении | `false` |
| `mini` | `bool` | Уменьшенный размер кнопки | `false` |
| `clipBehavior` | `Clip` | Поведение обрезки | `Clip.antiAlias` |
| `decorationColor` | `Color?` | Цвет фона кнопки | `primary` из темы |
| `foregroundColor` | `Color?` | Цвет иконки/текста | `onPrimary` из темы |
| `iconSize` | `double?` | Размер иконки | `iconSizes.md * 3` |

> **Важно**: Хотя бы один из параметров `child`, `icon` или `label` должен быть задан.

## Особенности поведения

- **Два режима**: обычный (круглая кнопка) и расширенный (с текстом)
- **Фиксированный размер**: 72x72 для обычной кнопки
- **Скругления**: использует `layout.radius.card` из темы
- **Нулевая тень**: `elevation: 0` для чистого дизайна
- **IconTheme**: автоматически применяет размер иконки ко всем дочерним Icons

## Режимы

### Обычный режим (круглая кнопка)
Активируется когда `label` не задан.

### Расширенный режим (с текстом)
Активируется при наличии `label`. Кнопка растягивается по ширине контента.

## Примеры использования

### Простая кнопка с иконкой

```dart
KopimFloatingActionButton(
  icon: Icon(Icons.add),
  tooltip: 'Добавить транзакцию',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(),
      ),
    );
  },
)
```

### Расширенная кнопка

```dart
KopimFloatingActionButton(
  icon: Icon(Icons.save),
  label: Text('Сохранить'),
  tooltip: 'Сохранить изменения',
  onPressed: () async {
    await saveData();
  },
)
```

### С пользовательскими цветами

```dart
KopimFloatingActionButton(
  icon: Icon(Icons.delete),
  decorationColor: Colors.red,
  foregroundColor: Colors.white,
  tooltip: 'Удалить',
  onPressed: () {
    showDeleteConfirmation();
  },
)
```

### Мини-кнопка

```dart
KopimFloatingActionButton(
  icon: Icon(Icons.edit),
  mini: true,
  tooltip: 'Редактировать',
  onPressed: onEdit,
)
```

## Связанные файлы

- Исходный код: [`kopim_floating_action_button.dart`](file:///home/artem/StudioProjects/kopim/lib/core/widgets/kopim_floating_action_button.dart#L4-L110)
- Используется в: различных экранах приложения для основных действий
