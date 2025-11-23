# SettingsMenuItem

## Назначение
Пункт меню настроек с иконкой и текстовой меткой. Используется для создания кликабельных элементов в списке настроек.

> **Примечание**: Это приватный виджет (`_SettingsMenuItem`), используемый внутри экрана настроек.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `icon` | `IconData` | Иконка пункта меню | *обязательный* |
| `label` | `String` | Текстовая метка пункта меню | *обязательный* |
| `textStyle` | `TextStyle?` | Кастомный стиль текста | *обязательный* |
| `onTap` | `VoidCallback?` | Коллбэк при нажатии | `null` |
| `backgroundColor` | `Color?` | Цвет фона | `Colors.transparent` |
| `borderRadius` | `double` | Радиус скругления углов | `16` |
| `contentPadding` | `EdgeInsetsGeometry` | Внутренние отступы | `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` |

## События и коллбэки

| Событие | Описание |
|---------|----------|
| `onTap()` | Вызывается при нажатии на элемент меню |

## Особенности поведения

- **Компоновка**: иконка слева, текст справа
- **Цвет иконки**: `onSurfaceVariant` из темы (приглушённый)
- **Интерактивность**: эффект нажатия (InkWell) с учётом `borderRadius`
- **Адаптивность**: текст расширяется на всю доступную ширину
- **Прозрачность фона**: по умолчанию фон прозрачный (можно переопределить)

## Пример использования

```dart
// Простой пункт меню
_SettingsMenuItem(
  icon: Icons.person_outline,
  label: 'Профиль',
  textStyle: theme.textTheme.bodyLarge,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen()),
    );
  },
)

// С кастомным фоном
_SettingsMenuItem(
  icon: Icons.logout,
  label: 'Выйти',
  textStyle: theme.textTheme.bodyLarge?.copyWith(
    color: theme.colorScheme.error,
  ),
  backgroundColor: theme.colorScheme.errorContainer,
  onTap: () async {
    await authService.logout();
  },
)

// Неактивный элемент
_SettingsMenuItem(
  icon: Icons.info_outline,
  label: 'О приложении',
  textStyle: theme.textTheme.bodyMedium,
  onTap: null, // неактивен
)
```

## Связанные файлы

- Исходный код: [`menu_screen.dart`](file:///home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/menu_screen.dart#L192-L244)
- Родительский экран: `MenuScreen`
