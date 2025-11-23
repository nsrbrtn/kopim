# KopimDropdownField

## Назначение
Кастомное выпадающее меню (dropdown) с фирменным стилем Kopim. Поддерживает анимированное раскрытие, иконку слева, placeholder и произвольную функцию отображения выбранного значения.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `items` | `List<DropdownMenuItem<T>>` | Список элементов для выбора | *обязательный* |
| `value` | `T?` | Текущее выбранное значение | *обязательный* |
| `onChanged` | `ValueChanged<T>?` | Коллбэк при изменении значения | `null` |
| `label` | `String?` | Метка поля | `null` |
| `leading` | `Widget?` | Иконка или виджет слева от значения | `null` |
| `hint` | `String?` | Placeholder когда значение не выбрано | `null` |
| `duration` | `Duration` | Длительность анимации раскрытия | `260ms` |
| `enabled` | `bool` | Активно ли поле | `true` |
| `valueLabelBuilder` | `String Function(T?)?` | Функция для кастомного отображения выбранного значения | `null` |

## События и коллбэки

| Событие | Описание |
|---------|----------|
| `onChanged(T value)` | Вызывается при выборе нового значения из списка |

## Особенности поведения

- **Анимированное раскрытие**: плавная анимация появления списка
- **Кастомное отображение**: через `valueLabelBuilder` можно переопределить текст выбранного значения
- **Состояние disabled**: при `enabled = false` или `onChanged = null` поле неактивно
- **Leading icon**: можно добавить иконку слева для визуальной категоризации
- **Hint text**: отображается когда `value == null`

## Типовые параметры

Виджет поддерживает generic тип `<T>` для типобезопасности:
```dart
KopimDropdownField<String>  // Для строк
KopimDropdownField<int>     // Для чисел
KopimDropdownField<Category> // Для пользовательских типов
```

## Примеры использования

### Базовое использование

```dart
String? selectedCategory;

KopimDropdownField<String>(
  items: [
    DropdownMenuItem(value: 'food', child: Text('Еда')),
    DropdownMenuItem(value: 'transport', child: Text('Транспорт')),
    DropdownMenuItem(value: 'entertainment', child: Text('Развлечения')),
  ],
  value: selectedCategory,
  label: 'Категория',
  hint: 'Выберите категорию',
  onChanged: (value) {
    setState(() => selectedCategory = value);
  },
)
```

### С иконкой

```dart
KopimDropdownField<String>(
  items: [
    DropdownMenuItem(
      value: 'cash',
      child: Text('Наличные'),
    ),
    DropdownMenuItem(
      value: 'card',
      child: Text('Карта'),
    ),
  ],
  value: selectedPaymentMethod,
  label: 'Способ оплаты',
  leading: Icon(Icons.payment),  // Иконка слева
  onChanged: (value) {
    setState(() => selectedPaymentMethod = value);
  },
)
```

### С кастомным отображением значения

```dart
KopimDropdownField<Account>(
  items: accounts.map((account) =>
    DropdownMenuItem(
      value: account,
      child: Text(account.name),
    ),
  ).toList(),
  value: selectedAccount,
  label: 'Счёт',
  valueLabelBuilder: (account) {
    // Показываем имя + баланс
    if (account == null) return null;
    return '${account.name} (${formatCurrency(account.balance)})';
  },
  onChanged: (account) {
    setState(() => selectedAccount = account);
  },
)
```

### Неактивное поле

```dart
KopimDropdownField<String>(
  items: statusOptions,
  value: currentStatus,
  label: 'Статус',
  enabled: false,  // Поле заблокировано
  onChanged: null,
)
```

### С быстрой анимацией

```dart
KopimDropdownField<int>(
  items: [
    DropdownMenuItem(value: 1, child: Text('Опция 1')),
    DropdownMenuItem(value: 2, child: Text('Опция 2')),
  ],
  value: selectedOption,
  duration: Duration(milliseconds: 150),  // Быстрая анимация
  onChanged: (value) => setState(() => selectedOption = value),
)
```

## Использование в формах

```dart
class TransactionForm extends StatefulWidget {
  // ...
}

class _TransactionFormState extends State<TransactionForm> {
  String? _selectedCategory;
  Account? _selectedAccount;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        KopimDropdownField<Account>(
          items: _accounts.map((acc) =>
            DropdownMenuItem(value: acc, child: Text(acc.name))
          ).toList(),
          value: _selectedAccount,
          label: 'Счёт',
          leading: Icon(Icons.account_balance),
          hint: 'Выберите счёт',
          onChanged: (account) {
            setState(() => _selectedAccount = account);
          },
        ),
        SizedBox(height: 16),
        KopimDropdownField<String>(
          items: _categories.map((cat) =>
            DropdownMenuItem(value: cat.id, child: Text(cat.name))
          ).toList(),
          value: _selectedCategory,
          label: 'Категория',
          hint: 'Выберите категорию',
          onChanged: (categoryId) {
            setState(() => _selectedCategory = categoryId);
          },
        ),
      ],
    );
  }
}
```

## Связанные файлы

- Исходный код: [`kopim_dropdown_field.dart`](file:///home/artem/StudioProjects/kopim/lib/core/widgets/kopim_dropdown_field.dart#L6-L32)
- Используется в: формах транзакций, настройках, фильтрах
