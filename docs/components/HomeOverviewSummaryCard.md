# HomeOverviewSummaryCard

## Назначение
Карточка-виджет на главном экране, показывающая общий баланс, дневные доходы/расходы и топ-категорию расходов за месяц. Данные рассчитываются с учетом настроек обзора (по умолчанию учитываются все счета, включая скрытые и кредитные/долговые).

## Визуальная структура
- Внешний контейнер использует `secondaryContainer` с радиусом 28 и внутренним отступом 8.
- Верхний акцентный блок баланса и нижние плитки используют светлую зелёную подложку по макету, крупную типографику `displayMedium` и иконку `arrow_outward` как индикатор перехода.
- Нижний ряд состоит из двух карточек: сводка за сегодня и топ расходов за месяц.
- Для топ-категории расходов отображается иконка категории в отдельном лаймовом контейнере; при отсутствии данных показывается текстовое пустое состояние.

## Параметры
- `onTap` (VoidCallback) — обработчик клика по карточке.

## События и коллбэки
- `onTap` — переход на экран обзора `OverviewScreen`.

## Поведение перехода
- По нажатию открывается экран `OverviewScreen` с карточками аналитического обзора.
- Текущая версия экрана обзора реализована как статичный UI-макет (без подключения бизнес-логики и реальных вычислений).

## Как проверить
- На главном экране карточка обзора должна иметь трёхуровневую композицию: внешний фон, крупный баланс сверху и две нижние плитки.
- Нажатие по любой области карточки должно по-прежнему открывать `OverviewScreen`.
- Если за месяц нет расходов, в правой нижней плитке показывается `Нет расходов` / `No expenses yet`.

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
