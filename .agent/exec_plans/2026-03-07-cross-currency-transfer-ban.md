# ExecPlan: Жесткий запрет cross-currency transfer без FX

## Context and Orientation
- Цель: запретить переводы между счетами с разной валютой, если в приложении нет FX-модели, и тем самым убрать скрытый расчет "1:1" между валютами.
- Область кода: `lib/features/transactions/**`, связанный UI формы транзакции, тесты `test/features/transactions/**`.
- Контекст/ограничения: запрет должен работать на доменном уровне, а UI должен не подталкивать пользователя к невалидному сценарию.
- Риски: если ограничиться только UI, доменная логика останется дырявой; если ограничиться только domain, UX останется запутанным.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): не затрагиваются.
- Локальные зависимости (Drift, codegen): use case транзакций, presentation controller, widget-тесты формы.
- Затрагиваемые API/модули: `AddTransactionUseCase`, `UpdateTransactionUseCase`, `TransactionDraftController`, `transaction_form_view.dart`.

## Plan of Work
- Проверить все текущие пути создания и обновления transfer-транзакций.
- Добавить доменную валидацию валюты source/target account.
- Ограничить UI выбора target account только счетами той же валюты.
- Закрыть изменения тестами и обновить аудит.

## Concrete Steps
1) Изучить текущую transfer-логику в add/update use case и в форме транзакции.
2) Добавить проверку совпадения валюты source/target в domain use case.
3) Обновить UI перевода, чтобы список target accounts фильтровался по валюте source account.
4) Добавить/обновить unit и widget тесты.
5) Обновить `docs/logic/business_logic_audit_2026-03-07.md`.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded test/features/transactions
```
- Acceptance criteria:
  - transfer между счетами с разной валютой отклоняется на уровне domain.
  - форма перевода не предлагает target accounts с другой валютой.
  - аудит отражает закрытие находки.

## Idempotence and Recovery
- Что можно безопасно перезапускать: форматирование, analyze, transaction-тесты, обновление аудита.
- Как откатиться/восстановиться: вернуть изменения в transaction use case/UI/тестах.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Создать ExecPlan.
- [x] Шаг 2: Изучить текущую логику.
- [x] Шаг 3: Реализовать доменную валидацию.
- [x] Шаг 4: Обновить UI и тесты.
- [x] Шаг 5: Обновить аудит.

## Surprises & Discoveries
- Полный `test/features/transactions` по-прежнему падает не из-за transfer-логики, а из-за уже известной проблемы `TransactionDraftController`, который читает реальный `AccountRepository` в тестах.
- После расширения репозиториев на предыдущих задачах несколько in-memory test doubles в transaction-тестах требовали синхронизации с новыми методами интерфейсов.

## Decision Log
- Запрет должен быть enforced в domain use case, UI только отражает ограничение.

## Outcomes & Retrospective
- Что сделано:
  - добавлен жесткий доменный запрет на перевод между счетами с разной валютой без FX;
  - UI формы перевода ограничен счетами назначения той же валюты;
  - добавлены unit/widget тесты на новый контракт;
  - аудит обновлен и finding закрыт.
- Проверки:
  - `flutter analyze` без ошибок, только 4 старых `info` в несвязанных тестах;
  - `flutter test --reporter expanded test/features/transactions/domain/use_cases/add_transaction_use_case_test.dart test/features/transactions/domain/use_cases/update_transaction_use_case_test.dart test/features/transactions/presentation/transaction_form_view_test.dart` проходит;
  - полный `flutter test --reporter expanded test/features/transactions` все еще падает на известной проблеме `TransactionDraftController`.
- Что бы улучшить в следующий раз: держать обязательный checklist по currency-aware сценариям для всех money операций.
