import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the active index of the main navigation shell.
class MainNavigationController extends Notifier<int> {
  @override
  int build() {
    return 0; // initial state
  }

  void setIndex(int index) {
    if (index == state) return;
    state = index;
  }
}

final NotifierProvider<MainNavigationController, int> mainNavigationControllerProvider =
NotifierProvider<MainNavigationController, int>(
  MainNavigationController.new,
);
