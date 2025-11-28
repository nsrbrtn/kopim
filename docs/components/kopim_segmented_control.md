# KopimSegmentedControl

Сегментированная кнопка для переключения между несколькими опциями (2+), с анимированным ползунком и адаптивной шириной сегментов.

## Параметры
- `options` — список `KopimSegmentedOption<T>` (value/label/icon).
- `selectedValue` — текущий выбранный `value`.
- `onChanged(T value)` — колбэк при выборе сегмента.
- `height` — высота контейнера, по умолчанию `48`.
- `padding` — внутренние отступы, по умолчанию `EdgeInsets.all(6)`.

## Использование
```dart
final List<KopimSegmentedOption<String>> filters = <KopimSegmentedOption<String>>[
  const KopimSegmentedOption(value: 'expenses', label: 'Расходы', icon: Icons.arrow_downward),
  const KopimSegmentedOption(value: 'income', label: 'Доходы', icon: Icons.arrow_upward),
];

KopimSegmentedControl<String>(
  options: filters,
  selectedValue: current,
  onChanged: (String value) => setState(() => current = value),
);
```

## Код
- `lib/core/widgets/kopim_segmented_control.dart`
