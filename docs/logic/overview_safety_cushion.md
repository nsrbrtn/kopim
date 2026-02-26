# Финансовая подушка (Overview)

## Обзор
Карточка `Финансовая подушка` на `OverviewScreen` показывает, на сколько месяцев хватит ликвидных активов при текущем уровне расходов.

## Формула
- `liquidAssets` — сумма балансов ликвидных счетов (исключаем `credit`, `credit_card`, `debt`).
- `avgMonthlyExpense3m` — средний месячный расход за последние 3 месяца.
- `monthsCovered = liquidAssets / max(avgMonthlyExpense3m, 1)` с ограничением `0..12`.
- `targetMonths` — целевой горизонт (MVP: `6`).
- `progress = clamp(monthsCovered / targetMonths, 0..1)`.

## Safety score
Для синхронизации с фактором `safety` финансового индекса используется единая формула:
- `coverageScore = clamp((monthsCovered / targetMonths) * 100, 0..100)`
- `goalScore` — прогресс активных целей накоплений (или fallback от `monthsCovered`)
- `safetyScore = round(coverageScore * 0.7 + goalScore * 0.3)`

## Реализация
- Модель: `lib/features/overview/domain/models/overview_safety_cushion.dart`
- Калькулятор: `lib/features/overview/domain/services/safety_cushion_calculator.dart`
- Use case: `lib/features/overview/domain/use_cases/watch_overview_safety_cushion_use_case.dart`
- Provider: `lib/features/overview/presentation/controllers/overview_financial_index_providers.dart`
- UI-карточка: `lib/features/overview/presentation/overview_screen.dart`

## Edge-cases
- Нет расходов и нет активов: карточка показывает `0` и нейтральный `safetyScore=50`.
- Liability-счета не участвуют в расчете ликвидной подушки.
- При ошибке потока карточка показывает fallback `No data / Нет данных` без фиктивных значений.
