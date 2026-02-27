# ExecPlan: Оптимизация форматтеров на домашнем экране

## Context and Orientation
- Цель: убрать повторную аллокацию `DateFormat`/`NumberFormat` в горячих участках домашнего экрана.
- Область кода: `lib/features/home/presentation/screens/home_screen.dart`, `lib/features/home/presentation/widgets/home_overview_summary_card.dart`, `lib/features/home/presentation/widgets/home_upcoming_items_card.dart`, `AUDIT_home_screen_2026-02-27.md`.
- Контекст/ограничения: без изменения UX и бизнес-логики, только оптимизация аллокаций в UI.
- Риски: случайно изменить формат отображения сумм/дат при рефакторинге.

## Interfaces and Dependencies
- Внешние сервисы: нет.
- Локальные зависимости: `intl`, `TransactionTileFormatters`.
- Затрагиваемые модули: home presentation widgets/screens.

## Plan of Work
- Убрать создание форматтеров внутри `itemBuilder` и повторяющихся leaf-виджетов.
- Переиспользовать кешируемые/предрасчитанные форматтеры на уровень выше.
- Обновить аудит с фиксацией выполнения.

## Concrete Steps
1) `home_screen.dart`: предрасчитать currency-форматтеры по валютам и использовать в карусели счетов.
2) `home_overview_summary_card.dart`: заменить `NumberFormat.simpleCurrency` на кешированный symbol provider.
3) `home_upcoming_items_card.dart`: вынести `DateFormat`/`NumberFormat` из дочерних элементов, пробрасывать готовые форматтеры.
4) Проверить `flutter analyze` и отметить шаг в `AUDIT_home_screen_2026-02-27.md`.

## Validation and Acceptance
- Команды проверки:
```bash
flutter analyze lib/features/home
```
- Acceptance criteria:
  - В hot path нет создания `NumberFormat.currency(...)`/`DateFormat(...)` внутри itemBuilder/каждого элемента списка.
  - Поведение UI не меняется.

## Idempotence and Recovery
- Безопасно перезапускать: `flutter analyze`.
- Откат: вернуть изменения в перечисленных файлах.

## Progress
- [x] Шаг 1: Оптимизированы форматтеры в `home_screen.dart`.
- [x] Шаг 2: Оптимизирован форматтер в `home_overview_summary_card.dart`.
- [x] Шаг 3: Оптимизированы форматтеры в `home_upcoming_items_card.dart`.
- [x] Шаг 4: Обновлен аудит и выполнена проверка.

## Surprises & Discoveries
- В проекте уже есть кеш `TransactionTileFormatters`, поэтому оптимизация сделана через его переиспользование и подъем форматтеров на уровень выше в дереве виджетов.

## Decision Log
- Для счетов: предрасчет форматтеров по уникальной валюте и `decimalDigits`.
- Для Upcoming: один `DateFormat` на row и кеш `NumberFormat` по `scale` на карточку секции.

## Outcomes & Retrospective
- Что сделано:
- Убрано создание `NumberFormat.currency(...)` внутри `itemBuilder` карусели счетов.
- Убрано создание `DateFormat/NumberFormat` на каждом элементе Upcoming.
- В overview заменен `simpleCurrency` на кешированный `fallbackCurrencySymbol`.
- Что бы улучшить в следующий раз:
