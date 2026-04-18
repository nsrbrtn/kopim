import 'package:kopim/features/getting_started/domain/entities/getting_started_preferences.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_progress.dart';

class GettingStartedViewModel {
  const GettingStartedViewModel({
    required this.preferences,
    required this.progress,
    required this.shouldAutoActivate,
    required this.shouldDisplayOnHome,
  });

  final GettingStartedPreferences preferences;
  final GettingStartedProgress progress;
  final bool shouldAutoActivate;
  final bool shouldDisplayOnHome;
}
