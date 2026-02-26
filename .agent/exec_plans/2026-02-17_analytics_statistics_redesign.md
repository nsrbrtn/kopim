# ExecPlan: Редизайн вкладки "Статистика" в аналитике

## Context and Orientation
- Цель: обновить визуал вкладки `Статистика` по макету Figma (карточки "Остаток денег" и "Денег всего").
- Область кода: `lib/features/analytics/presentation/widgets/monthly_cashflow_bar_chart_widget.dart`, `lib/features/analytics/presentation/widgets/total_money_chart_widget.dart`, при необходимости `lib/features/analytics/presentation/analytics_screen.dart`.
- Контекст/ограничения: использовать цвета/типографику из темы; без хардкода шрифтов/цветов вне `ThemeData` и `ColorScheme`; сохранить текущие данные и интерактивность выбора месяца.
- Риски: визуальное расхождение со скрином, регресс в выборе месяца/окне данных, переполнение на узких экранах.

## Interfaces and Dependencies
- Внешние сервисы: нет.
- Локальные зависимости: `syncfusion_flutter_charts`, локализация `AppLocalizations`.
- Затрагиваемые API/модули: `MonthlyCashflowBarChartWidget`, `TotalMoneyChartWidget`.

## Plan of Work
- Перестроить карточку "Остаток денег" под новый layout с чипами и метриками.
- Перестроить карточку "Денег всего" под новый layout с line chart и правой шкалой.
- Сохранить текущую механику выбора месяца и навигации, проверить адаптивность.

## Concrete Steps
1) Обновить структуру `MonthlyCashflowBarChartWidget`: заголовок, фильтры-чипы, блоки метрик, график и кнопки навигации.
2) Обновить структуру `TotalMoneyChartWidget`: заголовок, фильтры-чипы, крупное значение, line chart и кнопки навигации.
3) Прогнать форматирование/анализатор и поправить overflow/стили.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed lib/features/analytics/presentation/widgets/monthly_cashflow_bar_chart_widget.dart lib/features/analytics/presentation/widgets/total_money_chart_widget.dart
flutter analyze lib/features/analytics/presentation/widgets/monthly_cashflow_bar_chart_widget.dart lib/features/analytics/presentation/widgets/total_money_chart_widget.dart lib/features/analytics/presentation/analytics_screen.dart
```
- Acceptance criteria:
  - Вкладка `Статистика` визуально соответствует макету по структуре блоков.
  - Цвета и типографика берутся из темы.
  - Нет overflow и ошибок анализатора.

## Idempotence and Recovery
- Безопасно перезапускать: `dart format`, `flutter analyze`.
- Откат: вернуть изменения в двух виджетах статистики.
- Rollback миграций: не требуется.

## Progress
- [x] Шаг 1: Обновлён `MonthlyCashflowBarChartWidget`.
- [x] Шаг 2: Обновлён `TotalMoneyChartWidget`.
- [x] Шаг 3: Валидация и финальные правки.

## Surprises & Discoveries
- ...

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Перестроена карточка `Остаток денег`: заголовок, фильтр-чипы, цветные метрики, обновлённый bar chart, навигационные стрелки.
- Перестроена карточка `Денег всего`: заголовок, фильтр-чипы, крупная сумма, line chart с правой шкалой, навигационные стрелки.
- Сохранён выбор месяца по нажатию на точки/столбцы графиков.
- Подключена интерактивность чипов `месяц` и `счета` на вкладке `Статистика` через существующие пикеры.
- Удалена декоративная иконка фильтра в карточках статистики.
- Добавлена синхронизация окна графиков с выбранным месяцем, чтобы данные не залипали вне видимого диапазона.
- Что улучшить:
