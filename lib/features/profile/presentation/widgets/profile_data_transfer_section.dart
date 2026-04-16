import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/widgets/kopim_segmented_control.dart';
import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/presentation/controllers/export_user_data_controller.dart';
import 'package:kopim/features/settings/presentation/controllers/import_user_data_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class ProfileDataTransferSection extends ConsumerStatefulWidget {
  const ProfileDataTransferSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.sync_alt_outlined,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  ConsumerState<ProfileDataTransferSection> createState() =>
      _ProfileDataTransferSectionState();
}

class _ProfileDataTransferSectionState
    extends ConsumerState<ProfileDataTransferSection> {
  bool _isExpanded = false;
  String? _exportDirectoryPath;
  bool _isPickingDirectory = false;
  DataTransferFormat _format = DataTransferFormat.json;

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
    final ThemeData theme = Theme.of(context);
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    const bool canSelectDirectory = !kIsWeb;

    return Column(
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: <Widget>[
                Icon(widget.icon, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    strings.profileDataTransferFormatLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  KopimSegmentedControl<DataTransferFormat>(
                    options: <KopimSegmentedOption<DataTransferFormat>>[
                      KopimSegmentedOption<DataTransferFormat>(
                        value: DataTransferFormat.csv,
                        label: strings.profileDataTransferFormatCsv,
                        icon: Icons.table_chart_outlined,
                      ),
                      KopimSegmentedOption<DataTransferFormat>(
                        value: DataTransferFormat.json,
                        label: strings.profileDataTransferFormatJson,
                        icon: Icons.code_outlined,
                      ),
                    ],
                    selectedValue: _format,
                    onChanged: (DataTransferFormat value) {
                      setState(() => _format = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _DataTransferFormatHint(format: _format),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final bool stacked =
                              constraints.maxWidth < 420 || textScale > 1.05;
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
                  if (canSelectDirectory) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      strings.profileExportDataDestinationLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final bool stacked =
                                constraints.maxWidth < 460 || textScale > 1.05;
                            final Widget folderText = Text(
                              _exportDirectoryPath != null
                                  ? strings.profileExportDataSelectedFolder(
                                      _exportDirectoryPath!,
                                    )
                                  : strings.profileExportDataDefaultDestination,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            );
                            final Widget folderButton = OutlinedButton.icon(
                              onPressed: _isPickingDirectory
                                  ? null
                                  : () => _selectExportDirectory(context),
                              icon: _isPickingDirectory
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    )
                                  : const Icon(Icons.folder_open_outlined),
                              label: Text(
                                strings.profileExportDataSelectFolderCta,
                              ),
                            );
                            if (stacked) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  folderText,
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: folderButton,
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: <Widget>[
                                Expanded(child: folderText),
                                const SizedBox(width: 12),
                                folderButton,
                              ],
                            );
                          },
                    ),
                  ],
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Future<void> _selectExportDirectory(BuildContext context) async {
    if (_isPickingDirectory) {
      return;
    }
    setState(() => _isPickingDirectory = true);
    try {
      final AppLocalizations strings = AppLocalizations.of(context)!;
      final String? selected = await FilePicker.platform.getDirectoryPath(
        dialogTitle: strings.profileExportDataDirectoryPickerTitle,
      );
      if (!mounted) {
        return;
      }
      if (selected != null && selected.isNotEmpty) {
        setState(() => _exportDirectoryPath = selected);
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingDirectory = false);
      }
    }
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ExportUserDataController controller = ref.read(
      exportUserDataControllerProvider.notifier,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await controller.export(
      directoryPath: _exportDirectoryPath,
      format: _format,
    );
    final AsyncValue<ExportFileSaveResult?> state = ref.read(
      exportUserDataControllerProvider,
    );
    state.when(
      data: (ExportFileSaveResult? result) {
        if (result == null) {
          messenger.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(strings.genericErrorMessage),
            ),
          );
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
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(message),
            ),
          );
        controller.clearResult();
      },
      error: (Object error, StackTrace _) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(strings.profileExportDataFailure(error.toString())),
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
    await controller.importData(format: _format);
    final AsyncValue<ImportUserDataResult?> state = ref.read(
      importUserDataControllerProvider,
    );
    state.when(
      data: (ImportUserDataResult? result) {
        if (result == null) {
          messenger.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(strings.genericErrorMessage),
            ),
          );
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
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(message),
            ),
          );
        controller.clearResult();
      },
      error: (Object error, StackTrace _) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(strings.profileImportDataFailure(error.toString())),
            ),
          );
        controller.clearResult();
      },
      loading: () {},
    );
  }
}

class _DataTransferFormatHint extends StatelessWidget {
  const _DataTransferFormatHint({required this.format});

  final DataTransferFormat format;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final bool isJson = format == DataTransferFormat.json;
    final ColorScheme colors = theme.colorScheme;
    final Color background = isJson
        ? colors.secondaryContainer
        : colors.surfaceContainerHigh;
    final Color foreground = isJson
        ? colors.onSecondaryContainer
        : colors.onSurfaceVariant;
    final IconData icon = isJson
        ? Icons.verified_user_outlined
        : Icons.history_toggle_off_outlined;
    final String badge = isJson
        ? strings.profileDataTransferFormatHintJsonBadge
        : strings.profileDataTransferFormatHintCsvBadge;
    final String title = isJson
        ? strings.profileDataTransferFormatHintJsonTitle
        : strings.profileDataTransferFormatHintCsvTitle;
    final String body = isJson
        ? strings.profileDataTransferFormatHintJsonBody
        : strings.profileDataTransferFormatHintCsvBody;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: foreground.withValues(
                    alpha: (foreground.a * 0.12).clamp(0, 1).toDouble(),
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    badge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: theme.textTheme.bodySmall?.copyWith(color: foreground),
          ),
        ],
      ),
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
    final double disabledAlpha = background.a * 0.6;
    final Color displayBackground = disabled
        ? background.withValues(alpha: disabledAlpha)
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
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
