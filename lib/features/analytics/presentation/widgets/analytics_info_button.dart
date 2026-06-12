import 'package:flutter/material.dart';
import 'package:kopim/l10n/app_localizations.dart';

class AnalyticsInfoButton extends StatelessWidget {
  const AnalyticsInfoButton({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return IconButton(
      onPressed: () => _showInfoDialog(context),
      icon: Icon(Icons.question_mark, size: 24, color: colors.outline),
      tooltip: strings.analyticsInfoTitle,
      visualDensity: VisualDensity.compact,
      splashRadius: 20,
    );
  }

  Future<void> _showInfoDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.surfaceContainerHigh,
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
          content: Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                strings.analyticsDialogClose,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
