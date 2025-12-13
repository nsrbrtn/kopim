# Architecture map
- **Home (lib/features/home/presentation/screens/home_screen.dart):** вход через `buildHomeTabContent` в `main_navigation_tabs_provider`; данные подтягиваются из провайдеров: `homeAccountsProvider` → `watchAccountsUseCase` → `AccountRepository` → Drift/outbox; `homeGroupedTransactionsProvider` → `watchRecentTransactionsUseCase(limit: kDefaultRecentTransactionsLimit)` → Drift → `GroupTransactionsByDayUseCase`; `homeAccountMonthlySummariesProvider` → `watchRecentTransactionsUseCase(limit: 0)` → Drift → `computeCurrentMonthSummaries`; `homeCategoriesProvider` → `watchCategoriesUseCase` → CategoryRepository; `homeUpcomingItemsProvider` → `ListHomeUpcomingItemsUC` → `UpcomingPaymentsRepository`/`PaymentRemindersRepository`; `homeDashboardPreferencesController` → `HomeDashboardPreferencesRepository`. UI строится через `CustomScrollView` с карточками счетов, быстрым добавлением, блоками бюджета/сбережений/повторяющихся платежей и списком транзакций.
- **Навигация Add/Edit:** FAB `_AddTransactionButton` и тап по транзакции (`_TransactionListItem.onTap`) дергают `transactionSheetControllerProvider` → `TransactionFormOverlay` → `TransactionFormView`. Undo после успешного создания/удаления проходит через `transactionActionsController` → `DeleteTransactionUseCase`.
- **Быстрое добавление:** `QuickAddTransactionCard` → `quickTransactionController` → `AddTransactionUseCase` → `TransactionRepositoryImpl` (Drift + outbox) и `AccountRepository` (баланс) + `ProfileEventRecorder`.
- **Форма Add/Edit:** `TransactionFormView` использует autoDispose family `transactionFormControllerProvider(formArgs)` + `transactionFormAccountsProvider`/`transactionFormCategoriesProvider`. Сабмит: `TransactionDraftController.submit` → `AddTransactionUseCase` или `UpdateTransactionUseCase` → `TransactionRepository`/`AccountRepository` → Drift/outbox (+ профильные события). Отдельный роут `/transactions/add` (`AddTransactionScreen`) и обертка `TransactionFormOpenContainer` используют ту же пару виджетов/провайдеров.

# Dead code candidates
- Удалено: дублирующий `lib/features/transactions/domain/usecases/watch_recent_transactions_use_case_impl.dart`.
- Удалено: неиспользуемые провайдеры `homeUpcomingPaymentsProvider`, `homeRecurringRulesProvider`, `homeRecurringRuleByIdProvider` из home.

# Bugs & edge-cases
- [high][fixed] Форма Add/Edit теперь на autoDispose family `transactionFormControllerProvider`, стейт не течет между открытиями (AddTransactionScreen/TransactionFormView/Overlay).
- [med][fixed] Оверлей формы не закрывается во время сабмита (PopScope/backdrop учитывают `isSubmitting`), пользователь не теряет обратную связь.
- [low][fixed] Быстрый ввод использует общий `digitsAndSeparatorsFormatter`, валидация совпадает с основной формой.

# Performance findings
- [med][fixed] `homeAccountMonthlySummariesProvider` больше не грузит всю историю. Агрегация вынесена в Drift (`TransactionDao.watchAccountMonthlyTotals`) и отдает суммы только за текущий месяц.
- [low][fixed] `TransactionFormOverlay` теперь оборачивает blur в `ClipRect` и адаптирует `sigma` по платформе (на Web blur отключён), чтобы уменьшить просадки FPS.
- [low][fixed] Кнопки сохранения формы и FAB больше не используют хардкоды цветов — опираются на `ThemeData.colorScheme`.

# Refactor plan
- **Быстрые (до 2ч):**
  - Сделано: autoDispose семейство для формы, чистка дублей use case и неиспользуемых провайдеров, единый форматтер суммы в Quick Add, блокировка закрытия оверлея при сабмите.
- **Средние (полдня):**
  - Вынести месячные агрегаты в Drift-запрос: `TransactionDao.watchMonthlySummaries(monthStart, nextMonth)` и использовать его в `homeAccountMonthlySummariesProvider`; добавить юнит-тесты на границы месяца/часовой пояс.
  - Заменить хардкоды цветов в форме/кнопках на `ColorScheme`/токены темы; проверить контраст в светлой/темной схеме.
  - Переподключить `TransactionFormOverlay`/`AddTransactionScreen` к отдельным инстансам стейта (family by args), чтобы можно было открывать несколько форм независимо и гарантировать авто-dispose.
- **Крупные (несколько PR):**
  - Сделать агрегаты домашнего экрана (месяц по счетам, группировки по дням) вне UI-isolate с кэшированием и метриками Firebase Performance для первого рендера.
  - Перепройти UI-пути home на предмет тяжелых эффектов (blur/теневые карточки) и добавить профилирование в profile-режиме на реальном устройстве.
  - Добавить интеграционные тесты: сабмит транзакции из оверлея/быстрого добавления обновляет баланс счета и появляется в фиде; отмена (undo) откатывает баланс.
