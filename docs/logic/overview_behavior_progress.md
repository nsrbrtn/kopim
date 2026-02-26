# Виджет «Поведенческий прогресс» (Overview)

Карточка `Поведенческий прогресс` на `OverviewScreen` показывает дисциплину ведения учета за последние 30 дней.

## Источник данных
- `AccountRepository.watchAccounts()`
- `TransactionRepository.watchTransactions()`
- Фильтры из `OverviewPreferences`:
  - `accountIds`
  - `categoryIds`

## Формула
Расчет выполняет `BehaviorDisciplineCalculator`.

- `activeDays30d` — количество уникальных дней с транзакциями в окне `30` дней.
- `streakDays` — количество дней подряд от текущей даты назад, где в каждом дне была хотя бы одна транзакция.
- `consistencyScore = clamp((activeDays30d / 30) * 100, 0..100)`.
- `streakScore = clamp((streakDays / 14) * 100, 0..100)`.
- `disciplineScore = round(consistencyScore * 0.6 + streakScore * 0.4)`.
- `progress = disciplineScore / 100`.

## UI поведение
- `title`: `Поведенческий прогресс`.
- `value`: `x{streakDays}`.
- `subtitle`: `{N} дней осознанного учета подряд`.
- progress bar: `progress` (`0..1`) с цветом зоны по `disciplineScore`.

Состояния:
- `loading`: `subtitle = "Расчёт..."`, `value = "x--"`.
- `error/empty`: `subtitle = "Нет данных"`, `value = "x--"`.

## Реализация
- Модель:
  `lib/features/overview/domain/models/overview_behavior_progress.dart`
- Калькулятор:
  `lib/features/overview/domain/services/behavior_discipline_calculator.dart`
- Use case:
  `lib/features/overview/domain/use_cases/watch_overview_behavior_progress_use_case.dart`
- Provider:
  `lib/features/overview/presentation/controllers/overview_financial_index_providers.dart`
- UI:
  `lib/features/overview/presentation/overview_screen.dart`

## Проверка
1. Добавить транзакции в последние дни и проверить рост `streak`.
2. Удалить транзакции за текущий день и проверить, что `streak` сбрасывается.
3. Проверить loading/error fallback без статичного `x6`.
