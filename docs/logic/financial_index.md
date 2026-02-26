# Финансовый индекс (Feature Overview)

## Обзор
`Финансовый индекс` — агрегированный показатель `0..100`, который показывает общее состояние финансов пользователя.

На этапе 1 зафиксированы:
- формула расчета с весами;
- диапазоны статусов;
- правила нормализации и округления.

## Формула
Индекс рассчитывается как взвешенная сумма 4 факторов:

- `Контроль бюджета` — 30%
- `Подушка безопасности` — 30%
- `Динамика месяца` — 20%
- `Поведенческая дисциплина` — 20%

Формула:

`index = budget*0.30 + safety*0.30 + dynamics*0.20 + discipline*0.20`

Где каждый фактор предварительно нормализуется в диапазон `0..100`.

## Правила расчета
- Каждый входной фактор клампится в `0..100`.
- Итоговое значение округляется до целого (`round`).
- После округления итог клампится в `0..100`.

## Статусы индекса
Для итогового индекса используются следующие состояния:

- `< 40` → `Финансовый риск`
- `40..59` → `Нестабильно`
- `60..79` → `Стабильно`
- `80..100` → `Уверенный рост`

Примечание по границам:
- `40` относится к `Нестабильно`;
- `60` относится к `Стабильно`;
- `80` относится к `Уверенный рост`.

## Реализация в коде (этап 1)
- Модели: `lib/features/overview/domain/models/financial_index_models.dart`
- Калькулятор: `lib/features/overview/domain/services/financial_index_calculator.dart`
- Unit-тесты: `test/features/overview/domain/services/financial_index_calculator_test.dart`

## Реализация в коде (этап 3)
- Use case-агрегатор факторов и серии по месяцам:
  `lib/features/overview/domain/use_cases/watch_financial_index_use_case.dart`
- Общий расчет safety-фактора:
  `lib/features/overview/domain/services/safety_cushion_calculator.dart`
- Общий расчет дисциплины:
  `lib/features/overview/domain/services/behavior_discipline_calculator.dart`
- Unit-тесты use case:
  `test/features/overview/domain/use_cases/watch_financial_index_use_case_test.dart`

## Реализация в коде (этап 5)
- Локализация карточки индекса:
  - `lib/l10n/app_ru.arb`
  - `lib/l10n/app_en.arb`
- UI-карточка использует локализованные статусы и текст чипа:
  - `lib/features/overview/presentation/overview_screen.dart`
- Widget-тест карточки:
  - `test/features/overview/presentation/overview_screen_test.dart`

## Проверка
Ключевой тест формулы: при входных значениях
- `budget = 80`
- `safety = 60`
- `dynamics = 70`
- `discipline = 90`

получаем `index = 74`.
