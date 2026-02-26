# ExecPlan: Виджет «Поведенческий прогресс» на Overview

## Context and Orientation
- Цель: заменить статичный `_BehaviorProgressCard` на карточку с реальными данными поведенческой дисциплины и стрика на `OverviewScreen`.
- Область кода:
  - `lib/features/overview/presentation/overview_screen.dart`
  - `lib/features/overview/presentation/controllers/overview_financial_index_providers.dart`
  - `lib/features/overview/domain/models/`
  - `lib/features/overview/domain/services/`
  - `lib/features/overview/domain/use_cases/`
  - `test/features/overview/domain/`
  - `test/features/overview/presentation/overview_screen_test.dart`
  - `lib/l10n/app_ru.arb`, `lib/l10n/app_en.arb`
  - `docs/logic/`
- Контекст/ограничения:
  - `_BehaviorProgressCard` сейчас полностью статичен (`x6`, фиксированный subtitle из l10n).
  - `disciplineScore` уже рассчитывается в `WatchFinancialIndexUseCase`, но не отдается как отдельная модель для карточки.
  - offline-first, source-of-truth — локальные репозитории (`watchAccounts`, `watchTransactions`).
  - автоген-файлы (`*.g.dart`, `*.freezed.dart`, `*.drift.dart`) не редактировать вручную.
- Риски:
  - дублирование формул дисциплины между финансовым индексом и карточкой.
  - несогласованность отображения при пустой истории/ошибках стрима.
  - лишние rebuild в `OverviewScreen`, если неверно выбрать уровень provider-ов.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): нет.
- Локальные зависимости (Drift, codegen): схема БД без изменений; возможна только генерация l10n.
- Затрагиваемые API/модули:
  - `AccountRepository.watchAccounts()`
  - `TransactionRepository.watchTransactions()`
  - `OverviewPreferencesController` (фильтр счетов/категорий)
  - `WatchFinancialIndexUseCase` и формула `disciplineScore`

## Plan of Work
- Выделить единый доменный расчет поведенческой дисциплины (score + streak + activeDays) в отдельный сервис.
- Добавить отдельный use case/provider для карточки «Поведенческий прогресс».
- Подключить provider к `OverviewScreen`, заменить статичный текст на динамический, добавить состояния loading/error/empty.
- Закрыть изменение unit/widget тестами и обновить документацию поведения.

## Concrete Steps
1) Уточнить спецификацию метрики карточки
- Зафиксировать, что карточка использует те же базовые данные, что и `disciplineScore` в индексе:
  - окно 30 дней;
  - `activeDays` — количество дней с >= 1 транзакцией;
  - `streakDays` — непрерывные дни от `reference` назад;
  - `disciplineScore` — текущая формула (consistency + streak с весами 60/40).
- Зафиксировать правила UI:
  - value: `x{streakDays}` (или `x0` при отсутствии активности);
  - subtitle: локализованная строка вида «N дней осознанного учета подряд»;
  - progress bar: `disciplineScore / 100`.

2) Вынести общую математику дисциплины
- Добавить сервис, например:
  - `lib/features/overview/domain/services/behavior_discipline_calculator.dart`.
- В сервисе вернуть структурированный результат, например:
  - `OverviewBehaviorProgress` (`disciplineScore`, `streakDays`, `activeDays30d`, `progress`).
- Перевести `WatchFinancialIndexUseCase` на использование нового сервиса вместо локальной `_computeDisciplineScore`, чтобы избежать расхождений.

3) Добавить use case и provider для Overview карточки
- Добавить `WatchOverviewBehaviorProgressUseCase` (stream) в `lib/features/overview/domain/use_cases/`.
- Источники:
  - `watchAccounts()` + `watchTransactions()`;
  - фильтры `OverviewPreferences` для согласованности с индексом.
- Добавить `overviewBehaviorProgressProvider` в
  `overview_financial_index_providers.dart`.

4) Интеграция в UI
- Переделать `_BehaviorProgressCard` из `StatelessWidget` в `ConsumerWidget`.
- Подключить `overviewBehaviorProgressProvider` и реализовать состояния:
  - `loading`: subtitle loading + нейтральный `x--`;
  - `data`: реальный `streak`/subtitle/progress;
  - `error`: безопасный fallback без старого хардкода `x6`.
- Цвет value/progress привязать к зонам (`_zoneColorForScore`) для единообразия с другими метриками.

5) Локализация
- Заменить статичные ключи на параметризованные:
  - `overviewBehaviorProgressSubtitleStreak(days)`
  - `overviewBehaviorProgressValueMultiplier(streak)`
  - ключи для `loading`/`unavailable`.
- Обновить `app_ru.arb` и `app_en.arb` + проверить генерацию l10n.

6) Тесты
- Unit:
  - `behavior_discipline_calculator_test.dart`:
    - пустая история;
    - активность в отдельные дни;
    - длинный streak;
    - clamp для score/progress.
  - `watch_financial_index_use_case_test.dart`:
    - проверка, что `disciplineScore` берется из общего сервиса без регрессии формулы.
  - `watch_overview_behavior_progress_use_case_test.dart`:
    - фильтры аккаунтов/категорий;
    - loading/error/data сценарии.
- Widget:
  - расширить `test/features/overview/presentation/overview_screen_test.dart`:
    - карточка рендерит динамические subtitle/value;
    - при ошибке не показывает `x6`.

7) Документация
- Обновить `docs/logic/financial_index.md` (источник `disciplineScore` через общий сервис).
- Добавить документ `docs/logic/overview_behavior_progress.md` с формулой, edge-cases и UI-состояниями.
- Обновить `docs/logic/README.md` ссылкой на новый документ.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```
- Acceptance criteria:
  - Карточка «Поведенческий прогресс» на `OverviewScreen` отображает реальные данные, без хардкода.
  - Формула дисциплины едина для индекса и карточки.
  - При loading/error карточка показывает корректные fallback-состояния.
  - Unit + widget тесты покрывают базовые и edge-сценарии.

## Idempotence and Recovery
- Что можно безопасно перезапускать:
  - форматирование, анализ, генерацию l10n, тесты.
- Как откатиться/восстановиться:
  - временно вернуть `_BehaviorProgressCard` к статичному виду;
  - отключить `overviewBehaviorProgressProvider`;
  - оставить расчет дисциплины только внутри индекса.
- План rollback (для миграций): не требуется (миграций нет).

## Progress
- [x] Шаг 1: Зафиксировать спецификацию метрики и UI-правила карточки.
- [x] Шаг 2: Вынести общий `BehaviorDisciplineCalculator`.
- [x] Шаг 3: Добавить `WatchOverviewBehaviorProgressUseCase` и provider.
- [x] Шаг 4: Перевести `_BehaviorProgressCard` на реальные данные.
- [x] Шаг 5: Обновить l10n-строки и fallback-состояния.
- [x] Шаг 6: Добавить/обновить unit и widget тесты.
- [x] Шаг 7: Обновить документацию в `docs/logic/`.

## Surprises & Discoveries
- В `OverviewScreen` карточка поведенческого прогресса не подключена к данным и полностью статична.
- Доменная логика `disciplineScore` уже есть, поэтому выгоднее рефакторинг к общему сервису, чем новая формула.

## Decision Log
- Выбрана стратегия переиспользования текущей формулы дисциплины через единый сервис, чтобы индекс и карточка не расходились.
- Для MVP сохраняется окно `30 дней` и cap стрика `14 дней` (как в текущем расчете индекса).

## Outcomes & Retrospective
- Что сделано:
  - Подготовлен пошаговый ExecPlan реализации функции «Поведенческий прогресс» для `OverviewScreen`.
- Что бы улучшить в следующий раз:
  - заранее зафиксировать продуктовые требования по текстам для `streak=0` и очень длинных серий.

## Definition of Done (чек-лист)
- `dart format --set-exit-if-changed .` без изменений.
- `flutter analyze` без ошибок.
- `dart run build_runner build --delete-conflicting-outputs` проходит.
- `flutter test --reporter expanded` проходит.
- Новая логика покрыта unit-тестами и хотя бы одним widget-тестом.
- Нет тяжелого CPU/I/O на UI isolate.

## Regression checklist
- Riverpod: минимум лишних rebuild, точечные provider-ы.
- Domain: единая формула дисциплины без дублирования.
- UI: нет хардкода значений `x6`/фиксированных строк.
- L10n: все пользовательские строки локализованы.
- Offline-first: данные берутся из локальных репозиториев/стримов.

## Документация
- Что изменилось: карточка «Поведенческий прогресс» стала рассчитываться из реальных данных транзакционной активности.
- Зачем: убрать статику и дать пользователю актуальный `streak` и прогресс дисциплины.
- Как проверить: добавить/удалить транзакции за последние дни и проверить пересчет карточки.
- Breaking changes: нет.
