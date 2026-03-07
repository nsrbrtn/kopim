# ExecPlan: Вычистить подтвержденный dead code

## Context and Orientation
- Цель: удалить подтвержденный dead/legacy code из accounts, analytics, app_shell, budgets и overview, чтобы убрать шум, ложные точки расширения и неиспользуемые DI-регистрации.
- Область кода: `lib/features/accounts/domain/usecases/**`, `lib/features/analytics/presentation/widgets/swipe_hint_arrows.dart`, `lib/features/app_shell/presentation/widgets/main_navigation_rail.dart`, `lib/features/budgets/presentation/budget_detail_screen.dart`, `lib/features/overview/domain/use_cases/watch_overview_goal_focus_use_case.dart`, связанный provider в `lib/core/di/injectors.dart`.
- Контекст/ограничения: удаляем только то, что не имеет потребителей в приложении, тестах, маршрутах и DI-графе.

## Interfaces and Dependencies
- Внешние сервисы: не затрагиваются.
- Локальные зависимости: DI injectors, feature files и аудит.
- Затрагиваемые API/модули: только неподключенные файлы и неподключенный provider.

## Plan of Work
- Подтвердить отсутствие потребителей по репозиторию.
- Удалить отсоединенные файлы и provider.
- Обновить аудит с объяснением назначения каждого удаленного элемента и причины неиспользования.
- Проверить `flutter analyze`.

## Concrete Steps
1) Проверить поиском usage по всем кандидатам.
2) Удалить подтвержденный dead code и сиротские модели/provider.
3) Обновить аудит и пометить cleanup выполненным.
4) Прогнать `flutter analyze`.

## Validation and Acceptance
- Команды проверки:
```bash
flutter analyze
```
- Acceptance criteria:
  - удаленные файлы не имеют потребителей;
  - DI не содержит неиспользуемый `overview_goal_focus` provider;
  - аудит объясняет, что делал код и почему он был мертвым.

## Idempotence and Recovery
- Что можно безопасно перезапускать: поиск usage, analyze, обновление аудита.
- Как откатиться/восстановиться: вернуть удаленные файлы и provider.
- План rollback: миграции не затрагиваются.

## Progress
- [x] Шаг 1: Подтвердить отсутствие usage.
- [x] Шаг 2: Удалить dead code и provider.
- [x] Шаг 3: Обновить аудит.
- [x] Шаг 4: Прогнать analyze.

## Surprises & Discoveries
- `overview_goal_focus` use case был зарегистрирован в DI, но не использовался ни в приложении, ни в тестах; после его удаления сиротской стала и модель `OverviewGoalFocus`.
- После удаления пользователь уточнил, что экран бюджета и логика копилки могут еще понадобиться, поэтому эти два кандидата нельзя считать окончательно мертвыми без дополнительной продуктовой проверки.

## Decision Log
- Удаление выполнено только после подтверждения отсутствия прямых ссылок, маршрутов, provider consumers и тестов.

## Outcomes & Retrospective
- Что сделано:
  - удалены legacy `accounts/domain/usecases/**`;
  - удалены неподключенные `SwipeHintArrows` и `MainNavigationRail`;
  - удалены только подтвержденные legacy-фрагменты без продуктовой неопределенности;
  - `BudgetDetailScreen` и `overview_goal_focus` восстановлены по запросу пользователя;
  - аудит обновлен с пояснением, какие кандидаты удалены, а какие возвращены в ручную проверку.
- Проверки:
  - `flutter analyze` без ошибок и warning, остались только 4 старых `info` в несвязанных тестах.
- Что бы улучшить в следующий раз:
  - периодически прогонять поиск по provider-графу и orphan screens/widgets, чтобы такие остатки не копились.
