# ExecPlan: Виджет «Цель» на Overview + пополнение копилки как перевод между счетами

## Context and Orientation
- Цель: реализовать рабочий виджет «Цель» на `OverviewScreen` на основе существующих `saving_goals` и изменить механику пополнения копилки на перевод с существующего счета (а не расход/виртуальное пополнение).
- Область кода:
  - `lib/features/overview/presentation/overview_screen.dart`
  - `lib/features/overview/presentation/controllers/overview_financial_index_providers.dart`
  - `lib/features/overview/domain/use_cases/`
  - `lib/features/savings/domain/entities/saving_goal.dart`
  - `lib/features/savings/domain/use_cases/add_contribution_use_case.dart`
  - `lib/features/savings/domain/repositories/saving_goal_repository.dart`
  - `lib/features/savings/data/repositories/saving_goal_repository_impl.dart`
  - `lib/features/savings/data/sources/local/saving_goal_dao.dart`
  - `lib/features/savings/data/sources/remote/saving_goal_remote_data_source.dart`
  - `lib/features/savings/presentation/controllers/contribute_controller.dart`
  - `lib/features/savings/presentation/screens/contribute_screen.dart`
  - `lib/core/data/database.dart`
  - `lib/l10n/app_ru.arb`, `lib/l10n/app_en.arb`
  - `test/features/overview/presentation/overview_screen_test.dart`
  - `test/features/savings/domain/use_cases/add_contribution_use_case_test.dart`
  - `test/features/savings/data/saving_goal_repository_impl_test.dart`
  - `docs/logic/feature_invariants.md`, `docs/logic/`
- Контекст/ограничения:
  - Сейчас `_GoalCard` на overview статичен (`0.68`, фиксированный процент/инсайт), без связи с domain.
  - Сейчас `addContribution` при наличии source account создает `TransactionEntity(type: 'expense')` и уменьшает только исходный счет; это не соответствует логике перевода в копилку.
  - В `saving_goals` сейчас нет связи с отдельным счетом копилки; функция не моделирует целевой счет накоплений.
  - Offline-first: запись сначала в локальную БД (Drift), затем outbox/sync.
  - Автоген (`*.g.dart`, `*.freezed.dart`, `*.drift.dart`) вручную не править.
- Риски:
  - Миграция существующих целей и исторических взносов без потери консистентности балансов.
  - Возможные расхождения валют между счетом-источником и счетом-целью копилки.
  - Регрессии в soft-delete транзакций, аналитике и sync payload.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics):
  - Firestore sync для `saving_goal`, `account`, `transaction` (через outbox/auth sync).
- Локальные зависимости (Drift, codegen):
  - Drift миграция схемы (`saving_goals` + индексы/constraints при необходимости).
  - `build_runner` / генерация Freezed/JSON/l10n после изменений моделей.
- Затрагиваемые API/модули:
  - `SavingGoalRepository.addContribution(...)`
  - `TransactionEntity` c `type='transfer'`, `transferAccountId`, `savingGoalId`
  - `WatchSavingGoalsUseCase`/новый overview use case для фокусной цели
  - `ContributeController` и форма пополнения цели

## Plan of Work
- Привязать каждую копилку к отдельному счету накоплений (целевая сторона перевода).
- Перевести сценарий пополнения цели на обязательный перевод `source -> goal account`.
- Подключить Overview Goal card к реальным целям и действию «Пополнить».
- Закрыть изменение тестами, миграцией и документацией инвариантов.

## Concrete Steps
1) Зафиксировать доменную спецификацию «копилка = цель + счет накоплений»
- Добавить в `SavingGoal` поле связи со счетом накоплений (например `accountId`).
- Правило: каждая активная цель имеет связанный счет накоплений; пополнение цели всегда идет переводом с выбранного пользователем исходного счета на этот счет.
- Правило валюты MVP: перевод разрешен только между счетами одной валюты; если валюты не совпадают, UI блокирует submit с явной ошибкой.

