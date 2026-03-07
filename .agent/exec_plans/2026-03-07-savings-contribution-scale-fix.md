# ExecPlan: Исправление масштаба суммы при пополнении копилки

## Context and Orientation
- Цель: убрать жесткую привязку пополнения копилки к `scale=2` и перевести расчет на корректную работу с minor units и фактическим `currencyScale`.
- Область кода: `lib/features/savings/**`, связанные тесты `test/features/savings/**`.
- Контекст/ограничения: пополнение копилки должно оставаться атомарной DB-операцией и не ломать инварианты transfer + goal contribution.
- Риски: ошибка в пересчете minor units повредит баланс исходного счета, счета копилки и прогресс цели.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): не затрагиваются.
- Локальные зависимости (Drift, codegen): Drift DAO savings/accounts/transactions.
- Затрагиваемые API/модули: `SavingGoalRepositoryImpl.addContribution`, тесты репозитория копилок.

## Plan of Work
- Проверить текущий путь формирования суммы перевода.
- Исправить расчет на прямую работу с minor units.
- Добавить тест на валютный scale, отличный от 2.
- Обновить аудит как закрытую находку.

## Concrete Steps
1) Изучить `SavingGoalRepositoryImpl.addContribution` и текущие тесты contributions.
2) Заменить перевод через `appliedDelta / 100` на создание денежного значения из minor units с корректным scale.
3) Добавить тестовый сценарий для `currencyScale != 2`.
4) Прогнать форматирование, анализ и релевантные savings-тесты.
5) Обновить `docs/logic/business_logic_audit_2026-03-07.md`.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded test/features/savings
```
- Acceptance criteria:
  - Сумма перевода в копилку не зависит от предположения `scale=2`.
  - Для `scale != 2` сохраняются корректные `amountMinor/amountScale`.
  - Аудит отражает закрытие находки.

## Idempotence and Recovery
- Что можно безопасно перезапускать: форматирование, analyze, savings-тесты, обновление аудита.
- Как откатиться/восстановиться: вернуть изменения в `SavingGoalRepositoryImpl`, тестах и документе аудита.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Создать ExecPlan.
- [x] Шаг 2: Изучить реализацию и тесты.
- [x] Шаг 3: Исправить расчет суммы.
- [x] Шаг 4: Обновить тесты.
- [x] Шаг 5: Обновить аудит.

## Surprises & Discoveries
- Для корректного исправления недостаточно было заменить `/ 100` на `fromMinor`; scale тоже нужно брать из `sourceAccountRow.currencyScale`, а не из `resolveCurrencyScale(currency)`.
- После расширения `TransactionRepository` пришлось обновить один savings test double под новый контракт `findByGroupId`.

## Decision Log
- Исправление должно работать через minor units без промежуточного `double`.

## Outcomes & Retrospective
- Что сделано: исправлен расчет суммы пополнения копилки на работу через minor units и фактический scale, добавлен тест на `currencyScale != 2`, аудит обновлен.
- Что бы улучшить в следующий раз: держать обязательные тесты на разные `currencyScale` для всех money-sensitive сценариев.
