# Аудит бизнес-логики приложения

Дата аудита: 2026-03-07

## Область и метод

Проверка охватывала:

- `lib/features/**`, связанные зависимости в `lib/core/**`;
- архитектурные инварианты из `docs/logic/feature_invariants.md`;
- статический анализ `flutter analyze`;
- регрессионный прогон `flutter test --reporter expanded`;
- поиск незавершенной логики, расхождений с offline-first и кандидатов на dead code.

## Краткий вывод

Приложение в целом имеет понятную feature-first структуру и во многих критичных модулях уже покрыто тестами, но в текущем состоянии есть несколько серьезных проблем:

- в кредитах исходно был незавершенный сценарий редактирования платежей, но на 2026-03-07 он закрыт отдельной доработкой;
- в savings есть ошибка масштаба суммы при пополнении цели;
- в переводах между счетами исходно отсутствовала валютная валидация, но на 2026-03-07 это закрыто отдельной доработкой;
- накопился заметный слой неиспользуемого и дублирующегося кода;
- часть исходных проблем тестового контура на 2026-03-07 уже закрыта отдельными доработками, но вне transaction-модуля еще остаются несвязанные падения.

## Подтвержденные находки

### 1. Закрыто 2026-03-07: редактирование кредитного платежа переведено на атомарную операцию payment group

Файлы:

- `lib/features/credits/domain/use_cases/update_credit_payment_case.dart`
- `lib/features/credits/presentation/widgets/pay_credit_sheet.dart`
- `lib/features/credits/presentation/screens/credit_payment_details_screen.dart`
- `test/features/credits/domain/use_cases/update_credit_payment_use_case_test.dart`

Что было найдено в момент первичного аудита:

- `UpdateCreditPaymentUseCase` существует, но полностью пустой и содержит только TODO.
- При этом экран деталей кредитного платежа открывает обычную форму редактирования для каждой транзакции внутри платежной группы через `TransactionFormOpenContainer`.

Почему это ошибка:

- кредитный платеж в модели приложения состоит минимум из `payment group`, связанных transaction rows и, опционально, schedule item;
- при редактировании одной внутренней транзакции меняется только transaction-слой, но не пересчитываются `CreditPaymentGroupEntity` и `CreditPaymentScheduleEntity`;
- это создает рассинхрон между историей платежей, деталями платежной группы, графиком выплат и derived UI.

Риск:

- пользователь видит одну сумму в деталях платежа и другую в фактических транзакциях;
- график кредита может остаться в старом состоянии после редактирования процентов/комиссий/основного долга.

Что сделано:

- реализован `UpdateCreditPaymentUseCase` с атомарным обновлением `payment group`, связанных transaction rows и `schedule item`;
- в data/domain слой добавлены операции `find/update payment group` и `find transactions by groupId`;
- UI деталей платежа переведен с редактирования одиночной transaction row на редактирование всей payment group через `PayCreditSheet`;
- добавлены unit-тесты на сценарии обновления, удаления нулевой component-транзакции и ошибки при отсутствии группы.

Статус:

- находка закрыта;
- подтверждение: `flutter test --reporter expanded test/features/credits` проходит.

### 2. Закрыто 2026-03-07: пополнение копилки переведено на работу с фактическим currencyScale

Файл:

- `lib/features/savings/data/repositories/saving_goal_repository_impl.dart`
- `test/features/savings/data/saving_goal_repository_impl_test.dart`

Что было найдено в момент первичного аудита:

- при `addContribution` сумма строится через `final double amountDouble = appliedDelta / 100;`
- после этого `Money.fromDouble(..., scale: scale)` пересобирает minor-значение обратно.

Почему это ошибка:

- `appliedDelta` уже приходит в minor units;
- деление на `100` корректно только для валют с двумя знаками после запятой;
- для валют/конфигураций с другим `currencyScale` сумма перевода и итоговый баланс будут искажены.

Пример:

