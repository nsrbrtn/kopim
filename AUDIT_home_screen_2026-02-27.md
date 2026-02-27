# Комплексный аудит домашнего экрана (2026-02-27)

## Область аудита
- Экран: `lib/features/home/presentation/screens/home_screen.dart`
- Виджеты: `lib/features/home/presentation/widgets/*.dart`
- Провайдеры/контроллеры: `lib/features/home/presentation/controllers/*.dart`
- Тесты: `test/features/home/**`

## Что проверено
- Корректность поведения (состояния, пустые/ошибочные кейсы, навигация, критичные ветки).
- Отсутствие хардкода цветов/шрифтов/текстов.
- Производительность (форматтеры, лишние пересборки, тяжелые операции в build).
- Текущее здоровье тестов и анализатора.

## Результаты запусков
- `flutter analyze lib/features/home` → **OK, замечаний нет**.
- `flutter test test/features/home --reporter expanded` → **FAIL** (2 падения):
  - `test/features/home/presentation/widgets/home_budget_progress_card_test.dart` (ожидается `CategoryChip`, фактически рендерится другой виджет).
  - `test/features/home/presentation/screens/home_screen_test.dart` (timeout + ошибка binding/path_provider при инициализации зависимостей).

## Статус выполнения
- [x] Удален `HomeGamificationWidget` и его виджетный тест:
  - `lib/features/home/presentation/widgets/home_gamification_widget.dart`
  - `test/features/home/presentation/widgets/home_gamification_widget_test.dart`
- [x] Исправлено определение пустого списка транзакций:
  - `lib/features/home/presentation/screens/home_screen.dart` (учитываются `_TransactionItemEntry` и `_TransactionGroupEntry`).
- [x] Исправлен хардкод текстов:
  - `quick_add_transaction.dart` → `homeQuickAddTransactionTitle`
  - `home_screen.dart` → `homeLogoSemanticLabel`
  - `home_upcoming_items_card.dart` → `homeUpcomingPaymentsOverflowIndicator`
- [x] Исправлен хардкод цветов:
  - заменены `Color(0xFF101010)`, `Colors.white/black*`, `Colors.transparent`
  - используются значения из `Theme.of(context).colorScheme` и контрастный выбор через `ThemeData.estimateBrightnessForColor`.
- [x] Убрана повторная аллокация форматтеров в горячих местах:
  - `home_screen.dart`: форматтеры валют предрасчитываются по валютам, не создаются в `itemBuilder`.
  - `home_upcoming_items_card.dart`: `DateFormat` и `NumberFormat` переиспользуются, пробрасываются в элементы.
  - `home_overview_summary_card.dart`: символ валюты через кешированный `fallbackCurrencySymbol`.

## Критичные находки

### 1) [HIGH][FIXED] Некорректное определение пустого списка транзакций
- Файл: `lib/features/home/presentation/screens/home_screen.dart:1793`
- Проблема: пустое состояние определяется только по `_TransactionItemEntry`, а `_TransactionGroupEntry` (сгруппированные кредитные платежи) не учитывается.
- Риск: при наличии только grouped-платежей пользователь увидит `homeTransactionsEmpty`, хотя данные есть.
- Фикс: `entry is _TransactionItemEntry || entry is _TransactionGroupEntry`.

### 2) [HIGH] Домашний модуль не проходит собственный тестовый набор
- Файлы:
  - `test/features/home/presentation/widgets/home_budget_progress_card_test.dart:208`
  - `test/features/home/presentation/screens/home_screen_test.dart:70`
- Проблема:
  - тест бюджета ожидает `CategoryChip`, но текущая реализация использует `_BudgetCategoryChip`.
  - тест `homeAccountsProvider` не полностью изолирован от инфраструктурных зависимостей (в рантайме лезет в `path_provider`/DB), из-за чего получает timeout и binding-ошибку.
- Риск: регрессии домашнего экрана не контролируются надежно в CI.

## Важные находки

### 3) [MEDIUM][FIXED] Есть хардкод текстов (без l10n)
- Фикс: тексты вынесены в l10n-ключи `homeQuickAddTransactionTitle`, `homeLogoSemanticLabel`, `homeUpcomingPaymentsOverflowIndicator`.
- Риск: неполная локализация, сложнее поддержка мультиязычности.

### 4) [MEDIUM][FIXED] Есть хардкод цветов
- Фикс: хардкод цветов заменен на токены `colorScheme` и контрастный выбор по яркости фона.
- Риск: несоответствие дизайн-токенам, возможные проблемы контраста в разных темах.

### 5) [MEDIUM][FIXED] Повторная аллокация форматтеров в горячих местах
- Фикс:
  - `home_screen.dart` — предрасчет и переиспользование `NumberFormat` по валютам.
  - `home_upcoming_items_card.dart` — общий `DateFormat` для списка и кеш `NumberFormat` по `amount.scale`.
  - `home_overview_summary_card.dart` — символ валюты берется из кеша `TransactionTileFormatters`.
- Риск: лишняя нагрузка GC/CPU при скролле и частых обновлениях.

## Дополнительные наблюдения
- `fontFamily`-хардкода в модуле не найдено.
- Есть fallback `TextStyle(...)` с явными размерами/высотами (`home_screen.dart:1648`, `:1654`, `:1662`, `:1787`, `:1792`) — это не критично, но лучше централизовать через тему/токены.
- В app bar используется `assets/icons/logo_dark.png` (`home_screen.dart:495`) — возможна визуальная несогласованность в светлой теме.

## Вывод по запросу
- Экран **частично корректен**, но утверждение «все работает правильно» сейчас подтвердить нельзя из-за:
  - падений тестов модуля.
- Требование по хардкоду текстов и цветов в проверенных местах домашнего экрана выполнено; `fontFamily`-хардкода нет.
- По производительности есть несколько точек для оптимизации (прежде всего кэш форматтеров в провайдерах/мемоизированных утилитах).

## Рекомендованный план исправлений
1. Исправить проверку пустого состояния транзакций: учитывать `_TransactionGroupEntry` как валидный контент.
2. Привести тесты `features/home` в green:
   - обновить ожидания `home_budget_progress_card_test` под фактический UI,
   - полностью замокать зависимости `home_screen_test` (credits/creditCards/DB path provider).
3. Убрать хардкод строк в `l10n` (quick add title, gamification phrases, semanticLabel, `...`).
4. Убрать хардкод цветов: заменить на `ColorScheme`/токены темы.
5. Вынести `DateFormat`/`NumberFormat` из itemBuilder в кэшируемые провайдеры/утилиты.
