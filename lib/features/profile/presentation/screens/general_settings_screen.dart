import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/profile/presentation/widgets/profile_theme_preferences_card.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/presentation/controllers/exact_alarm_controller.dart';
import 'package:kopim/features/settings/presentation/controllers/export_user_data_controller.dart';
import 'package:kopim/features/settings/presentation/controllers/import_user_data_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  static const String routeName = '/settings/general';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileGeneralSettingsTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const <Widget>[
            _SettingsSectionContainer(child: ProfileThemePreferencesCard()),
            SizedBox(height: 16),
            _ExactRemindersSection(),
            SizedBox(height: 16),
            _DataTransferSection(),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionContainer extends StatelessWidget {
  const _SettingsSectionContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color background = theme.colorScheme.surfaceContainerHighest.withAlpha(
      (255 * (isDark ? 0.4 : 0.8)).round(),
    );
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}

class _ExactRemindersSection extends ConsumerWidget {
  const _ExactRemindersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<bool> permissionAsync = ref.watch(
      exactAlarmControllerProvider,
    );
    final ThemeData theme = Theme.of(context);

    return _SettingsSectionContainer(
      child: permissionAsync.when(
        data: (bool isEnabled) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.notifications_active_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        strings.settingsNotificationsExactTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.settingsNotificationsExactSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isEnabled,
                  onChanged: (_) => ref
                      .read(exactAlarmControllerProvider.notifier)
                      .request(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => ref
                    .read(exactAlarmControllerProvider.notifier)
                    .refresh(),
                icon: const Icon(Icons.refresh),
                label: Text(strings.settingsNotificationsRetryTooltip),
              ),
            ),
          ],
        ),
        loading: () => Row(
          children: <Widget>[
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(strings.settingsNotificationsExactTitle),
          ],
        ),
        error: (Object error, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.notifications_active_outlined,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.settingsNotificationsExactTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              strings.settingsNotificationsExactError(error.toString()),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => ref
                    .read(exactAlarmControllerProvider.notifier)
                    .refresh(),
                icon: const Icon(Icons.refresh),
                label: Text(strings.settingsNotificationsRetryTooltip),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataTransferSection extends ConsumerStatefulWidget {
  const _DataTransferSection();

  @override
  ConsumerState<_DataTransferSection> createState() =>
      _DataTransferSectionState();
}

class _DataTransferSectionState extends ConsumerState<_DataTransferSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<ExportFileSaveResult?> exportState = ref.watch(
      exportUserDataControllerProvider,
    );
    final AsyncValue<ImportUserDataResult?> importState = ref.watch(
      importUserDataControllerProvider,
    );
    final bool isExporting = exportState.isLoading;
    final bool isImporting = importState.isLoading;

    return _SettingsSectionContainer(
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.sync_alt_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          strings.profileGeneralSettingsManagementSection,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.profileImportDataCta,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
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
                padding: const EdgeInsets.only(top: 16),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool stacked = constraints.maxWidth < 360;
                    final double buttonWidth = stacked
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2;
                    final Widget exportButton = SizedBox(
                      width: buttonWidth,
                      child: _RoundedActionButton(
                        label: strings.profileExportDataCta,
                        icon: Icons.upload_file_outlined,
                        onPressed: isExporting
                            ? null
                            : () => _handleExport(context, ref),
                        isLoading: isExporting,
                      ),
                    );
                    final Widget importButton = SizedBox(
                      width: buttonWidth,
                      child: _RoundedActionButton(
                        label: strings.profileImportDataCta,
                        icon: Icons.download_for_offline_outlined,
                        onPressed: isImporting
                            ? null
                            : () => _handleImport(context, ref),
                        isLoading: isImporting,
                      ),
                    );
                    if (stacked) {
                      return Column(
                        children: <Widget>[
                          exportButton,
                          const SizedBox(height: 12),
                          importButton,
                        ],
                      );
                    }
                    return Row(
                      children: <Widget>[
                        exportButton,
                        const SizedBox(width: 12),
                        importButton,
                      ],
                    );
                  },
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ExportUserDataController controller = ref.read(
      exportUserDataControllerProvider.notifier,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await controller.export();
    final AsyncValue<ExportFileSaveResult?> state = ref.read(
      exportUserDataControllerProvider,
    );
    state.when(
      data: (ExportFileSaveResult? result) {
        if (result == null) {
          messenger
              .showSnackBar(SnackBar(content: Text(strings.genericErrorMessage)));
          return;
        }
        final String message = result.isSuccess
            ? (result.filePath?.isNotEmpty == true
                ? strings.profileExportDataSuccessWithPath(result.filePath!)
                : strings.profileExportDataSuccess)
            : strings.profileExportDataFailure(
                result.errorMessage ?? strings.genericErrorMessage,
              );
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        controller.clearResult();
      },
      error: (Object error, StackTrace _) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                strings.profileExportDataFailure(error.toString()),
              ),
            ),
          );
        controller.clearResult();
      },
      loading: () {},
    );
  }

  Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ImportUserDataController controller = ref.read(
      importUserDataControllerProvider.notifier,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await controller.importData();
    final AsyncValue<ImportUserDataResult?> state = ref.read(
      importUserDataControllerProvider,
    );
    state.when(
      data: (ImportUserDataResult? result) {
        if (result == null) {
          messenger
              .showSnackBar(SnackBar(content: Text(strings.genericErrorMessage)));
          return;
        }
        final String message = result.map(
          success: (ImportUserDataResultSuccess value) =>
              strings.profileImportDataSuccessWithStats(
                value.accounts,
                value.categories,
                value.transactions,
              ),
          cancelled: (_) => strings.profileImportDataCancelled,
          failure: (ImportUserDataResultFailure value) =>
              strings.profileImportDataFailure(value.message),
        );
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        controller.clearResult();
      },
      error: (Object error, StackTrace _) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                strings.profileImportDataFailure(error.toString()),
              ),
            ),
          );
        controller.clearResult();
      },
      loading: () {},
    );
  }
}

class _RoundedActionButton extends StatelessWidget {
  const _RoundedActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background = theme.colorScheme.secondaryContainer;
    final Color foreground = theme.colorScheme.onSecondaryContainer;
    final bool disabled = onPressed == null;
    final Color displayBackground = disabled
        ? background.withAlpha((background.alpha * 0.6).round())
        : background;
    return Material(
      color: displayBackground,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: disabled ? null : onPressed,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                )
              else
                Icon(icon, color: foreground),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
