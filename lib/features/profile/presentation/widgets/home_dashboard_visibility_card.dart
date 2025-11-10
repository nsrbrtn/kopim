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
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? textStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final Color containerColor = theme.colorScheme.surfaceContainer;
    final List<_DashboardToggleConfig> toggles = <_DashboardToggleConfig>[
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

    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: _toggleExpanded,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.home_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.strings.settingsHomeSectionTitle,
                        style: textStyle,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              sizeCurve: Curves.easeInOut,
              crossFadeState: _isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    for (int index = 0; index < toggles.length; index++) ...<
                        Widget>[
                      if (index > 0) const SizedBox(height: 16),
                      _DashboardToggleTile(config: toggles[index]),
                    ],
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
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
          Switch.adaptive(
            value: config.value,
            onChanged: config.onChanged,
          ),
        ],
      ),
    );
  }
}
