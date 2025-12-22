import 'package:flutter/material.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeDashboardVisibilityCard extends StatefulWidget {
  const HomeDashboardVisibilityCard({
    super.key,
    required this.strings,
    required this.preferences,
    required this.onToggleGamification,
    required this.onToggleBudget,
    required this.onToggleRecurring,
    required this.onToggleSavings,
  });

  final AppLocalizations strings;
  final HomeDashboardPreferences preferences;
  final ValueChanged<bool> onToggleGamification;
  final ValueChanged<bool> onToggleBudget;
  final ValueChanged<bool> onToggleRecurring;
  final ValueChanged<bool> onToggleSavings;

  @override
  State<HomeDashboardVisibilityCard> createState() =>
      _HomeDashboardVisibilityCardState();
}

class _HomeDashboardVisibilityCardState
    extends State<HomeDashboardVisibilityCard> {
  List<_DashboardToggleConfig> get _toggles => <_DashboardToggleConfig>[
    _DashboardToggleConfig(
      label: widget.strings.settingsHomeGamificationTitle,
      value: widget.preferences.showGamificationWidget,
      onChanged: widget.onToggleGamification,
    ),
    _DashboardToggleConfig(
      label: widget.strings.settingsHomeBudgetTitle,
      value: widget.preferences.showBudgetWidget,
      onChanged: widget.onToggleBudget,
    ),
    _DashboardToggleConfig(
      label: widget.strings.settingsHomeRecurringTitle,
      value: widget.preferences.showRecurringWidget,
      onChanged: widget.onToggleRecurring,
    ),
    _DashboardToggleConfig(
      label: widget.strings.settingsHomeSavingsTitle,
      value: widget.preferences.showSavingsWidget,
      onChanged: widget.onToggleSavings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 16),
        for (int index = 0; index < _toggles.length; index++) ...<Widget>[
          if (index > 0) const SizedBox(height: 16),
          _DashboardToggleTile(config: _toggles[index]),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DashboardToggleConfig {
  const _DashboardToggleConfig({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
}

class _DashboardToggleTile extends StatelessWidget {
  const _DashboardToggleTile({required this.config});

  final _DashboardToggleConfig config;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color tileColor = theme.colorScheme.surfaceContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              config.label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Switch.adaptive(value: config.value, onChanged: config.onChanged),
        ],
      ),
    );
  }
}
