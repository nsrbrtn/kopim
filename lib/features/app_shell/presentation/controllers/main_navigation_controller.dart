import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the active index of the main navigation shell.
class MainNavigationController extends StateNotifier<int> {
  MainNavigationController() : super(0);

  void setIndex(int index) {
    if (index == state) {
      return;
    }
    state = index;
  }
}

final mainNavigationControllerProvider =
    StateNotifierProvider<MainNavigationController, int>((Ref ref) {
  return MainNavigationController();
});
