# Виджет «Остаток в день» (Overview)

## Назначение
Карточка `Остаток` на экране обзора показывает, сколько денег можно тратить в день до ближайшего планового поступления.

## Источники данных
- Баланс по счетам: `AccountRepository.watchAccounts()`.
- Предстоящие движения: `UpcomingPaymentsRepository.watchAll()`.
- Фильтр счетов: `OverviewPreferences.accountIds`.

## Правила расчета (v1)
1. `currentBalance` — сумма `balanceMinor` по выбранным счетам.
2. Для каждого активного правила Upcoming рассчитывается ближайшая дата выполнения.
3. `nextIncomeDate` — ближайшая дата среди правил `flowType = income`.
4. `horizon`:
   - если есть `nextIncomeDate` → используем ее;
   - иначе fallback `today + 30 дней`.
5. До горизонта суммируются:
   - `plannedIncome` для `flowType = income`;
   - `plannedExpense` для `flowType = expense`.
6. `disposable = currentBalance + plannedIncome - plannedExpense`.
7. `daysLeft = max(1, days(horizon - today))`.
8. `dailyAllowance = disposable / daysLeft` (целочисленно в minor-единицах).

## Выходная модель
`OverviewDailyAllowance`:
- `dailyAllowance`
- `daysLeft`
- `horizonDate`
- `disposableAtHorizon`
- `plannedIncome`
- `plannedExpense`
- `hasIncomeAnchor`
- `isNegative`

## UI поведение
- Основная сумма: `dailyAllowance` + суффикс «в день».
- Подпись:
  - `Доход через N дней` — если найден ближайший доход;
  - `План на N дней` — fallback без доходов.

## Ограничения текущей версии
- В расчете используется только ближайшее исполнение каждого правила Upcoming.
- Мультивалютный сценарий сводится к unified money arithmetic без FX-конвертации.
