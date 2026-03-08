import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/l10n/app_localizations.dart';

final FutureProvider<PackageInfo> packageInfoProvider =
    FutureProvider<PackageInfo>((Ref ref) {
      return PackageInfo.fromPlatform();
    });

class AboutAppScreen extends ConsumerWidget {
  const AboutAppScreen({super.key});

  static const String routeName = '/settings/about';
  static final Uri _emailUri = Uri(scheme: 'mailto', path: 'qmodo@qmodo.ru');

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

  Future<void> _openWebsite(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (launched || !context.mounted) {
      return;
    }
    final AppLocalizations strings = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.profileWebsiteOpenError)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final AsyncValue<AppConfig> appConfigAsync = ref.watch(appConfigProvider);
    final AsyncValue<PackageInfo> packageInfoAsync = ref.watch(
      packageInfoProvider,
    );
    final LegalConfig legalConfig = appConfigAsync.maybeWhen(
      data: (AppConfig config) => config.legal,
      orElse: () => const LegalConfig(
        privacyPolicyUrl: 'https://kopim.site/privacy.html',
        termsOfUseUrl: 'https://kopim.site/terms.html',
        accountDeletionUrl: 'https://kopim.site/delete-account.html',
        supportUrl: 'https://kopim.site/support.html',
      ),
    );
    final String versionLabel = packageInfoAsync.maybeWhen(
      data: (PackageInfo info) => '${info.version} (${info.buildNumber})',
      orElse: () => '1.0.1 (1)',
    );

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
                      title: strings.profileAboutSupportCta,
                      icon: Icons.support_agent_rounded,
                      onTap: () => _openWebsite(context, legalConfig.supportUrl),
                    ),
                    const SizedBox(height: 8),
                    _AboutActionCard(
                      title: strings.profileAboutPrivacyPolicyCta,
                      onTap: () =>
                          _openWebsite(context, legalConfig.privacyPolicyUrl),
                    ),
                    const SizedBox(height: 8),
                    _AboutActionCard(
                      title: strings.profileAboutTermsCta,
                      onTap: () =>
                          _openWebsite(context, legalConfig.termsOfUseUrl),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.profileAboutVersion(versionLabel),
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
