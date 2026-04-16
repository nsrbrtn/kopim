import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kopim/features/app_shell/presentation/widgets/main_navigation_bar.dart';
import 'package:kopim/features/app_shell/presentation/widgets/navigation_responsive_breakpoints.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/profile/presentation/screens/about_app_screen.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/profile/presentation/widgets/home_dashboard_visibility_card.dart';
import 'package:kopim/features/savings/presentation/screens/savings_list_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  static const String routeName = '/menu';
  static const double _footerHeight = 28;
  static const double _footerBottomGap = 12;
  static const double _menuItemVerticalPadding = 19;
  static const double _itemsGap = 8;
  static final Uri _qmodoWebsiteUri = Uri.parse('https://qmodo.ru');
  static const String _qmodoLogoLightAsset = 'assets/icons/logoqlight.png';
  static const String _qmodoLogoDarkAsset = 'assets/icons/logoqdark.png';

  void _pushRoute(BuildContext context, String routeName) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push(routeName);
      return;
    }
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator != null) {
      navigator.pushNamed(routeName);
    }
  }

  double _footerBottomPadding(BuildContext context) {
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final double width = MediaQuery.sizeOf(context).width;
    final bool usesBottomNav = width < kMainNavigationRailBreakpoint;
    final double navigationClearance = usesBottomNav
        ? MainNavigationBar.height
        : 0;
    return bottomInset + navigationClearance + _footerBottomGap;
  }

  double _listBottomPadding(BuildContext context) {
    return _footerBottomPadding(context) + _footerHeight + 16;
  }

  Future<void> _openQmodoWebsite(BuildContext context) async {
    final bool launched = await launchUrl(
      _qmodoWebsiteUri,
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

  Future<void> _openHomeSectionSheet(BuildContext context) async {
    final AppLocalizations strings = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? _) {
                final AsyncValue<HomeDashboardPreferences> preferencesAsync =
                    ref.watch(homeDashboardPreferencesControllerProvider);
                return preferencesAsync.when(
                  data: (HomeDashboardPreferences preferences) =>
                      HomeDashboardVisibilityCard(
                        strings: strings,
                        preferences: preferences,
                        onToggleBudget: (bool value) => ref
                            .read(
                              homeDashboardPreferencesControllerProvider
                                  .notifier,
                            )
                            .setShowBudget(value),
                        onToggleRecurring: (bool value) => ref
                            .read(
                              homeDashboardPreferencesControllerProvider
                                  .notifier,
                            )
                            .setShowRecurring(value),
                        onToggleSavings: (bool value) => ref
                            .read(
                              homeDashboardPreferencesControllerProvider
                                  .notifier,
                            )
                            .setShowSavings(value),
                      ),
                  loading: () => const _SettingsSkeleton(),
                  error: (Object error, _) => _SettingsErrorMessage(
                    message: strings.homeDashboardPreferencesError(
                      error.toString(),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final List<_SettingsMenuConfig> menuItems = <_SettingsMenuConfig>[
      _SettingsMenuConfig(
        label: strings.upcomingPaymentsTitle,
        icon: Icons.event_repeat_outlined,
        onTap: () => _pushRoute(context, UpcomingPaymentsScreen.routeName),
      ),
      _SettingsMenuConfig(
        label: strings.creditsTitle,
        icon: Icons.account_balance_outlined,
        onTap: () => _pushRoute(context, '/credits'),
      ),
      _SettingsMenuConfig(
        label: strings.profileMenuCategoriesTagsCta,
        icon: Icons.category_outlined,
        onTap: () => _pushRoute(context, ManageCategoriesScreen.routeName),
      ),
      _SettingsMenuConfig(
        label: strings.savingsTitle,
        icon: Icons.savings_outlined,
        onTap: () => _pushRoute(context, SavingsListScreen.routeName),
      ),
      _SettingsMenuConfig(
        label: strings.profileMenuHomeSettingsCta,
        icon: Icons.home_outlined,
        onTap: () => _openHomeSectionSheet(context),
      ),
      _SettingsMenuConfig(
        label: strings.profileAboutAppCta,
        icon: Icons.info_outline,
        onTap: () => _pushRoute(context, AboutAppScreen.routeName),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileMenuTitle),
        actions: <Widget>[
          IconButton(
            tooltip: strings.profileGeneralSettingsTooltip,
            onPressed: () => _openGeneralSettings(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                _listBottomPadding(context),
              ),
              children: <Widget>[
                for (final _SettingsMenuConfig config in menuItems) ...<Widget>[
                  _SettingsMenuItem(
                    icon: config.icon,
                    label: config.label,
                    onTap: config.onTap,
                    textStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    backgroundColor: _settingsMenuContainerColor(theme),
                    borderRadius: 28,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: _menuItemVerticalPadding,
                    ),
                  ),
                  const SizedBox(height: _itemsGap),
                ],
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: _footerBottomPadding(context),
              child: _QmodoFooter(
                lightLogoPath: _qmodoLogoLightAsset,
                darkLogoPath: _qmodoLogoDarkAsset,
                title: strings.profileMadeInLabel,
                isDarkTheme: theme.brightness == Brightness.dark,
                onLogoTap: () => _openQmodoWebsite(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QmodoFooter extends StatelessWidget {
  const _QmodoFooter({
    required this.title,
    required this.lightLogoPath,
    required this.darkLogoPath,
    required this.isDarkTheme,
    required this.onLogoTap,
  });

  final String title;
  final String lightLogoPath;
  final String darkLogoPath;
  final bool isDarkTheme;
  final VoidCallback onLogoTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String logoPath = isDarkTheme ? darkLogoPath : lightLogoPath;
    final Color fallbackColor = isDarkTheme
        ? const Color(0xFF93FFC4)
        : const Color(0xFF141314);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(title, style: theme.textTheme.bodyLarge),
        const SizedBox(width: 6),
        InkWell(
          onTap: onLogoTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Image.asset(
              logoPath,
              width: 70,
              height: 18,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Text(
                'Qmodo',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: fallbackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsMenuConfig {
  const _SettingsMenuConfig({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _SettingsMenuItem extends StatelessWidget {
  const _SettingsMenuItem({
    required this.icon,
    required this.label,
    required this.textStyle,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 16,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
  });

  final IconData icon;
  final String label;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconColor = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: contentPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[Text(label, style: textStyle)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _settingsMenuContainerColor(ThemeData theme) {
  return theme.colorScheme.surfaceContainer;
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SettingsErrorMessage extends StatelessWidget {
  const _SettingsErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

Future<void> _openGeneralSettings(BuildContext context) async {
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const GeneralSettingsScreen(),
    ),
  );
}
