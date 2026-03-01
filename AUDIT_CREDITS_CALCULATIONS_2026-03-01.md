# Аудит ключевых расчетных компонентов

Дата: 2026-03-01
Область: кредиты, платежи, транзакционные балансы, upcoming rules, обзорные агрегаты.

## Статус реализации (обновлено 2026-03-01)

Выполнено:
- Инварианты платежа в `MakeCreditPaymentUseCase` (сумма компонентов, валюта/scale, `totalOutflow > 0`).
- Идемпотентность ручной оплаты (insert-if-absent + интеграционные/юнит проверки).
- Доменная валидация `CreditPaymentSchedule` перенесена в `CreditRepositoryImpl` (`addSchedule`/`updateScheduleItem`).
- Добавлены unit-тесты `CreditPaymentScheduleValidator` (матрица статусов и граничные кейсы).
- Расширены инвариантные тесты для `credit_calculations` и `credit_payment_amounts`.
- Консолидирован расчет аннуитетного платежа: `credit_calculations` использует единый источник `AnnuityCalculator.calculateMonthlyPayment`.

Осталось в этом аудите:
- Закрыть незавершенный `update_credit_payment_case.dart` (или удалить мертвый код).
- Довести покрытие UI-валидации в `pay_credit_sheet.dart` до полного набора негативных кейсов.

## TODO по update_credit_payment_case.dart

- [ ] Определить финальное решение: реализуем редактирование платежа или удаляем неиспользуемый use case.
- [ ] Если реализуем: добавить методы репозитория для чтения `payment group` по `groupId` и связанных транзакций.
- [ ] Добавить валидации на уровне use case: `totalOutflow == principal + interest + fees`, неотрицательность, единый `currency/scale`.
- [ ] Обновлять атомарно: `payment group` + связанные транзакции + `schedule item` (если привязан).
- [ ] Добавить unit/integration тесты на редактирование с изменением нулевых/ненулевых компонент и идемпотентные ключи.

## Критичные дефекты

1. Инвариант сумм кредитного платежа не enforced.
- Файл: `lib/features/credits/domain/use_cases/make_credit_payment_use_case.dart`
- Проблема: не проверяется равенство `totalOutflow == principal + interest + fees`.
- Риск: рассинхрон между платежной группой и проводками.

2. `transfer` может создаваться без `transferAccountId`.
- Файлы:
  - `lib/features/credits/domain/use_cases/make_credit_payment_use_case.dart`
  - `lib/features/transactions/data/services/transaction_balance_helper.dart`
- Проблема: при `type=transfer` и пустом `transferAccountId` баланс-эффект пустой.
- Риск: операция есть, балансы не изменены как ожидается.

3. Жесткий `RUB` в форме кредита.
- Файл: `lib/features/credits/presentation/screens/add_edit_credit_screen.dart`
- Проблема: scale/currency берутся не из данных пользователя/счета.
- Риск: ошибочные minor-суммы в мультивалютном сценарии.

## Высокий приоритет

4. Редактирование кредита не пересчитывает график платежей.
- Файл: `lib/features/credits/domain/use_cases/update_credit_use_case.dart`
- Риск: UI показывает обновленные параметры кредита со старым schedule.

5. Нет строгой проверки валютной совместимости в ручной оплате кредита.
- Файл: `lib/features/credits/presentation/widgets/pay_credit_sheet.dart`
- Риск: некорректный scale/сумма и финансовая неконсистентность.

6. Частичная идемпотентность ручных платежей.
- Файлы:
  - `lib/core/data/database.dart` (нет unique на `credit_payment_groups.idempotency_key`)
  - `lib/features/credits/domain/use_cases/make_credit_payment_use_case.dart`
- Риск: дубли платежей при повторных отправках.

## Средний приоритет

7. Незавершенный use case редактирования кредитного платежа.
- Файл: `lib/features/credits/domain/use_cases/update_credit_payment_case.dart`
- Риск: технический долг и неявное поведение.

8. Две стратегии расчета аннуитета (UI vs schedule).
- Файлы:
  - `lib/features/credits/domain/utils/credit_calculations.dart`
  - `lib/core/utils/annuity_calculator.dart`
- Риск: расхождения «ожидаемой суммы» и фактического графика.

## Тестовый контур

- Команда: `flutter test test/features/credits test/features/upcoming_payments --reporter expanded`
- Факт: есть компиляционный дефект в `sync_credit_payment_schedule_use_case_test.dart` (фейковый репозиторий не реализует актуальный контракт `CreditRepository`).

## Приоритет исполнения

1) Инварианты платежа + запрет некорректного transfer.
2) Удаление `RUB`-хардкода и валидация валютной совместимости.
3) Дальше: schedule при edit кредита, идемпотентность ручных платежей, расширение тестов.
