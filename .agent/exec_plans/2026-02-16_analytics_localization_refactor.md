# ExecPlan: Локализация экрана аналитики без хардкода

## Context and Orientation
- Цель: убрать русские хардкоды из экрана аналитики и виджетов графиков, чтобы UI корректно локализовался на `ru/en`.
- Область кода: `lib/features/analytics/presentation/analytics_screen.dart`, `lib/features/analytics/presentation/widgets/*.dart`, `lib/features/analytics/*/monthly_*_data.dart`, `lib/l10n/app_*.arb`.
- Контекст/ограничения: не править автоген (`app_localizations*.dart`), изменения через ARB + `flutter gen-l10n`.
- Риски: пропустить строку в вспомогательном диалоге/чипе; сломать тесты виджетов из-за изменений текстов.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): нет.
- Локальные зависимости (Drift, codegen): `flutter gen-l10n`, widget tests.
- Затрагиваемые API/модули: экран аналитики, виджеты графиков, l10n ключи.

## Plan of Work
- Выделить хардкоды и переиспользовать существующие ключи.
- Добавить недостающие l10n-ключи в `app_en.arb` и `app_ru.arb`.
- Перевести экран/виджеты на `AppLocalizations` и убрать русские месяцы из доменных/презентационных моделей.
- Прогнать генерацию и целевые тесты.

## Concrete Steps
1) Обновить `analytics_screen.dart`: табы, фильтры, bottom sheets, блок кредитов/долгов, переключатель типов диаграмм.
2) Обновить `monthly_cashflow_bar_chart_widget.dart` и `total_money_chart_widget.dart` на строки из l10n.
3) Убрать русские названия месяцев из `MonthlyCashflowData`/`MonthlyBalanceData` и форматировать месяцы по locale в виджетах.
4) Добавить новые ключи в `app_en.arb` и `app_ru.arb`; выполнить `flutter gen-l10n`.
5) Прогнать целевые тесты аналитики.

## Validation and Acceptance
- Команды проверки:
```bash
flutter gen-l10n
flutter test test/features/analytics/presentation/widgets/total_money_chart_widget_test.dart test/features/analytics/presentation/widgets/monthly_cashflow_bar_chart_widget_test.dart
flutter test test/features/analytics/presentation/analytics_screen_test.dart
```
- Acceptance criteria:
  - На `en`/`ru` экран аналитики не содержит русских хардкодов.
  - Месяцы в графиках форматируются по текущей локали.
  - Регрессионные тесты аналитики проходят или задокументированы существующие нестабильности.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `flutter gen-l10n`, `flutter test`.
- Как откатиться/восстановиться: откатить изменения в `analytics_*` и ARB.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Зафиксирован план и область изменений.
- [x] Шаг 2: Локализован `analytics_screen.dart`.
- [x] Шаг 3: Локализованы `total_money_chart_widget.dart` и `monthly_cashflow_bar_chart_widget.dart`.
- [x] Шаг 4: Убраны русские месяцы из моделей данных графиков.
- [x] Шаг 5: Добавлены ARB-ключи и выполнен `flutter gen-l10n`.
- [x] Шаг 6: Запущены целевые тесты.

## Surprises & Discoveries
- `analytics_screen_test.dart` продолжает падать с `pumpAndSettle timed out` в нескольких кейсах; это совпадает с предыдущим состоянием и связано с долгоживущими стримами в экране.

## Decision Log
- Использовать существующие `analytics*` ключи там, где подходят по смыслу, и добавлять новые только для уникальных текстов.

## Outcomes & Retrospective
- Что сделано:
- Убраны русские хардкоды из экрана аналитики и двух графиков, тексты вынесены в `l10n`.
- Удалены жестко заданные русские названия месяцев из моделей; подписи месяцев теперь формируются в UI через `DateFormat` с текущей локалью.
- Добавлены/обновлены widget-тесты графиков с `AppLocalizations`.
- Что бы улучшить в следующий раз:
