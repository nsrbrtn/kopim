# GlowingAccountCard

## Назначение
Оборачивает карточку счёта анимированной подсветкой-змейкой, которая движется по контуру карточки. Используется на экране добавления/редактирования транзакции для подсветки выбранного счёта.

## Параметры
- `child` (`Widget`, обяз.) — содержимое карточки.
- `glowColor` (`Color`, по умолчанию `Color(0xFF00F7FF)`) — цвет змейки и направляющей обводки. Для интеграции с темой подставляйте цвет счёта.
- `duration` (`Duration`, по умолчанию `4400ms`) — время полного обхода змейки вокруг карточки.
- `borderRadius` (`double`, по умолчанию `24.0`) — радиус скругления траектории (должен совпадать с карточкой).
- `enabled` (`bool?`, по умолчанию `true`) — включает/выключает свечение. При `false` возвращает только `child` без анимации.

## События и коллбэки
Нет собственных событий. Используйте события вложенной карточки (например, `InkWell.onTap`).

## Пример использования
```dart
GlowingAccountCard(
  glowColor: accountColor,
  borderRadius: 16,
  enabled: isSelected,
  child: AccountCardContent(account: account),
)
```

## Связанные файлы
- Исходник: `lib/features/transactions/presentation/widgets/transaction_form_view.dart` (виджет `_AccountSelectionCard` использует `GlowingAccountCard` для выбранного счёта).
