import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainNavigationState {
  const MainNavigationState({
    required this.currentIndex,
    required this.history,
  });

  final int currentIndex;
  final List<int> history;

  MainNavigationState copyWith({int? currentIndex, List<int>? history}) {
    return MainNavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      history: history ?? this.history,
    );
  }
}

/// Управляет текущим табом и историей переключений.
///
/// Важно: историю пишем только из нижней навигации (см. `selectFromBottomNav`).
class MainNavigationController extends Notifier<MainNavigationState> {
  @override
  MainNavigationState build() {
    return const MainNavigationState(currentIndex: 0, history: <int>[]);
  }

  void setIndex(int index) {
    if (index == state.currentIndex) return;
    state = state.copyWith(currentIndex: index);
  }

  void selectFromBottomNav(int index) {
    if (index == state.currentIndex) return;

    final List<int> history = List<int>.from(state.history);
    if (history.isEmpty || history.last != state.currentIndex) {
      history.add(state.currentIndex);
    }

    state = MainNavigationState(currentIndex: index, history: history);
  }

  bool popHistory() {
    if (state.history.isEmpty) {
      return false;
    }

    final List<int> history = List<int>.from(state.history);
    final int previousIndex = history.removeLast();
    state = MainNavigationState(currentIndex: previousIndex, history: history);
    return true;
  }
}

final NotifierProvider<MainNavigationController, MainNavigationState>
mainNavigationControllerProvider =
    NotifierProvider<MainNavigationController, MainNavigationState>(
      MainNavigationController.new,
    );
