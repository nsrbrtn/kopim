# Инварианты ручного платежа по кредиту

Документ фиксирует обязательные проверки при проведении ручного платежа по кредиту.

## Где применяется

- `lib/features/credits/domain/use_cases/make_credit_payment_use_case.dart`
- `lib/features/credits/presentation/widgets/pay_credit_sheet.dart`
- `lib/features/credits/presentation/screens/add_edit_credit_screen.dart`

## Инварианты

1. `totalOutflow` должен быть строго больше нуля.
2. `principalPaid`, `interestPaid`, `feesPaid` не могут быть отрицательными.
3. Сумма должна совпадать: `totalOutflow = principalPaid + interestPaid + feesPaid`.
4. Все части платежа должны совпадать с `totalOutflow` по `currency` и `scale`.
5. Для principal-перевода (`type=transfer`) должен существовать валидный `transferAccountId` (кредитный счет).
6. Счет списания должен существовать на момент проведения платежа.
7. Валюта счета списания и кредитного счета должна совпадать.
8. Повторный вызов ручного платежа с тем же `idempotencyKey` не должен создавать дубли.

## Изменение поведения формы кредита

- Валюта и scale для создаваемого кредита берутся из связанного счета:
  - при редактировании — из кредитного счета,
  - при создании — из выбранного счета зачисления,
  - fallback — из primary/первого активного счета,
  - финальный fallback: `RUB`.

Это убирает жесткую привязку к `RUB` в форме и предотвращает некорректный `minor/scale` в мультивалютном контуре.

## Пересчет графика при редактировании кредита

- При изменении суммы/ставки/срока кредита график (`credit_payment_schedule`) пересчитывается.
- Для совпавших периодов (`periodKey`) сохраняются фактические оплаты (`principalPaid`/`interestPaid`) с клампом до новых плановых значений.
- Периоды, которые больше не входят в новый срок и были в статусе `planned`, помечаются как `skipped`.

## Как проверить

```bash
flutter test test/features/credits/domain/use_cases/make_credit_payment_use_case_test.dart --reporter expanded
```

## Идемпотентность ручного платежа

- На группу платежа пишется `credit_payment_groups.idempotency_key`.
- В БД действует уникальный индекс: `credit_payment_groups_idempotency_key_unique`.
- Вставка группы выполняется через `insertOrIgnore`; при конфликте уникальности повтор считается идемпотентным успехом.
- При чтении графика и групп платежей валюта берется из кредитного счета (`credits.account_id -> accounts.currency`), а не из `XXX`.
- Для связанных транзакций используются детерминированные ключи:
  - `<baseKey>:principal`
  - `<baseKey>:interest`
  - `<baseKey>:fees`

## Уникальность периодов графика

- В БД действует уникальный индекс: `payment_schedules_credit_period_unique`.
- Для каждого кредита период (`credit_id + period_key`) может существовать только в одном экземпляре.
- Миграция `42 -> 43` дедуплицирует старые дубли:
  - сохраняет наиболее актуальную запись периода (по `updated_at`, затем `created_at`);
  - перевязывает `credit_payment_groups.schedule_item_id` на сохраненную запись.

## Инварианты schedule item

- `principalPaid` и `interestPaid` не могут быть отрицательными.
- `principalPaid <= principalAmount` и `interestPaid <= interestAmount`.
- `totalAmount = principalAmount + interestAmount`.
- Все Money-поля schedule item должны быть в одном `currency/scale`.
- `status=paid` допускается только при полном погашении и с заполненным `paidAt`.
- `status=partiallyPaid` требует частичной, но не полной оплаты.
- `status=planned/skipped` не допускает оплаченных сумм и `paidAt`.
- При пересчете графика в `UpdateCreditUseCase` `paidAt` нормализуется по статусу:
  - `paid` → `paidAt` обязателен (если отсутствовал, заполняется текущим временем),
  - `planned/skipped` → `paidAt = null`.
- Доменный валидатор: `CreditPaymentScheduleValidator`, применяется при `addSchedule/updateScheduleItem` в `CreditRepositoryImpl`.