- если scale = 0, то `1500` minor интерпретируется как `15.00`, а не `1500`;
- если scale = 3, то `1500` minor интерпретируется как `15.00`, а должно быть `1.500`.

Что сделано:

- логика переведена на создание суммы напрямую из `minor` через `Money.fromMinor`;
- scale теперь берется из фактического `sourceAccountRow.currencyScale`, а не из предположения о валюте;
- добавлен тестовый сценарий `addContribution respects account currencyScale when it is not 2`.

Статус:

- находка закрыта;
- подтверждение: `flutter test --reporter expanded test/features/savings` проходит.

### 3. Закрыто 2026-03-07: cross-currency transfer без FX запрещен на доменном уровне

Файлы:

- `lib/features/transactions/domain/use_cases/add_transaction_use_case.dart:77-88`
- `lib/features/transactions/domain/use_cases/update_transaction_use_case.dart:58-69`
- `lib/features/transactions/data/services/transaction_balance_helper.dart:11-22`
- `lib/features/transactions/presentation/widgets/transaction_form_view.dart:680-687`

Что было найдено в момент первичного аудита:

- при создании и обновлении transfer-проводок проверяется только существование target account;
- UI выбора счета назначения исключает только исходный счет, но не фильтрует валюту;
- баланс-эффект списывает одну и ту же сумму с source и зачисляет ту же сумму на target.

Почему это ошибка:

- если счета в разных валютах, приложение сейчас не делает ни запрет, ни конвертацию;
- значит перевод `100 USD` на счет в `RUB` попадет как `100 RUB` после простого rescale по decimal digits.

Риск:

- тихая порча балансов;
- некорректная аналитика и overview по счетам.

Что сделано:

- в `AddTransactionUseCase` добавлена доменная проверка совпадения валют source/target account;
- в `UpdateTransactionUseCase` добавлена такая же проверка для редактирования существующих переводов;
- форма транзакции больше не показывает target accounts с другой валютой в секции перевода;
- добавлены unit-тесты на запрет cross-currency transfer и widget-тест на UI-фильтрацию target accounts.

Статус:

- находка закрыта;
- подтверждение: `flutter test --reporter expanded test/features/transactions/domain/use_cases/add_transaction_use_case_test.dart test/features/transactions/domain/use_cases/update_transaction_use_case_test.dart test/features/transactions/presentation/transaction_form_view_test.dart` проходит.

### 4. Закрыто 2026-03-07: `TransactionDraftController` развязан от прямого `AccountRepository`

Файл:

- `lib/features/transactions/presentation/controllers/transaction_draft_controller.dart:255-257`
- `lib/features/transactions/presentation/controllers/transaction_draft_controller.dart:338`
- `lib/features/transactions/presentation/controllers/transaction_draft_controller.dart:418-425`
- `lib/features/transactions/presentation/controllers/transaction_draft_controller.dart:512-517`

Что было найдено в момент первичного аудита:

- контроллер формы транзакции читает `accountRepositoryProvider` напрямую;
- это используется и при `updateAccount`, и при `submit`.

Фактическое проявление:

- `flutter test` падает в `test/features/transactions/presentation/controllers/transaction_form_controller_test.dart`;
- причина: в тестах подменяются use case, но контроллер открывает реальную БД через репозиторий и доходит до `path_provider`, что приводит к `Binding has not yet been initialized`.

Почему это важно:

- presentation-controller оказался завязан не только на orchestrating use case, но и на конкретный data path;
- из-за этого тестировать бизнес-поток формы изолированно уже нельзя.

Что сделано:

- добавлен отдельный domain use case `GetAccountByIdUseCase`;
- `TransactionDraftController` переведен с прямого чтения `accountRepositoryProvider` на `getAccountByIdUseCaseProvider`;
- lookup счета для `submit` и для обновления `accountScale` теперь проходит через domain-контракт;
- тест `transaction_form_controller_test.dart` переведен на override нового use case и больше не открывает реальную БД через `path_provider`.

