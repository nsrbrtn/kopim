# ExecPlan: Виджеты долга во вкладке «Кредиты» аналитики

## Context and Orientation
- Цель: добавить во вкладку «Кредиты» экрана аналитики два виджета: «Общая сумма долга» и «Динамика долга» (6 месяцев).
- Область кода: `lib/features/analytics/presentation/analytics_screen.dart`, `lib/features/analytics/presentation/controllers/analytics_providers.dart`, `lib/l10n/*.arb`, `test/features/analytics/presentation/analytics_screen_test.dart`, `docs/logic/analytics.md`.
- Контекст/ограничения: использовать тему Kopim и существующие зависимости (Syncfusion), не менять схему БД, не править вручную автоген `*.g.dart/*.freezed.dart/*.drift.dart`.
- Риски: неоднозначность трактовки долга по знаку баланса разных liability-счетов; риск лишних rebuild в аналитике.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): нет.
- Локальные зависимости (Drift, codegen): Riverpod-провайдеры, стрим транзакций/счетов, генерация l10n.
- Затрагиваемые API/модули:
  - `analyticsAccountsProvider`, `transactionRepositoryProvider`
  - `watchTransactions()` для построения 6-месячного тренда долга
  - `AppLocalizations` для новых подписей.

## Plan of Work
- Добавить доменную агрегацию долга в analytics-провайдерах.
- Реализовать UI вкладки «Кредиты» по макету (две карточки).
- Добавить/обновить локализацию и документацию.
- Прогнать формат и целевые тесты.

## Concrete Steps
1) Реализовать в `analytics_providers.dart` провайдер сводки долга (текущий total + trend за 6 месяцев + delta текущего месяца).
2) Заменить placeholder вкладки «Кредиты» на реальный `CreditsAnalyticsTabView` с двумя карточками и линейным графиком.
3) Добавить l10n-ключи для заголовков/подписей виджетов и статуса изменений.
4) Добавить/обновить widget-тест аналитики на наличие новых блоков во вкладке «Кредиты».
5) Обновить `docs/logic/analytics.md` с описанием новой вкладки.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed lib/features/analytics/presentation/controllers/analytics_providers.dart lib/features/analytics/presentation/analytics_screen.dart test/features/analytics/presentation/analytics_screen_test.dart docs/logic/analytics.md
flutter test test/features/analytics/presentation/analytics_screen_test.dart
flutter test test/features/analytics/presentation/controllers/analytics_providers_test.dart
```
- Acceptance criteria:
  - Во вкладке «Кредиты» отображаются карточки «Общая сумма долга» и «Динамика долга».
  - Общая сумма долга считается по liability-счетам (`credit`, `credit_card`, `debt`, включая `custom:`-префикс).
  - График показывает 6 последних месяцев и не падает на пустых данных.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `dart format`, тесты, генерацию l10n.
- Как откатиться/восстановиться: откатить изменения в `analytics_*` файлах и `arb`.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Подготовить ExecPlan и зафиксировать scope.
- [x] Шаг 2: Реализовать провайдеры агрегатов долга.
- [x] Шаг 3: Реализовать UI вкладки «Кредиты».
- [x] Шаг 4: Добавить l10n + тесты + документацию.
- [x] Шаг 5: Прогнать проверки.

## Surprises & Discoveries
- В текущей реализации вкладка «Кредиты» — placeholder.
- Для корректного учета liability-типов требуется нормализация account type.

## Decision Log
- Выбран подход с вычислением тренда долга на основе `watchTransactions()` + текущих/стартовых балансов liability-счетов.

## Outcomes & Retrospective
- Что сделано: добавлены карточки «Общая сумма долга» и «Динамика долга» во вкладке «Кредиты», реализованы агрегаты по liability-счетам и 6-месячный тренд, обновлены l10n, тесты и документация.
- Что бы улучшить в следующий раз: вынести debt-chart в отдельный переиспользуемый виджет и добавить отдельные unit-тесты на расчет тренда по знаку баланса.