2) Drift миграция и backfill данных
- В `saving_goals` добавить колонку связи со счетом (`account_id`, nullable на миграции, далее обязательность на уровне домена).
- Повысить `schemaVersion`, добавить миграционный шаг:
  - для каждой существующей цели создать счет накоплений (например тип `savings`, `isHidden=true`, имя на базе цели);
  - записать связь `saving_goals.account_id`;
  - стартовый баланс нового счета выставить равным `goal.currentAmount`, чтобы восстановить «исчезнувшие» накопления в активах.
- Добавить защиту идемпотентности миграции (повторный запуск не создает дубли счетов).

3) Data/domain слой: перевод вместо расхода
- Обновить `SavingGoalRepository.addContribution(...)` и `AddContributionUseCase`:
  - `sourceAccountId` сделать обязательным для нового сценария;
  - создать `TransactionEntity` с `type='transfer'`, `accountId=source`, `transferAccountId=goal.accountId`, `savingGoalId=goal.id`, `categoryId=null`;
  - обновление `goal.currentAmount` оставить как доменный прогресс (cap до target), но сумма транзакции должна равняться `appliedDelta`.
- Сохранить совместимость с историей:
  - старые взносы `expense` не переписывать массово в миграции;
  - аналитика прогресса цели продолжает опираться на `savingGoalId` и `goal_contributions`.

4) UI пополнения копилки
- В `ContributeScreen` убрать опцию «без счета» и сделать выбор источника обязательным.
- Скрыть недоступные источники:
  - исключить `credit`, `credit_card`, `debt`, скрытые служебные счета накоплений, и сам целевой `goal.accountId`.
- Добавить валидации:
  - сумма > 0;
  - выбран исходный счет;
  - достаточно средств (для MVP по текущему балансу) и совпадает валюта с целевым счетом копилки.
- Обновить тексты/ошибки в l10n под термин «перевод в копилку».

5) Реализация карточки «Цель» в Overview
- Добавить provider/use case для фокусной цели (например ближайшая к достижению из неархивных).
- Заменить статичный `_GoalCard` на `ConsumerWidget`:
  - `data`: имя цели, реальный progress, проценты, краткий insight;
  - `empty`: CTA «Создать цель»;
  - `loading/error`: безопасный fallback.
- Добавить действие «Пополнить», ведущее в `ContributeScreen` выбранной цели.

6) Sync/outbox и совместимость payload
- Обновить сериализацию `SavingGoal` (локально/remote) новым полем связи со счетом.
- Проверить payload транзакции перевода (`type`, `transferAccountId`, `savingGoalId`) для outbox/auth sync.
- Проверить, что sanitizer/sync-поток не удаляет новую связь и корректно переживает частичную синхронизацию.

7) Тесты
- Unit `add_contribution_use_case_test.dart`:
  - ошибка без `sourceAccountId`;
  - cap до target сохраняется;
  - note trim/ошибки валидации.
- Repository `saving_goal_repository_impl_test.dart`:
  - создается `transfer`, а не `expense`;
  - уменьшается исходный счет и увеличивается счет копилки;
  - soft-delete перевода откатывает `goal.currentAmount` и account effects.
- Миграционные тесты Drift:
  - backfill создает счет для существующей цели и проставляет `account_id`;
  - миграция идемпотентна.
- Widget `overview_screen_test.dart`:
  - карточка цели показывает реальные данные;
  - CTA пополнения открывает flow;
  - empty/loading/error состояния.

8) Документация
- Обновить `docs/logic/feature_invariants.md`:
  - копилка пополняется переводом, не расходом;
  - у каждой цели есть связанный счет накоплений.
- Добавить документ `docs/logic/overview_goal_widget.md`:
  - критерий выбора фокусной цели;
  - состояния карточки и сценарий пополнения.
