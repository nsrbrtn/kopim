# AnalyticsDonutChart

## Назначение
Круговая (кольцевая) диаграмма для визуализации аналитических данных в процентах. Отображает данные в виде сегментов кольца с интерактивными значками категорий и возможностью выбора сегментов.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `items` | `List<AnalyticsChartItem>` | Список элементов данных для отображения на диаграмме | *обязательный* |
| `backgroundColor` | `Color` | Цвет фона диаграммы | *обязательный* |
| `totalAmount` | `double?` | Общая сумма для расчёта пропорций (если null, вычисляется автоматически) | `null` |
| `selectedIndex` | `int?` | Индекс выделенного сегмента | `null` |
| `onSegmentSelected` | `ValueChanged<int>?` | Коллбэк при клике на сегмент | `null` |

## События и коллбэки

| Событие | Описание |
|---------|----------|
| `onSegmentSelected(int index)` | Вызывается при нажатии на сегмент диаграммы. Передаёт индекс выбранного элемента |

## Особенности поведения

- **Плавная анимация появления**: диаграмма отрисовывается с анимацией за 650ms
- **Интерактивные иконки**: для каждого сегмента отображается иконка категории с процентным значением
- **Автоматическое позиционирование меток**: метки размещаются вдоль кольца и избегают наложения друг на друга
- **Выделение сегментов**: выбранный сегмент подсвечивается, его метка увеличивается
- **Hit-testing**: точное определение клика по сегменту с учётом кольцевой формы
- **Адаптивный размер**: толщина кольца составляет 12% от размера диаграммы (минимум 10px)

## Пример использования

```dart
AnalyticsDonutChart(
  items: [
    AnalyticsChartItem(
      key: 'food',
      title: 'Еда',
      amount: 15000.0,
      color: Colors.orange,
      icon: Icons.restaurant,
    ),
    AnalyticsChartItem(
      key: 'transport',
      title: 'Транспорт',
      amount: 8000.0,
      color: Colors.blue,
      icon: Icons.directions_car,
    ),
    AnalyticsChartItem(
      key: 'entertainment',
      title: 'Развлечения',
      amount: 5000.0,
      color: Colors.purple,
      icon: Icons.movie,
    ),
  ],
  backgroundColor: Colors.white,
  selectedIndex: 0,
  onSegmentSelected: (index) {
    print('Выбран сегмент $index');
  },
)
```

## Модель данных AnalyticsChartItem

Оба графика используют одну и ту же модель данных:
```dart
class AnalyticsChartItem {
  final String key;                   // Уникальный ключ элемента
  final String title;                 // Название категории
  final double amount;                // Сумма
  final Color color;                  // Цвет сегмента
  final IconData? icon;               // Иконка категории (опционально)
  final List<AnalyticsChartItem> children; // Дочерние элементы (для детализации)
  
  double get absoluteAmount => amount.abs();
}
```

## Связанные файлы

- Исходный код: [`analytics_chart.dart`](file:///home/artem/StudioProjects/kopim/lib/features/analytics/presentation/widgets/analytics_chart.dart#L27-L220)
- Модель данных: [`AnalyticsChartItem`](file:///home/artem/StudioProjects/kopim/lib/features/analytics/presentation/widgets/analytics_chart.dart#L9-L25)
- Painter: `_DonutChartPainter` (приватный класс в том же файле)
