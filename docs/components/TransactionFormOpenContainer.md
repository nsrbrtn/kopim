# TransactionFormOpenContainer

## Назначение
- Оборачивает любую «закрытую» карточку или кнопку и открывает экран формы транзакции с анимацией `OpenContainer` в стиле fade-through.
- Унифицирует переходы для создания и редактирования транзакций, сохраняя форму и цвет закрытого виджета.

## Параметры
- `Widget Function(BuildContext, VoidCallback) closedBuilder` — билдер закрытого состояния; обязан вызвать `openContainer` для запуска анимации.
- `TransactionFormArgs formArgs` — аргументы формы (по умолчанию — пустые, для создания новой транзакции).
- `Duration transitionDuration` — длительность перехода (по умолчанию 450 мс).
- `void Function(TransactionFormResult? result)? onClosed` — коллбэк после закрытия экрана формы.

## События и коллбэки
- `onClosed` — возвращает `TransactionFormResult?` после закрытия (успешное сохранение или отмена).

## Пример использования
```dart
// FAB на главном экране
TransactionFormOpenContainer(
  closedBuilder: (context, open) => KopimGlassFab(
    icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
    foregroundColor: Theme.of(context).colorScheme.primary,
    onPressed: open,
  ),
  onClosed: (result) {
    // Показать снекбар или сделать undo
  },
);

// Карточка транзакции в списке
TransactionFormOpenContainer(
  formArgs: TransactionFormArgs(initialTransaction: transaction),
  closedBuilder: (context, open) => Card(
    child: InkWell(
      onTap: open,
      child: TransactionListTileContent(transaction: transaction),
    ),
  ),
);
```

## Связанные файлы
- `lib/features/transactions/presentation/widgets/transaction_form_open_container.dart`
- `lib/features/transactions/presentation/add_transaction_screen.dart`