- Обновить индексы `docs/logic/README.md`.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```
- Acceptance criteria:
  - Карточка «Цель» на `OverviewScreen` отображает реальные данные существующих копилок.
  - Пополнение цели всегда оформляется как перевод между счетами (`transfer`) с указанием source и goal account.
  - Для существующих целей после миграции создан связаный счет накоплений и связь сохранена.
  - Нет регрессий в soft-delete/sync и базовых сценариях savings.

## Idempotence and Recovery
- Что можно безопасно перезапускать:
  - `build_runner`, `format`, `analyze`, тесты, локальные миграции в тестовой среде.
- Как откатиться/восстановиться:
  - временно вернуть UI карточки цели в read-only fallback;
  - в `addContribution` временно разрешить legacy-ветку (expense) под feature-flag.
- План rollback (для миграций):
  - колонка `account_id` добавляется как nullable;
  - при rollback код может игнорировать связь и работать в legacy-режиме;
  - backfill-счета остаются как данные пользователя, но не используются новой логикой.

## Progress
- [x] Шаг 1: Спецификация доменной модели «цель + счет накоплений».
- [x] Шаг 2: Миграция Drift + backfill существующих целей.
- [x] Шаг 3: Репозиторий/юзкейс пополнения как `transfer`.
- [x] Шаг 4: Обновление `ContributeScreen` и валидаций.
- [x] Шаг 5: Подключение динамической Goal card на Overview.
- [x] Шаг 6: Sync payload и совместимость.
- [x] Шаг 7: Тесты.
- [x] Шаг 8: Документация.

## Surprises & Discoveries
- Текущая реализация взноса создает `expense` с `savingGoalId`, а не `transfer`, поэтому деньги списываются с исходного счета без явного счета назначения.
- `Overview`-карточка цели сейчас полностью статична и не использует ни один provider целей.
- В схеме уже есть поддержка `transferAccountId` и влияние transfer на балансы, что позволяет реализовать корректную механику без новой таблицы транзакций.

## Decision Log
- Выбрана стратегия «одна цель = один связанный счет накоплений» для корректного двойного эффекта перевода и прозрачности балансов.
- Исторические транзакции взносов не переписываются массово; совместимость обеспечивается через backfill счета и доменную связь `saving_goal -> account`.
- Для MVP конвертацию валют не добавлять; переводы в цель только в одной валюте.

## Outcomes & Retrospective
- Что сделано:
  - Добавлена связь `saving_goal.account_id` и миграция v40 с backfill счета накоплений.
  - Пополнение цели переведено на `transfer` между source account и счетом цели.
  - `ContributeScreen` обновлен: обязательный выбор счета-источника, валидации валюты и доступного остатка.
  - Карточка `Overview` «Цель» подключена к реальным данным с `loading/empty/error` состояниями и действиями.
  - Добавлены/обновлены тесты: use case, repository, migration, widget.
  - Обновлена документация по инвариантам и поведению overview-карточки.
- Что бы улучшить в следующий раз:
  - заранее определить продуктовые правила для мультивалютных целей и отображения скрытых счетов накоплений в аналитике.

## Definition of Done (чек-лист)
- `dart format --set-exit-if-changed .` без изменений.
- `flutter analyze` без ошибок.
- `dart run build_runner build --delete-conflicting-outputs` проходит.
- `flutter test --reporter expanded` проходит.
- Новая логика покрыта unit-тестами и хотя бы одним widget или integration тестом.
- Нет тяжелого CPU/I/O на UI isolate.
- Для миграции есть проверка backfill и rollback-стратегия.

## Regression checklist
- Riverpod: минимизированы лишние rebuild, использованы `.select()`/листовые `ConsumerWidget`.
- Freezed: модели immutable, генерация корректна.
- Drift: миграция добавлена, схема не правится вручную.
- Offline-first: запись сначала в локальную БД.
- Sync: payload содержит `account_id` цели и `transferAccountId`, upsert идемпотентен.
- Accounts balance invariant: перевод уменьшает source и увеличивает goal account одинаковой суммой.
- UI: карточка цели корректно обрабатывает loading/empty/error.

## Документация
- Что изменилось: копилки на overview стали реальными данными, пополнение копилки переведено на модель межсчетного перевода.
- Зачем: убрать логическую ошибку «списание без счета назначения» и сделать накопления консистентными в балансах.
- Как проверить: пополнить цель с банковского счета и убедиться, что создан `transfer`, а балансы source/goal изменились в противоположные стороны.
- Breaking changes: `SavingGoal` расширяется связью со счетом накоплений (`account_id`), взнос без source account больше не поддерживается.
