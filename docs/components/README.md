# Кастомные виджеты проекта Kopim

Этот раздел содержит документацию всех кастомных UI-виджетов проекта.

## Структура документации

Каждый виджет описан в отдельном файле со следующими разделами:

- **Назначение** — роль виджета в приложении
- **Параметры** — список параметров конструктора с типами и значениями по умолчанию
- **События и коллбэки** — обрабатываемые события
- **Пример использования** — код-примеры
- **Связанные файлы** — ссылки на исходный код и тесты

## Категории виджетов

### Графики и визуализация
- [AnalyticsBarChart](AnalyticsBarChart.md) — столбчатая диаграмма для аналитики
- [AnalyticsDonutChart](AnalyticsDonutChart.md) — круговая диаграмма с интерактивной подсветкой
- [AnalyticsCreditDebtOperationsWidget](AnalyticsCreditDebtOperationsWidget.md) — блок операций по кредитам и долгам под диаграммой категорий
- [MonthlyCashflowBarChartWidget](MonthlyCashflowBarChartWidget.md) — сравнение доходов и расходов по месяцам
- [TotalMoneyChartWidget](TotalMoneyChartWidget.md) — график динамики общего баланса

### Формы и ввод данных
- [KopimTextField](KopimTextField.md) — кастомное текстовое поле с поддержкой иконок, валидации и многострочного режима
- [KopimDropdownField](KopimDropdownField.md) — выпадающий список с анимацией и кастомным отображением значений
- [AccountColorSelector](AccountColorSelector.md) — селектор цвета для счётов

### UI-компоненты и контейнеры
- [KopimFloatingActionButton](KopimFloatingActionButton.md) — кнопка действия с поддержкой обычного и расширенного режима
- [KopimGlassSurface](KopimGlassSurface.md) — стеклянный эффект (glassmorphism) для премиум-дизайна
- [TransactionFormOpenContainer](TransactionFormOpenContainer.md) — fade-through переход для открытия формы транзакции из карточки или FAB
- [AnimatedFab](AnimatedFab.md) — анимированное появление FAB с масштабом и fade

### Карточки и элементы списков
- [BudgetCard](BudgetCard.md) — карточка бюджета с прогресс-индикатором
- [BudgetMetric](BudgetMetric.md) — метрика бюджета (лейбл + значение)
- [DebtCard](DebtCard.md) — карточка долга с суммой, счетом и датой платежа
- [CreditPaymentDetailsScreen](CreditPaymentDetailsScreen.md) — экран деталей группового платежа по кредиту
- [HomeOverviewSummaryCard](HomeOverviewSummaryCard.md) — карточка сводки на главном экране
- [ReminderListItem](ReminderListItem.md) — элемент списка напоминаний
- [GlowingAccountCard](GlowingAccountCard.md) — анимированная подсветка-змейка вокруг карточки счёта
- [TransactionTypeSelector](TransactionTypeSelector.md) — сегментированный переключатель «расход/доход» в стиле Kopim

### Вспомогательные компоненты
- [BudgetMetric](BudgetMetric.md) — метрика бюджета (лейбл + значение)
- [UpcomingBadge](UpcomingBadge.md) — бейдж с количеством предстоящих событий
- [UpcomingSummaryBadges](UpcomingSummaryBadges.md) — группа бейджей для отображения сводки

### Состояния экранов
- [BudgetsEmptyState](BudgetsEmptyState.md) — пустое состояние экрана бюджетов
- [BudgetsErrorState](BudgetsErrorState.md) — состояние ошибки экрана бюджетов
- [SettingsSkeleton](SettingsSkeleton.md) — скелетон загрузки настроек
- [AccountDetailsScreen](AccountDetailsScreen.md) — экран обзора счёта с периодами, графиком и транзакциями

### UI-элементы настроек
- [SettingsActionButton](SettingsActionButton.md) — кнопка действия в настройках
- [SettingsErrorMessage](SettingsErrorMessage.md) — сообщение об ошибке в настройках
- [SettingsMenuItem](SettingsMenuItem.md) — пункт меню настроек

---

**Примечание**: Документация генерируется на основе актуального состояния кодовой базы. При добавлении новых виджетов не забудьте обновить этот раздел.
