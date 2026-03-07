# ExecPlan: Развязать TransactionDraftController от прямого AccountRepository

## Context and Orientation
- Цель: убрать прямую зависимость `TransactionDraftController` от `AccountRepository`, чтобы presentation-слой не открывал data path напрямую и чтобы тесты формы транзакции не ходили в реальную БД.
- Область кода: `lib/features/transactions/presentation/controllers/**`, `lib/features/accounts/domain/use_cases/**`, `lib/core/di/injectors.dart`, `test/features/transactions/presentation/controllers/**`.
- Контекст/ограничения: изменение должно сохранить текущее поведение формы транзакции, но доступ к счету должен идти через domain use case/provider.
- Риски: если вынести только часть логики, контроллер все равно останется привязанным к репозиторию через другой побочный путь.

## Interfaces and Dependencies
- Внешние сервисы: не затрагиваются.
- Локальные зависимости: `AccountRepository`, transaction form controller, DI providers.
- Затрагиваемые API/модули: `TransactionDraftController`, account domain use case layer, provider overrides в тестах.

## Plan of Work
- Добавить доменный use case для получения счета по `id`.
- Зарегистрировать его в DI.
- Перевести `TransactionDraftController` на use case вместо прямого репозитория.
- Обновить тесты контроллера и проверить analyze/transaction tests.
- Зафиксировать закрытие находки в аудите.

## Concrete Steps
1) Добавить `GetAccountByIdUseCase` в `lib/features/accounts/domain/use_cases/`.
2) Зарегистрировать provider в `lib/core/di/injectors.dart`.
3) Заменить прямой `accountRepositoryProvider` в `TransactionDraftController` на `getAccountByIdUseCaseProvider`.
4) Обновить `transaction_form_controller_test.dart` и связанные overrides.
5) Обновить аудит и итоговый статус.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded test/features/transactions/presentation/controllers/transaction_form_controller_test.dart
flutter test --reporter expanded test/features/transactions/domain/use_cases/add_transaction_use_case_test.dart test/features/transactions/domain/use_cases/update_transaction_use_case_test.dart test/features/transactions/presentation/transaction_form_view_test.dart
```
- Acceptance criteria:
  - `TransactionDraftController` больше не читает `AccountRepository` напрямую.
  - transaction form controller tests больше не открывают реальную БД через `path_provider`.
  - аудит отражает закрытие находки.

## Idempotence and Recovery
- Что можно безопасно перезапускать: форматирование, analyze, transaction tests, обновление документации.
- Как откатиться/восстановиться: вернуть изменения в use case, DI, controller и тестах.
- План rollback: миграции не затрагиваются.

## Progress
- [x] Шаг 1: Создать ExecPlan.
- [x] Шаг 2: Добавить domain use case/provider.
- [x] Шаг 3: Перевести controller на новый контракт.
- [x] Шаг 4: Обновить тесты и прогнать проверки.
- [x] Шаг 5: Обновить аудит.

## Surprises & Discoveries
- После замены зависимости на use case `transaction_form_controller_test.dart` перестал открывать реальную БД и больше не падает на `path_provider`.
- Полный `test/features/transactions` теперь проходит целиком, то есть проблема действительно была локализована в прямом доступе controller к repository.

## Decision Log
- Выбран отдельный domain use case вместо прямого provider family над repository, чтобы сохранить границы слоев и простой override в тестах.

## Outcomes & Retrospective
- Что сделано:
  - добавлен `GetAccountByIdUseCase` и provider в DI;
  - `TransactionDraftController` переведен на domain use case вместо прямого `AccountRepository`;
  - тесты controller обновлены под новый контракт;
  - аудит обновлен, finding закрыт.
- Проверки:
  - `flutter analyze` без ошибок, только 4 старых `info` в несвязанных тестах;
  - `flutter test --reporter expanded test/features/transactions/presentation/controllers/transaction_form_controller_test.dart` проходит;
  - `flutter test --reporter expanded test/features/transactions` проходит полностью.
- Что бы улучшить в следующий раз: держать presentation-контроллеры только на use case/provider уровне без прямых repository dependency.
