# SettingsErrorMessage

## Назначение
Виджет для отображения сообщения об ошибке в настройках. Используется для информирования пользователя о проблемах (например, при сохранении настроек).

> **Примечание**: Это приватный виджет (`_SettingsErrorMessage`), используемый внутри экрана настроек.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `message` | `String` | Текст сообщения об ошибке | *обязательный* |

## Особенности поведения

- **Цвет**: текст отображается красным цветом (`error` из темы)
- **Стиль**: использует `bodyMedium` из темы
- **Отступы**: вертикальные отступы 8px сверху и снизу
- **Простая компоновка**: просто текст с отступами

## Пример использования

```dart
if (errorMessage != null) {
  _SettingsErrorMessage(message: errorMessage);
}

// Конкретный пример
_SettingsErrorMessage(
  message: 'Не удалось сохранить настройки. Попробуйте ещё раз.',
)
```

## Использование в контексте формы

```dart
Column(
  children: [
    TextField(
      // ...
    ),
    if (validationError != null)
      _SettingsErrorMessage(message: validationError),
    ElevatedButton(
      onPressed: _save,
      child: Text('Сохранить'),
    ),
  ],
)
```

## Связанные файлы

- Исходный код: [`menu_screen.dart`](file:///home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/menu_screen.dart#L304-L322)
- Родительский экран: `MenuScreen`
