# KopimTextField

## Назначение
Кастомное текстовое поле ввода с фирменным стилем Kopim. Поддерживает placeholder, вспомогательный текст, префиксные/суффиксные иконки, многострочный режим и различные типы клавиатур.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `controller` | `TextEditingController?` | Контроллер для управления текстом | `null` |
| `focusNode` | `FocusNode?` | Узел фокуса | `null` |
| `placeholder` | `String?` | Текст-заполнитель (hint) | `null` |
| `supportingText` | `String?` | Вспомогательный текст под полем | `null` |
| `prefixIcon` | `Widget?` | Иконка слева внутри поля | `null` |
| `suffixIcon` | `Widget?` | Иконка справа внутри поля | `null` |
| `readOnly` | `bool` | Только для чтения | `false` |
| `enabled` | `bool` | Активно ли поле | `true` |
| `obscureText` | `bool` | Скрывать ли текст (для паролей) | `false` |
| `autofocus` | `bool` | Автоматический фокус при появлении | `false` |
| `keyboardType` | `TextInputType?` | Тип клавиатуры | `null` |
| `textInputAction` | `TextInputAction?` | Действие кнопки ввода | `null` |
| `inputFormatters` | `List<TextInputFormatter>?` | Форматтеры ввода | `null` |
| `onChanged` | `ValueChanged<String>?` | Коллбэк при изменении текста | `null` |
| `onSubmitted` | `ValueChanged<String>?` | Коллбэк при подтверждении ввода (Enter) | `null` |
| `onTap` | `VoidCallback?` | Коллбэк при нажатии на поле | `null` |
| `textCapitalization` | `TextCapitalization` | Автокапитализация | `none` |
| `maxLines` | `int?` | Максимальное количество строк | `1` |
| `minLines` | `int?` | Минимальное количество строк | `null` |
| `textStyle` | `TextStyle?` | Стиль текста | `null` |
| `fillColor` | `Color?` | Цвет фона поля | `null` |
| `placeholderColor` | `Color?` | Цвет placeholder | `null` |

## События и коллбэки

| Событие | Описание |
|---------|----------|
| `onChanged(String value)` | Вызывается при каждом изменении текста |
| `onSubmitted(String value)` | Вызывается при нажатии Enter или кнопки "Готово" на клавиатуре |
| `onTap()` | Вызывается при нажатии на поле |

## Особенности поведения

- **Stateful**: внутреннее состояние для управления фокусом и стилями
- **Адаптивная клавиатура**: тип клавиатуры зависит от `keyboardType`
- **Форматтеры**: поддержка `TextInputFormatter` для ограничения ввода
- **Многострочный режим**: при `maxLines > 1` или `minLines != null`
- **Read-only режим**: поле кликабельно, но не редактируется (для пикеров)

## Типы клавиатур

```dart
keyboardType: TextInputType.number        // Цифровая клавиатура
keyboardType: TextInputType.emailAddress  // Email клавиатура
keyboardType: TextInputType.phone         // Телефонная клавиатура
keyboardType: TextInputType.datetime      // Дата/время
keyboardType: TextInputType.multiline     // Многострочный ввод
```

## Примеры использования

### Простое текстовое поле

```dart
KopimTextField(
  placeholder: 'Введите название',
  onChanged: (value) {
    print('Текст изменён: $value');
  },
)
```

### С контроллером

```dart
final _controller = TextEditingController();

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// В build:
KopimTextField(
  controller: _controller,
  placeholder: 'Имя пользователя',
  prefixIcon: Icon(Icons.person),
  onSubmitted: (value) {
    submitForm();
  },
)
```

### Поле для суммы

```dart
KopimTextField(
  placeholder: '0,00',
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  prefixIcon: Icon(Icons.attach_money),
  textInputAction: TextInputAction.done,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
  ],
  onChanged: (value) {
    final amount = double.tryParse(value) ?? 0;
    setState(() => _amount = amount);
  },
)
```

### Поле для заметок (многострочное)

```dart
KopimTextField(
  placeholder: 'Добавьте заметку...',
  maxLines: 5,
  minLines: 3,
  textInputAction: TextInputAction.newline,
  textCapitalization: TextCapitalization.sentences,
  supportingText: 'Макс. 500 символов',
)
```

### Поле пароля

```dart
bool _obscurePassword = true;

KopimTextField(
  placeholder: 'Пароль',
  obscureText: _obscurePassword,
  prefixIcon: Icon(Icons.lock),
  suffixIcon: IconButton(
    icon: Icon(
      _obscurePassword ? Icons.visibility : Icons.visibility_off,
    ),
    onPressed: () {
      setState(() => _obscurePassword = !_obscurePassword);
    },
  ),
  onSubmitted: (password) {
    login(password);
  },
)
```

### Read-only поле (для picker)

```dart
KopimTextField(
  controller: _dateController,
  placeholder: 'Выберите дату',
  readOnly: true,
  prefixIcon: Icon(Icons.calendar_today),
  onTap: () async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _dateController.text = DateFormat.yMd().format(date);
    }
  },
)
```

### С валидацией и вспомогательным текстом

```dart
String? _errorText;

KopimTextField(
  placeholder: 'Email',
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icon(Icons.email),
  supportingText: _errorText ?? 'Введите корректный email',
  onChanged: (value) {
    setState(() {
      if (!value.contains('@')) {
        _errorText = 'Некорректный email';
      } else {
        _errorText = null;
      }
    });
  },
)
```

### С автокапитализацией

```dart
KopimTextField(
  placeholder: 'Название счёта',
  textCapitalization: TextCapitalization.words,  // "мой Счёт" → "Мой Счёт"
  prefixIcon: Icon(Icons.account_balance_wallet),
)
```

## Использование в формах

```dart
class TransactionForm extends StatefulWidget {
  // ...
}

class _TransactionFormState extends State<TransactionForm> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        KopimTextField(
          controller: _amountController,
          placeholder: 'Сумма',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          prefixIcon: Icon(Icons.attach_money),
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 16),
        KopimTextField(
          controller: _noteController,
          placeholder: 'Заметка (опционально)',
          maxLines: 3,
          prefixIcon: Icon(Icons.note),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
```

## Связанные файлы

- Исходный код: [`kopim_text_field.dart`](file:///home/artem/StudioProjects/kopim/lib/core/widgets/kopim_text_field.dart#L7-L59)
- Используется в: всех формах приложения (транзакции, счета, категории, профиль)
