# HomeOverviewSummaryCard

## Назначение
Карточка-виджет на главном экране, показывающая общий баланс, дневные доходы/расходы и топ-категорию расходов за месяц.

## Параметры
- `onTap` (VoidCallback) — обработчик клика по карточке.

## События и коллбэки
- `onTap` — переход на экран обзора.

## Пример использования
```dart
HomeOverviewSummaryCard(
  onTap: () => context.push(OverviewScreen.routeName),
)
```

## Связанные файлы
- `lib/features/home/presentation/widgets/home_overview_summary_card.dart`
- `lib/features/home/domain/use_cases/watch_home_overview_summary_use_case.dart`
- `test/features/home/presentation/widgets/home_overview_summary_card_test.dart`
