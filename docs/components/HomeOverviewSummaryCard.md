# HomeOverviewSummaryCard

## Назначение
Карточка-виджет на главном экране, показывающая общий баланс, дневные доходы/расходы и топ-категорию расходов за месяц. Данные рассчитываются с учетом настроек обзора (по умолчанию учитываются все счета, включая скрытые и кредитные/долговые).

## Параметры
- `onTap` (VoidCallback) — обработчик клика по карточке.

## События и коллбэки
- `onTap` — переход на экран обзора `OverviewScreen`.

## Поведение перехода
- По нажатию открывается экран `OverviewScreen` с карточками аналитического обзора.
- Текущая версия экрана обзора реализована как статичный UI-макет (без подключения бизнес-логики и реальных вычислений).

## Пример использования
```dart
HomeOverviewSummaryCard(
  onTap: () => context.push(OverviewScreen.routeName),
)
```

## Связанные файлы
- `lib/features/home/presentation/widgets/home_overview_summary_card.dart`
- `lib/features/home/domain/use_cases/watch_home_overview_summary_use_case.dart`
- `lib/features/overview/presentation/overview_screen.dart`
- `lib/features/overview/presentation/overview_settings_screen.dart`
- `lib/features/overview/presentation/controllers/overview_preferences_controller.dart`
- `test/features/home/presentation/widgets/home_overview_summary_card_test.dart`
