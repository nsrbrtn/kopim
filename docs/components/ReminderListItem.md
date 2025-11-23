# ReminderListItem

## Назначение
Элемент списка напоминаний о платежах. Отображает информацию о напоминании в виде карточки с возможностью отметить как оплаченное, редактировать или удалить.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `reminder` | `PaymentReminder` | Данные напоминания | *обязательный* |
| `onTap` | `VoidCallback` | Коллбэк при нажатии на карточку (для редактирования) | *обязательный* |
| `timeService` | `TimeService` | Сервис для конвертации времени в локальную зону | *обязательный* |
| `onMarkPaid` | `VoidCallback` | Коллбэк для отметки напоминания как оплаченного | *обязательный* |
| `onDelete` | `VoidCallback` | Коллбэк для удаления напоминания | *обязательный* |

## События и коллбэки

| Событие | Описание |
|---------|----------|
| `onTap()` | Вызывается при нажатии на карточку — обычно открывает экран редактирования |
| `onMarkPaid()` | Вызывается при нажатии кнопки "отметить как оплачено" (иконка галочки) |
| `onDelete()` | Вызывается при выборе пункта "Удалить" в меню |

## Особенности поведения

- **Визуальный статус**: 
  - Неоплаченные — иконка будильника (`alarm`), светлый фон
  - Оплаченные — иконка галочки (`check_circle`), цветной фон (`secondaryContainer`)
- **Отображение данных**:
  - Заголовок напоминания
  - Дата и время в локальном формате
  - Сумма платежа (отформатированная с учётом локали, без символа валюты)
  - Заметка (опционально, отображается под датой)
- **Действия**:
  - Кнопка "Оплачено" — активна только для неоплаченных напоминаний
  - Меню (три точки) с пунктами "Редактировать" и "Удалить"
- **Форматирование**: автоматическое форматирование даты, времени и суммы с учётом локали
- **Адаптив**: корректно отображается на разных размерах экрана

## Структура PaymentReminder

```dart
class PaymentReminder {
  final String id;
  final String title;          // Название напоминания
  final double amount;         // Сумма платежа
  final int whenAtMs;         // Время напоминания (UTC timestamp)
  final String? note;         // Дополнительная заметка
  final bool isDone;          // Флаг оплаты
  // ...
}
```

## Пример использования

```dart
ReminderListItem(
  reminder: PaymentReminder(
    id: '1',
    title: 'Оплата интернета',
    amount: 800.0,
    whenAtMs: DateTime.now().add(Duration(days: 3)).millisecondsSinceEpoch,
    note: 'Не забыть до 25 числа',
    isDone: false,
  ),
  timeService: timeService,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditReminderScreen(reminderId: '1'),
      ),
    );
  },
  onMarkPaid: () async {
    await reminderService.markAsPaid('1');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Отмечено как оплачено')),
    );
  },
  onDelete: () async {
    final confirmed = await showDeleteConfirmationDialog(context);
    if (confirmed) {
      await reminderService.delete('1');
    }
  },
)
```

## Связанные файлы

- Исходный код: [`reminder_list_item.dart`](file:///home/artem/StudioProjects/kopim/lib/features/upcoming_payments/presentation/widgets/reminder_list_item.dart#L8-L134)
- Модель: `PaymentReminder`
- Сервис времени: `TimeService`
