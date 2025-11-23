# KopimGlassSurface

## Назначение
Стеклянный эффект (glassmorphism) для создания современных полупрозрачных поверхностей с размытием фона, градиентной подсветкой и тенью. Используется для карточек, модальных окон и других UI-элементов премиум-дизайна.

## Параметры

| Параметр | Тип | Описание | По умолчанию |
|----------|-----|----------|--------------|
| `child` | `Widget` | Контент внутри стеклянной поверхности | *обязательный* |
| `borderRadius` | `BorderRadius` | Скругление углов | `BorderRadius.circular(28)` |
| `padding` | `EdgeInsetsGeometry?` | Внутренние отступы | `EdgeInsets.all(16)` |
| `margin` | `EdgeInsetsGeometry?` | Внешние отступы | `null` |
| `blurSigma` | `double` | Интенсивность размытия фона | `18.0` |
| `enableBorder` | `bool` | Показывать ли тонкую рамку | `true` |
| `enableGradientHighlight` | `bool` | Включить градиентную подсветку | `true` |
| `enableShadow` | `bool` | Добавить тень для эффекта "парения" | `true` |
| `onTap` | `VoidCallback?` | Обработчик нажатия (делает поверхность кликабельной) | `null` |
| `baseOpacity` | `double?` | Прозрачность фона (0.0 - 1.0) | 0.78 (тёмная) / 0.82 (светлая) |
| `gradientHighlightIntensity` | `double` | Интенсивность градиентной подсветки (0.0 - 1.0) | `1.0` |
| `gradientTintColor` | `Color?` | Цвет тонировки градиента | `primary` / `secondaryContainer` |

## Особенности поведения

- **Адаптивная тема**: автоматически подстраивается под светлую/тёмную тему
- **Многослойный эффект**: 
  1. Тень (если `enableShadow`)
  2. Полупрозрачный фон с размытием
  3. Градиентная подсветка (если `enableGradientHighlight`)
  4. Рамка (если `enableBorder`)
- **Интерактивность**: при задании `onTap` добавляется InkWell с ripple-эффектом
- **Оптимизация**: градиентная подсветка игнорирует touch-события через `IgnorePointer`

## Визуальная структура

```
┌───────────────────────────────┐
│  ╔═══════════════════════╗    │ ← Тень (shadow)
│  ║                       ║    │
│  ║   Градиентная         ║    │ ← Gradient highlight
│  ║   подсветка ↘         ║    │
│  ║                       ║    │
│  ║      Контент          ║    │ ← child с padding
│  ║                       ║    │
│  ╚═══════════════════════╝    │ ← Рамка (border)
└───────────────────────────────┘
```

## Примеры использования

### Базовое использование

```dart
KopimGlassSurface(
  child: Column(
    children: [
      Text('Заголовок', style: TextStyle(fontSize: 20)),
      SizedBox(height: 8),
      Text('Описание с glassmorphism эффектом'),
    ],
  ),
)
```

### Кликабельная карточка

```dart
KopimGlassSurface(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(...));
  },
  child: ListTile(
    leading: Icon(Icons.star),
    title: Text('Премиум функция'),
    subtitle: Text('Нажмите для подробностей'),
  ),
)
```

### С настройками стиля

```dart
KopimGlassSurface(
  borderRadius: BorderRadius.circular(16),
  padding: EdgeInsets.all(24),
  blurSigma: 12.0,
  baseOpacity: 0.9,  // Более непрозрачный
  gradientHighlightIntensity: 0.5,  // Слабая подсветка
  enableShadow: false,  // Без тени
  child: Text('Кастомный стиль'),
)
```

### Минималистичная стеклянная поверхность

```dart
KopimGlassSurface(
  enableBorder: false,
  enableGradientHighlight: false,
  enableShadow: false,
  blurSigma: 24.0,  // Усиленное размытие
  baseOpacity: 0.6,  // Высокая прозрачность
  child: Padding(
    padding: EdgeInsets.all(20),
    child: Text('Чистое размытие без эффектов'),
  ),
)
```

### С кастомным цветом тонировки

```dart
KopimGlassSurface(
  gradientTintColor: Colors.purple,
  gradientHighlightIntensity: 1.5,  // Усиленная подсветка
  child: Icon(Icons.favorite, size: 48, color: Colors.white),
)
```

## Использование в дизайне

**Рекомендуется для:**
- Модальных окон и диалогов
- Карточек премиум-функций
- Навигационных панелей
- Виджетов над фоновыми изображениями
- Элементов с эффектом "floating"

**Не рекомендуется:**
- В списках с большим количеством элементов (производительность)
- На устройствах с низкой производительностью
- Для текстовых полей (лучше использовать KopimTextField)

## Производительность

> **Внимание**: Эффект размытия (`BackdropFilter`) может быть ресурсоёмким. Не используйте в прокручиваемых списках с большим количеством элементов.

## Связанные файлы

- Исходный код: [`kopim_glass_surface.dart`](file:///home/artem/StudioProjects/kopim/lib/core/widgets/kopim_glass_surface.dart#L12-L190)
- Используется в: модальных окнах, карточках, навигационных элементах