Статус:

- находка закрыта;
- подтверждение: `flutter test --reporter expanded test/features/transactions` проходит полностью.

### 5. Средняя важность: в home/feed используется упрощенное группирование кредитных платежей с placeholder-данными

Файл:

- `lib/features/home/domain/use_cases/group_transactions_by_day_use_case.dart:51-75`

Что найдено:

- для grouped credit payment подставляется `creditId: ''`;
- валюта totalOutflow подставляется как `'XXX'`;
- note собирается простым `join('; ')`.

Почему это проблема:

- use case претендует на доменную агрегацию, но возвращает частично фиктивные данные;
- такой объект легко повторно использовать как будто он полноценный, хотя у него нет корректного `creditId` и валютного контекста.

Степень риска:

- сейчас UI частично компенсирует это внешними данными, но сама модель уже небезопасна;
- это плохая точка расширения и источник скрытых ошибок при повторном использовании в новых экранах.

Рекомендация:

- либо обогащать агрегат корректным `creditId/currency` на уровне use case;
- либо сделать отдельный explicit DTO типа `GroupedTransactionPreview`, где отсутствие этих полей зафиксировано типом.

## Dead Code и архитектурный мусор

### Частично закрыто 2026-03-07: подтвержденный dead code удален, но часть кандидатов возвращена в ручную проверку

Что было удалено и за что отвечал код:

1. `lib/features/accounts/domain/usecases/**`
   - это legacy-ветка старого naming style `usecases/` c абстракцией `WatchAccountsUseCase` и ее proxy-реализацией поверх `AccountRepository.watchAccounts()`;
   - фактическая рабочая версия давно живет в `lib/features/accounts/domain/use_cases/watch_accounts_use_case.dart`;
   - код не использовался, потому что ни один provider, экран, controller или тест не импортировал папку `usecases/`.

2. `lib/features/analytics/presentation/widgets/swipe_hint_arrows.dart`
   - это маленький UI-виджет с левым и правым chevron для подсказки навигации по диапазонам свайпом;
   - код не использовался, потому что по репозиторию у него не было ни одного consumer, кроме собственного объявления.

3. `lib/features/app_shell/presentation/widgets/main_navigation_rail.dart`
   - это обертка над `NavigationRail`, которая должна была рисовать desktop/tablet-навигацию и синхронизировать выбор вкладки с `mainNavigationControllerProvider`;
   - код не использовался, потому что реальный responsive shell не инстанцировал этот виджет, а использовал только breakpoint-константу из соседнего файла.

4. `lib/features/budgets/presentation/budget_detail_screen.dart`
   - это полноценный экран детализации бюджета: прогресс, фильтры, список транзакций, edit/delete budget actions и переходы в редактирование транзакций;
   - по прямому поиску usage экран не имел маршрута и вызовов на момент аудита, но 2026-03-07 был возвращен в кодовую базу, потому что его полезность как заготовки/скрытого сценария не подтверждена окончательно.

5. `overview_goal_focus` use case/provider
   - `lib/features/overview/domain/use_cases/watch_overview_goal_focus_use_case.dart`
   - `lib/features/overview/domain/models/overview_goal_focus.dart`
   - provider в `lib/core/di/injectors.dart`
   - эта логика выбирает одну активную копилку как "goal focus" для overview: считает progress, percent и remaining amount;
   - по прямому поиску usage consumer не найден, но 2026-03-07 код был возвращен, потому что нельзя исключить скрытое или отложенное использование без отдельной продуктовой верификации.

Что сделано:

- удалены legacy-файлы `accounts/domain/usecases/**`;
- удалены неиспользуемые `SwipeHintArrows`, `MainNavigationRail`, `BudgetDetailScreen`;
- удалены `WatchOverviewGoalFocusUseCase`, `OverviewGoalFocus` и соответствующий provider из DI.
- позднее возвращены `BudgetDetailScreen` и `overview_goal_focus`, поскольку пользователь указал, что эти сценарии могут еще понадобиться и не должны считаться окончательно мертвыми без дополнительной проверки.

