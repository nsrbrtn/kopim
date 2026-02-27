# ExecPlan: Точный календарь активности на экране профиля

## Context and Orientation
- Цель: заменить агрегированную подсветку активности на профиле точным календарем за последние 7 дней по фактическим датам транзакций.
- Область кода: `lib/features/profile/presentation/widgets/profile_management_body.dart`, `lib/features/profile/presentation/controllers/`, `test/features/profile/`.
- Контекст/ограничения: offline-first, без изменений схемы БД и без тяжелой логики в `build`; использовать текущие потоки данных Riverpod.
- Риски: лишние rebuild из-за стримов, ошибки с локальными датами и границами дней.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): не затрагиваются.
- Локальные зависимости (Drift, codegen): используется поток транзакций из репозитория.
- Затрагиваемые API/модули: `transactionRepositoryProvider`, `ProfileManagementBody`, виджет `_ActivitySection`.

## Plan of Work
- Добавить профильный провайдер активных дней за окно 7 дней.
- Переключить UI активности на работу с точным набором дат.
- Добавить unit-тест расчета активных дней.

## Concrete Steps
1) Реализовать `profile_activity_days_provider` с вычислением активных дат из транзакций.
2) Обновить `_ActivitySection` в профиле: подсветка по реальным датам, а не по агрегированному числу.
3) Добавить unit-тесты на функцию расчета активных дней (границы окна, дедупликация дат, игнор вне окна).
4) Выполнить `dart format` и `flutter analyze` по затронутым файлам.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed lib/features/profile/presentation
flutter analyze lib/features/profile/presentation/widgets/profile_management_body.dart lib/features/profile/presentation/controllers/profile_activity_days_provider.dart test/features/profile/presentation/controllers/profile_activity_days_provider_test.dart
```
- Acceptance criteria:
  - Активность на профиле отмечает именно те дни, в которые есть транзакции в последние 7 дней.
  - Несколько транзакций в один день подсвечивают только один день.
  - Дни вне окна (старше 6 дней и будущие) не подсвечиваются.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `dart format`, `flutter analyze`, unit-тест.
- Как откатиться/восстановиться: откат изменений в новых/измененных файлах профиля.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Подготовлен ExecPlan.
- [x] Шаг 2: Добавлен провайдер активных дней.
- [x] Шаг 3: Обновлен UI карточки активности.
- [x] Шаг 4: Добавлены unit-тесты.
- [x] Шаг 5: Выполнены проверки форматирования и анализа.

## Surprises & Discoveries
- Текущий блок активности использовал агрегированную метрику из `OverviewBehaviorProgress`, а не реальные даты последних 7 дней.

## Decision Log
- Для точности выбран отдельный профильный провайдер активных дат, который вычисляет `Set<DateTime>` из стрима транзакций.

## Outcomes & Retrospective
- Что сделано:
- Добавлен `profileActivityDaysProvider` и функция `resolveProfileActiveDaysForWindow`.
- Карточка активности на профиле переведена на точную подсветку дней по фактическим датам транзакций.
- Добавлены unit-тесты на дедупликацию и фильтрацию по окну дат.
- Что бы улучшить в следующий раз:
- Добавить widget-тест, проверяющий конкретную подсветку 7 ячеек в `_ActivitySection`.
