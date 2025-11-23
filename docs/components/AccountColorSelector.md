# AccountColorSelector

## Назначение
Виджет для выбора пользовательского цвета счёта. Отображается в виде элемента списка с превью цвета, текущим значением (hex-код) и кнопками для выбора/очистки цвета.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `color` | `String?` | HEX-представление текущего цвета (например, "#FF5733") | *обязательный* |
| `onColorChanged` | `ValueChanged<String?>` | Коллбэк при изменении цвета, передаёт новый hex-код или null | *обязательный* |
| `enabled` | `bool` | Флаг активности виджета (можно ли взаимодействовать) | *обязательный* |

## События и коллбэки

| Событие | Описание |
|---------|----------|
| `onColorChanged(String? hexColor)` | Вызывается при выборе нового цвета или его очистке. Передаёт hex-код без альфа-канала (например, "#FF5733") или `null` |

## Особенности поведения

- **Превью цвета**: слева отображается аватар с текущим цветом или иконкой палитры, если цвет не выбран
- **Hex-код**: в подзаголовке отображается текущий цвет в формате hex или текст "По умолчанию"
- **Две кнопки**:
  - Кнопка **очистки** (крестик) — отображается только если цвет выбран, вызывает `onColorChanged(null)`
  - Кнопка **выбора** (палитра) — открывает диалог выбора цвета
- **Диалог выбора**: использует `showAccountColorPickerDialog` с сеткой предустановленных цветов
- **Отключённое состояние**: при `enabled = false` все интерактивные элементы неактивны

## Пример использования

```dart
String? accountColor;

AccountColorSelector(
  color: accountColor,
  enabled: true,
  onColorChanged: (String? newColor) {
    setState(() {
      accountColor = newColor;
    });
    print('Новый цвет: ${newColor ?? "не выбран"}');
  },
)
```

## Пример с формой редактирования счёта

```dart
class EditAccountForm extends StatefulWidget {
  // ...
}

class _EditAccountFormState extends State<EditAccountForm> {
  String? _selectedColor;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // другие поля формы...
        
        AccountColorSelector(
          color: _selectedColor,
          enabled: !_isSaving,
          onColorChanged: (color) {
            setState(() => _selectedColor = color);
          },
        ),
      ],
    );
  }
}
```

## Связанные файлы

- Исходный код: [`account_color_selector.dart`](file:///home/artem/StudioProjects/kopim/lib/features/accounts/presentation/widgets/account_color_selector.dart#L23-L88)
- Диалог выбора: `showAccountColorPickerDialog` (в том же файле)
- Утилиты цвета: `parseHexColor`, `colorToHex` (используются для конвертации)