Статус:

- находка закрыта частично;
- подтверждение: `flutter analyze` проходит, новых ошибок после удаления нет.

### Последствия dead code

- увеличивает стоимость сопровождения;
- создает ложное ощущение, что сценарии уже реализованы;
- мешает аудиту и ускоряет дрейф архитектуры.

## Состояние тестового контура

### `flutter analyze`

Результат на 2026-03-07 после закрытия transaction-specific находок:

- ошибок и warning нет;
- есть 4 `info` по отсутствующим type annotations в тестах.

### `flutter test --reporter expanded`

Результат первичного аудита на 2026-03-07:

- полный прогон `flutter test --reporter expanded` завершается с ошибкой;
- на видимой части лога: `00:19 +345 ~2 -26: Some tests failed.`

Дополнение после исправлений в transaction-модуле:

- `flutter test --reporter expanded test/features/transactions` теперь проходит полностью;
- красная зона `transaction_form_controller_test.dart`, связанная с прямым доступом к репозиторию счета, закрыта;
- оставшиеся падения полного репозиторного тестового прогона находятся вне transaction-модуля.

Подтвержденные красные зоны:

1. `test/features/overview/presentation/overview_screen_test.dart`
   - `Bad state: No element` в сценарии открытия pop-up по иконке финансового индекса.

2. `test/features/profile/presentation/auth_controller_test.dart`
   - тест не компилируется: `FakeAuthRepository` не реализует новые методы `updateEmail` и `updatePassword`.

3. `test/core/services/auth_sync_service_test.dart`
   - есть несовпадение ожидаемого/фактического денежного контракта.

4. `test/features/accounts/presentation/controllers/account_details_providers_test.dart`
   - фильтрация и summary расходятся с ожиданиями.

5. `test/features/analytics/presentation/analytics_screen_test.dart`
   - несколько UI-регрессий и overflow/поиск отсутствующих элементов.

6. `test/features/categories/presentation/screens/manage_categories_screen_test.dart`
   - несколько `Bad state: No element`.

7. `test/features/profile/presentation/*`
   - серия падений на изменившихся текстах/навигации/структуре экрана.

9. `test/features/settings/domain/services/export_bundle_csv_codec_test.dart`
   - дрейф контракта: `openingBalanceMinor` теперь декодируется как `0`, а тест ждет `null`.

### Дополнительный технический сигнал

Во время прогона много раз появляется предупреждение Drift:

- создано несколько экземпляров `AppDatabase` поверх одного executor;
- это не обязательно текущий прод-баг, но явный индикатор нестабильности тестовой инфраструктуры и потенциальных race conditions.

## Что выглядит здоровым

По коду и тестам видно, что следующие зоны проработаны лучше остальных:

- upcoming payments: есть проверки идемпотентности, валидации и recalc;
- overview calculators: safety, behavior, financial index покрыты отдельными тестами;
- credit payment creation: сценарий `MakeCreditPaymentUseCase` и инварианты расписания заметно более зрелые, чем редактирование.

## Приоритетный план исправления

1. Закрыть критический разрыв в credit payments:
   - запретить редактирование составных транзакций кредитного платежа или реализовать `UpdateCreditPaymentUseCase`.

2. Исправить savings contribution на работу с minor units без `double`.

3. Запретить cross-currency transfer без явной FX-модели.

4. Развязать `TransactionDraftController` от прямого `AccountRepository`.

5. Поддерживать слой dead code пустым:
   - не оставлять в DI provider без consumers;
   - удалять отсоединенные экраны/виджеты сразу после смены навигации или UX;
   - не держать рядом legacy-папки с дублирующими use case;
   - кандидаты вроде скрытых экранов и резервных overview-сценариев удалять только после продуктовой верификации.

6. После исправления логики стабилизировать тесты и вернуть `flutter test` в зеленое состояние.
