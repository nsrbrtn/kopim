# TransactionTypeSelector (расход/доход)

## Назначение
Сегментированный переключатель для выбора типа транзакции (расход/доход) с анимированной «таблеткой» в стиле Kopim. Используется в форме добавления/редактирования транзакций и может переиспользоваться для других двоичных режимов.

## Параметры и стиль
- **Длительность анимации:** `Duration(milliseconds: 260)`
- **Кривая:** `Curves.easeOutBack`
- **Трек:** фон `surfaceContainerHigh`, скругление 999
- **Активная таблетка:** цвет `colorScheme.primary` (без альфы), скругление 999, анимированное смещение (`AnimatedPositioned`) и заливка (`AnimatedContainer`)
- **Текст:** `labelLarge`, анимации `AnimatedDefaultTextStyle` + `AnimatedScale`; выбранный цвет — `onPrimary`, невыбранный — `onSurface` c прозрачностью ~0.8; шрифт `w700` для выбранного, `w400` для невыбранного

## Пример использования
```dart
TransactionTypeSelector(
  formArgs: formArgs,
  strings: AppLocalizations.of(context)!,
)
```

## Связанные файлы
- Исходник: `lib/features/transactions/presentation/widgets/transaction_form_view.dart` (`_TransactionTypeSelector` и `_TypeSegmentItem`)
