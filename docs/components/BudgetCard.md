# BudgetCard

## Назначение
Карточка отображения бюджета с прогресс-индикатором и метриками. Показывает название бюджета, визуализацию использования средств и три ключевые метрики: потрачено, лимит и остаток (или превышение).

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `progress` | `BudgetProgress` | Данные о прогрессе выполнения бюджета | *обязательный* |
| `onTap` | `VoidCallback?` | Коллбэк при нажатии на карточку | `null` |

## События и коллбэки

| Событие | Описание |
|---------|----------|
| `onTap()` | Вызывается при нажатии на карточку (обычно используется для навигации к деталям бюджета) |

## Особенности поведения

- **Прогресс-индикатор**: визуализирует степень использования бюджета (зелёный/красный)
- **Автоматическое определение превышения**: если потрачено больше лимита, метрика "Остаток" меняется на "Превышено" с красным цветом
- **Ограничение прогресса**: коэффициент использования ограничен диапазоном [0, 2] для корректной визуализации
- **Адаптивное форматирование**: суммы отображаются с учётом локали пользователя
- **Интерактивность**: карточка имеет эффект нажатия (InkWell) при наличии `onTap`

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
  progress: BudgetProgress(
    budget: Budget(
      id: '1',
      title: 'Продукты',
      amount: 30000.0,
      // ...
    ),
    spent: 22500.0,
    remaining: 7500.0,
    utilization: 0.75,  // 75%
    isExceeded: false,
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BudgetDetailScreen(budgetId: '1'),
      ),
    );
  },
)
```

## Пример с превышением бюджета

```dart
BudgetCard(
  progress: BudgetProgress(
    budget: Budget(
      id: '2',
      title: 'Развлечения',
      amount: 10000.0,
    ),
    spent: 12500.0,
    remaining: -2500.0,
    utilization: 1.25,  // 125%
    isExceeded: true,
  ),
  onTap: () => print('Открыть детали бюджета'),
)
// В этом случае вместо "Остаток: 7500₽" будет "Превышено: 2500₽" красным цветом
```

## Связанные файлы

- Исходный код: [`budget_card.dart`](file:///home/artem/StudioProjects/kopim/lib/features/budgets/presentation/widgets/budget_card.dart#L10-L84)
- Компонент прогресса: `BudgetProgressIndicator` (используется внутри)
- Вспомогательный виджет: [`_BudgetMetric`](file:///home/artem/StudioProjects/kopim/lib/features/budgets/presentation/widgets/budget_card.dart#L86-L115) (приватный, используется для отображения метрик)
