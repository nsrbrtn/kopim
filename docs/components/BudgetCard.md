# BudgetCard

## Назначение
Карточка отображения бюджета с прогресс-индикатором и метриками. Показывает название бюджета, визуализацию использования средств и три ключевые метрики: потрачено, лимит и остаток (или превышение).

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `progress` | `BudgetProgress` | Данные о прогрессе выполнения бюджета | *обязательный* |
| `categorySpend` | `List<BudgetCategorySpend>` | Список категорий с тратами | *обязательный* |
| `onOpenDetails` | `VoidCallback` | Открыть экран деталей бюджета | *обязательный* |
| `onEdit` | `VoidCallback` | Открыть редактирование бюджета | *обязательный* |
| `onDelete` | `VoidCallback` | Удаление бюджета | *обязательный* |
| `showDetailsButton` | `bool` | Показывать кнопку «Details» внутри карточки | `true` |
| `onTap` | `VoidCallback?` | Коллбэк при нажатии на карточку, когда выключено раскрытие | `null` |
| `enableExpansion` | `bool` | Разрешить раскрытие карточки и показ детализации | `true` |

## События и коллбэки

| Событие | Описание |
|---------|----------|
| `onOpenDetails()` | Открытие экрана деталей бюджета |
| `onEdit()` | Переход к редактированию |
| `onDelete()` | Запрос на удаление |
| `onTap()` | Вызывается при нажатии на карточку, когда `enableExpansion = false` |

## Особенности поведения

- **Прогресс-индикатор**: визуализирует степень использования бюджета (зелёный/красный)
- **Автоматическое определение превышения**: если потрачено больше лимита, метрика "Остаток" меняется на "Превышено" с красным цветом
- **Ограничение прогресса**: коэффициент использования ограничен диапазоном [0, 2] для корректной визуализации
- **Адаптивное форматирование**: суммы отображаются с учётом локали пользователя
- **Интерактивность**: карточка раскрывается по тапу, либо открывает детали при `enableExpansion = false`

## Структура BudgetProgress

```dart
class BudgetProgress {
  final Budget budget;         // Данные бюджета (название, лимит)
  final double spent;          // Сумма потраченных средств
  final double remaining;      // Остаток средств
  final double utilization;    // Коэффициент использования (0.0 - 1.0+)
  final bool isExceeded;       // Флаг превышения лимита
}
```

## Пример использования

```dart
BudgetCard(
  progress: progress,
  categorySpend: categorySpend,
  onOpenDetails: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BudgetOverviewScreen(budgetId: progress.budget.id),
      ),
    );
  },
  onEdit: () => openEdit(),
  onDelete: () => confirmDelete(),
)
```

## Пример с превышением бюджета

```dart
BudgetCard(
  progress: progress,
  categorySpend: categorySpend,
  enableExpansion: false,
  showDetailsButton: false,
  onTap: () => openDetails(),
  onOpenDetails: () => openDetails(),
  onEdit: () => openEdit(),
  onDelete: () => confirmDelete(),
)
// В этом случае вместо "Остаток: 7500₽" будет "Превышено: 2500₽" красным цветом
```

## Связанные файлы

- Исходный код: `lib/features/budgets/presentation/widgets/budget_card.dart`
- Компонент прогресса: `BudgetProgressIndicator` (используется внутри)
