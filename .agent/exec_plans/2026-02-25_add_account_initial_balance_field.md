# ExecPlan: Поле начального баланса при добавлении счета

## Context and Orientation
- Цель: добавить/обеспечить поле начального баланса в сценарии создания счета, включая кредитную карту.
- Область кода: `lib/features/accounts/presentation/accounts_add_screen.dart`, `lib/features/accounts/presentation/controllers/add_account_form_controller.dart`, тесты контроллера.
- Контекст/ограничения: использовать текущие компоненты формы; не изменять автоген-файлы вручную.
- Риски: регресс валидации формы для кредитных карт и в поведении сохранения счета.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): нет.
- Локальные зависимости (Drift, codegen): не требуются.
- Затрагиваемые API/модули: форма добавления счета, доменная сущность `AccountEntity` (заполнение `balanceMinor` и `openingBalanceMinor`).

## Plan of Work
- Включить поле баланса в UI для всех типов счета.
- Привести валидацию/сохранение баланса к единому поведению.
- Обновить тесты и документацию изменения UX.

## Concrete Steps
1) Убрать скрытие поля баланса для `credit_card` в `accounts_add_screen.dart`.
2) В `add_account_form_controller.dart` валидировать баланс для всех типов счета и сохранять введенное значение в `balanceMinor/openingBalanceMinor`.
3) Обновить тесты контроллера добавления счета.
4) Обновить `docs/logic/` запись о поведении формы и прогнать проверки.

## Validation and Acceptance
- Команды проверки:
```bash
dart format lib/features/accounts/presentation/accounts_add_screen.dart lib/features/accounts/presentation/controllers/add_account_form_controller.dart test/features/accounts/presentation/controllers/add_account_form_controller_test.dart
flutter analyze lib/features/accounts/presentation/accounts_add_screen.dart lib/features/accounts/presentation/controllers/add_account_form_controller.dart
flutter test test/features/accounts/presentation/controllers/add_account_form_controller_test.dart --reporter expanded
```
- Acceptance criteria:
  - На экране добавления счета есть поле начального баланса и для кредитной карты.
  - Значение начального баланса сохраняется в созданный `AccountEntity`.
  - Некорректный ввод начального баланса валидируется ошибкой.

## Idempotence and Recovery
- Что можно безопасно перезапускать: форматирование, analyze, тест.
- Как откатиться/восстановиться: откатить изменения в UI/контроллере/тестах.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Создать ExecPlan.
- [x] Шаг 2: Обновить UI и контроллер.
- [x] Шаг 3: Обновить тесты.
- [x] Шаг 4: Обновить документацию и проверить.

## Surprises & Discoveries
- Для `credit_card` начальный баланс раньше не вводился и принудительно устанавливался в `0`, поэтому значение в форме игнорировалось.

## Decision Log
- Поле баланса трактуется как начальный баланс, поэтому для кредитной карты оно должно быть доступно в создании счета.

## Outcomes & Retrospective
- Что сделано:
  - Поле начального баланса отображается на форме добавления счета для всех типов.
  - Валидация баланса унифицирована для всех типов счета.
  - Добавлен тест на сохранение начального баланса для `credit_card`.
  - Обновлена документация в `docs/logic/`.
- Что бы улучшить в следующий раз:
