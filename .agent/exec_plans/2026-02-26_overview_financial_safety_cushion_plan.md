# ExecPlan: Внедрение функции «Финансовая подушка» на OverviewScreen

## Context and Orientation
- Цель: заменить статичную карточку `_SafetyPillowCard` на рабочую функцию расчета и отображения финансовой подушки на `OverviewScreen`.
- Область кода:
  - `lib/features/overview/presentation/overview_screen.dart`
  - `lib/features/overview/presentation/controllers/overview_financial_index_providers.dart`
  - `lib/features/overview/domain/models/`
  - `lib/features/overview/domain/use_cases/`
  - `test/features/overview/domain/use_cases/`
  - `test/features/overview/presentation/overview_screen_test.dart`
  - `lib/l10n/app_ru.arb`, `lib/l10n/app_en.arb`
  - `docs/logic/`, `docs/components/`
- Контекст/ограничения:
  - карточка подушки сейчас хардкожена (`7.4 / 10 мес`, `progress: 0.74`);
  - в проекте уже есть расчет safety-фактора внутри `WatchFinancialIndexUseCase`, но он не отдает отдельную модель для UI карточки;
  - offline-first, source-of-truth — локальные репозитории;
  - не править автоген (`*.g.dart`, `*.freezed.dart`) вручную.
- Риски:
  - дублирование бизнес-логики между финансовым индексом и карточкой подушки;
  - нестабильность метрики при малом объеме транзакций;
  - неоднозначность «целевого срока подушки» (по умолчанию/из настроек/из целей накоплений).

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): нет.
- Локальные зависимости (Drift, codegen): без изменений схемы БД; возможна генерация l10n.
- Затрагиваемые API/модули:
  - `AccountRepository.watchAccounts()`;
  - `TransactionRepository.watchTransactions()`;
  - `SavingGoalRepository.watchGoals(includeArchived: false)`;
  - `OverviewPreferencesController` (опционально — настройка target months).

## Plan of Work
- Выделить доменную модель подушки и use case для потокового расчета.
- Переиспользовать/вынести общую safety-математику из `WatchFinancialIndexUseCase`, чтобы избежать расхождений.
- Подключить новый provider к `OverviewScreen` и заменить статичную карточку.
- Добавить unit/widget тесты и обновить документацию.

## Concrete Steps
1) Спецификация метрики подушки
- Зафиксировать формулу MVP:
  - `liquidAssets` = сумма балансов ликвидных счетов (без `credit`, `credit_card`, `debt`);
  - `avgMonthlyExpense3m` = средние расходы за 3 последних месяца;
  - `monthsCovered = liquidAssets / max(avgMonthlyExpense3m, 1)` с ограничением сверху (например 12);
  - `targetMonths` = 6 по умолчанию (или значение из настроек, если добавим);
  - `progress = clamp(monthsCovered / targetMonths, 0..1)`.
- Определить UX-правила для edge-cases:
  - нет транзакций и нет активов;
  - отрицательный/нулевой баланс;
  - экстремально высокое покрытие.

2) Доменная модель и use case
- Добавить модель `OverviewSafetyCushion` (например: `monthsCovered`, `targetMonths`, `progress`, `liquidAssets`, `avgMonthlyExpense`, `state`).
- Реализовать `WatchOverviewSafetyCushionUseCase` как stream-комбинацию accounts + transactions + saving goals.
- Вынести общий расчет safety в отдельный helper/service (например `overview/domain/services/safety_cushion_calculator.dart`) и использовать его:
  - в новом use case карточки;
  - в `WatchFinancialIndexUseCase` для `safetyScore`.

3) Provider и интеграция в экран
- Добавить `overviewSafetyCushionProvider` в `overview_financial_index_providers.dart`.
- Переделать `_SafetyPillowCard` в `ConsumerWidget`:
  - loading: skeleton/placeholder;
  - data: динамический subtitle (`X.X / Y мес`) + прогресс;
  - error: безопасный fallback без хардкода метрики.
- Привести цвета прогресса к зоне риска/стабильности (единые правила с индексом, если применимо).

4) Локализация
- Заменить статичную строку `overviewSafetyPillowSubtitle` на параметризованную, например:
  - `overviewSafetyPillowSubtitleProgress(monthsCovered, targetMonths)`.
- Добавить строки для empty/error состояний карточки.

5) Тестирование
- Unit: `watch_overview_safety_cushion_use_case_test.dart`:
  - базовый сценарий расчета;
  - отсутствие расходов;
  - только liability-счета;
  - отрицательный баланс;
  - проверка clamp и округления.
- Unit: проверить, что `WatchFinancialIndexUseCase` использует ту же safety-логику (без регрессии формулы).
- Widget: расширить `overview_screen_test.dart`:
  - карточка подушки рендерит динамический subtitle и progress;
  - при ошибке не показывает старый хардкод `7.4 / 10`.

6) Документация
- Обновить `docs/logic/feature_invariants.md` (источник и формула подушки).
- Добавить/обновить документ в `docs/components/` по поведению карточки на `OverviewScreen`.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```
- Acceptance criteria:
  - Карточка «Финансовая подушка» на `OverviewScreen` строится из реальных данных, без хардкода.
  - Метрика подушки и safety-фактор индекса используют консистентную формулу.
  - Динамические тексты локализованы на RU/EN.
  - Unit и widget тесты покрывают базовые и edge-сценарии.

## Idempotence and Recovery
- Что можно безопасно перезапускать: форматирование, анализатор, build_runner, тесты.
- Как откатиться/восстановиться:
  - вернуть `_SafetyPillowCard` к статичному отображению;
  - временно отключить `overviewSafetyCushionProvider`;
  - оставить расчет safety только внутри индекса.
- План rollback (для миграций): не требуется (миграций БД нет).

## Progress
- [x] Шаг 1: Зафиксировать формулу и edge-case правила подушки.
- [x] Шаг 2: Добавить модель и use case `WatchOverviewSafetyCushionUseCase`.
- [x] Шаг 3: Вынести/переиспользовать общую safety-математику.
- [x] Шаг 4: Подключить provider и обновить `_SafetyPillowCard`.
- [x] Шаг 5: Обновить l10n и тесты.
- [x] Шаг 6: Обновить docs.

## Surprises & Discoveries
- В `OverviewScreen` карточка `_SafetyPillowCard` полностью статическая.
- В проекте уже реализован safety-расчет внутри `WatchFinancialIndexUseCase`; его нужно переиспользовать, чтобы не дублировать логику.
- `flutter analyze` падает на существующем `info` вне текущих изменений:
  `test/features/analytics/presentation/controllers/analytics_providers_test.dart:960` (`always_specify_types`).

## Decision Log
- Выбрана стратегия «единый калькулятор safety-метрики» вместо копирования формулы в несколько use case.
- Целевое покрытие подушки в MVP: `6 месяцев` по умолчанию с возможностью вынести в настройки позже.

## Outcomes & Retrospective
- Что сделано:
  - добавлена доменная модель и потоковый use case подушки;
  - вынесен единый `SafetyCushionCalculator` и подключен в финансовый индекс;
  - карточка на `OverviewScreen` переведена на реальные данные с loading/error fallback;
  - добавлены новые l10n ключи RU/EN и обновлены widget/unit тесты;
  - обновлена документация в `docs/logic/`.
- Что бы улучшить в следующий раз: вынести `targetMonths` в пользовательские настройки overview.

## Definition of Done (чек-лист)
- `dart format --set-exit-if-changed .` без изменений.
- `flutter analyze` без ошибок.
- `dart run build_runner build --delete-conflicting-outputs` проходит.
- `flutter test --reporter expanded` проходит.
- Новая логика покрыта unit-тестами и минимум одним widget-тестом.
- Нет тяжелых вычислений в `build`.

## Regression checklist
- Riverpod: нет лишних rebuild, использованы точечные provider-ы.
- Domain: расчет детерминирован и не зависит от Flutter-слоя.
- Формула safety едина для карточки и финансового индекса.
- L10n: нет хардкода пользовательских строк.
- UI: корректные loading/error/empty состояния карточки.

## Документация
- Что изменилось: карточка «Финансовая подушка» стала рассчитываться из реальных данных.
- Зачем: убрать статичную метрику и показать фактический запас месяцев расходов.
- Как проверить: изменить баланс/историю расходов и убедиться, что карточка пересчитывается.
- Breaking changes: нет.
