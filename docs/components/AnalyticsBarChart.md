# AnalyticsBarChart

## Назначение
Столбчатая диаграмма для визуализации аналитических данных. Отображает данные в виде вертикальных столбцов с возможностью интерактивного выбора и анимации.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `items` | `List<AnalyticsChartItem>` | Список элементов данных для отображения на диаграмме | *обязательный* |
| `backgroundColor` | `Color` | Цвет фона контейнера диаграммы | *обязательный* |
| `totalAmount` | `double?` | Общая сумма для расчёта пропорций (если null, вычисляется автоматически) | `null` |
| `selectedIndex` | `int?` | Индекс выделенного элемента | `null` |
| `onBarSelected` | `ValueChanged<int>?` | Коллбэк при клике на столбец | `null` |

## События и коллбэки

| Событие | Описание |
|---------|----------|
| `onBarSelected(int index)` | Вызывается при нажатии на столбец диаграммы. Передаёт индекс выбранного элемента |

## Особенности поведения

- Автоматически вычисляет общую сумму элементов, если `totalAmount` не указан
- Минимальная высота столбца — 4px (даже для нулевых значений)
- Выделенный столбец получает полную непрозрачность и тень
- Невыделенные столбцы отображаются с прозрачностью 0.7
- Анимированный переход при изменении выделения (200ms)
- Отображает иконку категории над столбцом, если доля элемента достаточно велика

## Пример использования

```dart
AnalyticsBarChart(
  items: [
    AnalyticsChartItem(
      absoluteAmount: 1500.0,
      color: Colors.blue,
      icon: Icons.shopping_cart,
    ),
    AnalyticsChartItem(
      absoluteAmount: 2300.0,
      color: Colors.green,
      icon: Icons.restaurant,
    ),
    AnalyticsChartItem(
      absoluteAmount: 800.0,
      color: Colors.orange,
      icon: Icons.directions_car,
    ),
  ],
  backgroundColor: Colors.white,
  selectedIndex: 1,
  onBarSelected: (index) {
    print('Выбран столбец $index');
  },
)
```

## Связанные файлы

- Исходный код: [`analytics_chart.dart`](file:///home/artem/StudioProjects/kopim/lib/features/analytics/presentation/widgets/analytics_chart.dart#L222-L374)
- Модель данных: `AnalyticsChartItem` (в том же файле)
