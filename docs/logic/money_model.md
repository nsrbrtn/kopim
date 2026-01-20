# Единая модель денег

Цель: уйти от `double` и хранить суммы детерминированно с явной точностью,
поддерживая разные валюты и криптоактивы.

## Базовая модель

`Money` хранит:
- `minor` — целое количество минимальных единиц (BigInt).
- `scale` — число дробных знаков для валюты/актива.
- `currency` — ISO 4217 или тикер (например, `USD`, `RUB`, `BTC`).

Пример:
- `USD` (scale=2): `12.34` => `minor=1234`.
- `JPY` (scale=0): `1200` => `minor=1200`.
- `BTC` (scale=8): `0.00010000` => `minor=10000`.

## Округление

Единое правило: **banker’s rounding (half‑even)** до `scale` при вводе,
импорте и синхронизации.

Все вычисления выполняются в `minor` без `double`.

## Хранение в БД и доменных моделях

Каноничные поля — `*_minor` + `*_scale`:
- Accounts: `balance_minor`, `opening_balance_minor`, `currency_scale`.
- Transactions: `amount_minor`, `amount_scale`.
- Budgets/BudgetInstances: `amount_minor`, `amount_scale`.
- UpcomingPayments/PaymentReminders: `amount_minor`, `amount_scale`.
- Debts/Credits/CreditCards: `amount_minor`, `amount_scale` (а также `total_amount_*`
  или эквиваленты, если есть).

BigInt хранится в Drift как `TEXT` (строковое представление).

Legacy‑поля `balance/openingBalance/amount` (double) остаются для
совместимости и UI‑форматтеров, но все расчёты выполняются на `minor/scale`.

## Правила конвертации и backfill

- Если `*_minor` отсутствует, он вычисляется из `double` с учетом `scale`.
- Если есть и `*_minor`, и `double`, источником истины считается `*_minor`.
- `scale` берется из `currency_scale` счёта либо из `*_scale` сущности.

## Синк и импорт/экспорт

- В payload использовать `amountMinor`/`balanceMinor` + `currencyScale`.
- Для backward‑compat: если пришёл `amount` (double), конвертировать в minor.

## UI

UI форматирует `Money` по `currency/scale`.
Ввод — строка, парсинг в `Money` с округлением.
