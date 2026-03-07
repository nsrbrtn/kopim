# ExecPlan: Атомарное редактирование платежа по кредиту

## Context and Orientation
- Цель: полностью реализовать `UpdateCreditPaymentUseCase` как атомарную операцию уровня payment group и убрать рассинхрон между payment group, transaction rows и schedule item.
- Область кода: `lib/features/credits/**`, `lib/features/transactions/**`, возможные DI-изменения в `lib/core/di/**`, тесты `test/features/credits/**`.
- Контекст/ограничения: изменение затрагивает критичную бизнес-логику кредитов; необходимо сохранить инварианты суммы, идемпотентности и связи с графиком платежей.
- Риски: частичная реализация может сломать баланс счетов, расписание платежей и историю транзакций; нужны атомарность и проверка всех связанных сущностей.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): не требуются.
- Локальные зависимости (Drift, codegen): Drift-репозитории кредитов и транзакций, Riverpod DI.
- Затрагиваемые API/модули: `CreditRepository`, `TransactionRepository`, `CreditPaymentGroupEntity`, `CreditPaymentScheduleEntity`, экран деталей кредитного платежа.

## Plan of Work
- Поднять текущую модель payment group и операции доступа к ней.
- Реализовать доменный use case редактирования с одной транзакцией.
- Подключить редактирование из UI так, чтобы редактировалась группа, а не одиночные transaction rows.
- Закрыть изменения тестами и обновить аудит.

## Concrete Steps
1) Изучить репозитории/DAO кредитов и транзакций, найти способы читать и обновлять payment group и связанные transaction rows.
2) Реализовать `UpdateCreditPaymentUseCase`:
   - загрузка group и связанных transaction rows;
   - валидация сумм и money context;
   - атомарное обновление payment group;
   - пересчет и обновление schedule item;
   - обновление/удаление/создание transaction rows по principal/interest/fees.
3) Подключить use case в экран деталей платежа и убрать обходной путь через одиночное редактирование транзакции.
4) Добавить unit/integration тесты на редактирование платежной группы.
5) Обновить `docs/logic/business_logic_audit_2026-03-07.md`, зафиксировав закрытие находки.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded test/features/credits
```
- Acceptance criteria:
  - Редактирование платежа обновляет `payment group`, связанные транзакции и `schedule item` согласованно.
  - UI не позволяет обходить доменный сценарий через редактирование отдельных внутренних transaction rows.
  - Есть тесты на сценарии изменения principal/interest/fees.

## Idempotence and Recovery
- Что можно безопасно перезапускать: форматирование, analyze, credit-тесты, локальные изменения docs/ExecPlan.
- Как откатиться/восстановиться: удалить изменения в use case/UI/тестах и вернуть прежнее поведение.
- План rollback (для миграций): не требуется, схема БД не меняется.

## Progress
- [x] Шаг 1: Создать ExecPlan.
- [x] Шаг 2: Изучить зависимости и текущие точки обновления.
- [x] Шаг 3: Реализовать use case и атомарное обновление.
- [x] Шаг 4: Подключить UI.
- [x] Шаг 5: Добавить тесты и обновить аудит.

## Surprises & Discoveries
- Для реализации пришлось расширить контракты `CreditRepository` и `TransactionRepository`, добавив поиск payment group по id, update payment group и выборку transaction rows по `groupId`.
- Внутри `credit_payment_details_screen` не было доменной модели payment group, только агрегированный feed item, поэтому UI редактирования пришлось перевести на групповой сценарий через `PayCreditSheet`.
- Пакет `test/features/credits` проходит целиком после обновления in-memory test doubles под новые интерфейсы.

## Decision Log
- Итоговая реализация должна менять payment group как доменный агрегат, а не редактировать внутренние transaction rows напрямую.

## Outcomes & Retrospective
- Что сделано: реализован `UpdateCreditPaymentUseCase`, добавлены операции data/domain слоя, UI переведен на редактирование payment group, написаны тесты, аудит обновлен.
- Что бы улучшить в следующий раз: держать явную матрицу "aggregate root -> editable UI paths".
