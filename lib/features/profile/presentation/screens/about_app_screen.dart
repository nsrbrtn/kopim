import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kopim/l10n/app_localizations.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const String routeName = '/settings/about';
  static final Uri _emailUri = Uri(scheme: 'mailto', path: 'qmodo@qmodo.ru');
  static const String _appVersion = '1.0.1';

  Future<void> _openEmail(BuildContext context) async {
    final bool launched = await launchUrl(_emailUri);
    if (launched || !context.mounted) {
      return;
    }
    final AppLocalizations strings = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.profileAboutEmailOpenError)));
  }

  void _showPlaceholder(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.profileAboutPlaceholderMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.profileAboutAppCta)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _AboutCard(
                      child: Text(
                        strings.profileAboutDescription,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AboutActionCard(
                      title: strings.profileAboutEmailCta,
                      icon: Icons.mail_outline_rounded,
                      onTap: () => _openEmail(context),
                    ),
                    const SizedBox(height: 8),
                    _AboutActionCard(
                      title: strings.profileAboutPrivacyPolicyCta,
                      onTap: () => _showPlaceholder(context),
                    ),
                    const SizedBox(height: 8),
                    _AboutActionCard(
                      title: strings.profileAboutTermsCta,
                      onTap: () => _showPlaceholder(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.profileAboutVersion(_appVersion),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}

class _AboutActionCard extends StatelessWidget {
  const _AboutActionCard({required this.title, this.icon, this.onTap});

  final String title;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, size: 24, color: theme.colorScheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
