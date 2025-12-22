import 'package:flutter/foundation.dart';

/// Управляет состоянием раскрытия секций свернутого списка.
class CollapsibleListController extends ChangeNotifier {
  CollapsibleListController({Map<String, bool>? initialState})
    : _expansionState = Map<String, bool>.from(
        initialState ?? const <String, bool>{},
      );

  final Map<String, bool> _expansionState;

  bool isExpanded(String sectionId) => _expansionState[sectionId] ?? false;

  /// Переключает состояние секции и уведомляет слушателей.
  void toggle(String sectionId) =>
      setExpanded(sectionId, !isExpanded(sectionId));

  /// Устанавливает состояние секции, если оно изменилось.
  void setExpanded(String sectionId, bool expanded) {
    if (_expansionState[sectionId] == expanded) {
      return;
    }
    _expansionState[sectionId] = expanded;
    notifyListeners();
  }

  /// Регистрирует секцию, не меняя уже существующее состояние.
  void registerSection(String sectionId, {bool initiallyExpanded = false}) {
    _expansionState.putIfAbsent(sectionId, () => initiallyExpanded);
  }

  /// Скрывает все секции.
  void collapseAll() {
    if (_expansionState.values.every((bool value) => !value)) {
      return;
    }
    _expansionState.updateAll((String key, bool value) => false);
    notifyListeners();
  }

  /// Раскрывает все секции.
  void expandAll() {
    if (_expansionState.values.every((bool value) => value)) {
      return;
    }
    _expansionState.updateAll((String key, bool value) => true);
    notifyListeners();
  }

  /// Текущие состояния секций.
  Map<String, bool> get values =>
      Map<String, bool>.unmodifiable(_expansionState);
}
