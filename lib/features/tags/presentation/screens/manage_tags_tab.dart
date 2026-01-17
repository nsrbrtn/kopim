import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/categories/presentation/utils/category_color_palette.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/presentation/controllers/tag_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

final StreamProvider<List<TagEntity>> manageTagsListProvider =
    StreamProvider.autoDispose<List<TagEntity>>((Ref ref) {
      return ref.watch(watchTagsUseCaseProvider).call();
    });

class ManageTagsTab extends ConsumerWidget {
  const ManageTagsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<TagEntity>> tagsAsync = ref.watch(
      manageTagsListProvider,
    );

    return tagsAsync.when(
      data: (List<TagEntity> tags) {
        if (tags.isEmpty) {
          return _EmptyTagsView(message: strings.manageTagsEmpty);
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
          itemCount: tags.length,
          itemBuilder: (BuildContext context, int index) {
            final TagEntity tag = tags[index];
            return _TagTile(
              tag: tag,
              onEdit: () =>
                  showTagEditor(context, ref, strings: strings, tag: tag),
              onDelete: () =>
                  _deleteTagFlow(context, ref, strings: strings, tag: tag),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 12),
        );
      },
      error: (Object error, _) => _ErrorTagsView(
        message: strings.manageTagsListError(error.toString()),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

Future<void> showTagEditor(
  BuildContext context,
  WidgetRef ref, {
  required AppLocalizations strings,
  TagEntity? tag,
}) async {
  final bool? didSave = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) {
      return _TagEditorSheet(tag: tag);
    },
  );

  if (didSave == true && context.mounted) {
    final String message = tag == null
        ? strings.manageTagsSuccessCreate
        : strings.manageTagsSuccessUpdate;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(duration: const Duration(seconds: 3), content: Text(message)),
      );
  }
}

Future<bool> _deleteTagFlow(
  BuildContext context,
  WidgetRef ref, {
  required AppLocalizations strings,
  required TagEntity tag,
}) async {
  final bool? shouldDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(strings.manageTagsDeleteConfirmTitle),
        content: Text(strings.manageTagsDeleteConfirmMessage(tag.name)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.manageTagsDeleteAction),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true || !context.mounted) {
    return false;
  }

  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(archiveTagUseCaseProvider)(tag.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(strings.manageTagsDeleteSuccess),
        ),
      );
    return true;
  } catch (error) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(strings.manageTagsDeleteError(error.toString())),
        ),
      );
    return false;
  }
}

class _TagTile extends StatelessWidget {
  const _TagTile({
    required this.tag,
    required this.onEdit,
    required this.onDelete,
  });

  final TagEntity tag;
  final Future<void> Function() onEdit;
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color? color = parseHexColor(tag.color);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color ?? theme.colorScheme.surfaceContainerHigh,
        ),
        title: Text(tag.name),
        onTap: onEdit,
        trailing: IconButton(
          tooltip: AppLocalizations.of(context)!.manageTagsDeleteAction,
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _TagEditorSheet extends ConsumerStatefulWidget {
  const _TagEditorSheet({this.tag});

  final TagEntity? tag;

  @override
  ConsumerState<_TagEditorSheet> createState() => _TagEditorSheetState();
}

class _TagEditorSheetState extends ConsumerState<_TagEditorSheet> {
  late final TagFormParams _params;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _params = TagFormParams(initial: widget.tag);
    final TagFormState initialState = ref.read(
      tagFormControllerProvider(_params),
    );
    _nameController = TextEditingController(text: initialState.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    ref.listen<TagFormState>(tagFormControllerProvider(_params), (
      TagFormState? previous,
      TagFormState next,
    ) {
      if (previous?.name != next.name && _nameController.text != next.name) {
        _nameController.value = _nameController.value.copyWith(
          text: next.name,
          selection: TextSelection.collapsed(offset: next.name.length),
        );
      }
      if (next.isSuccess && previous?.isSuccess != next.isSuccess) {
        ref.read(tagFormControllerProvider(_params).notifier).resetSuccess();
        Navigator.of(context).pop(true);
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(strings.manageTagsSaveError(next.errorMessage!)),
            ),
          );
      }
    });

    final TagFormState state = ref.watch(tagFormControllerProvider(_params));
    final TagFormController controller = ref.read(
      tagFormControllerProvider(_params).notifier,
    );

    final ThemeData theme = Theme.of(context);
    final String title = widget.tag == null
        ? strings.manageTagsCreateTitle
        : strings.manageTagsEditTitle;
    final Color? selectedColor = parseHexColor(state.color);
    final String colorSubtitle = selectedColor != null
        ? strings.manageTagsColorSelected
        : strings.manageTagsColorNone;
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;

    Future<void> selectColor() async {
      final String? hex = await _showTagColorPickerDialog(
        context: context,
        strings: strings,
        initialColor: selectedColor,
      );
      if (hex != null) {
        controller.updateColor(hex);
      }
    }

    final bool isFormComplete =
        state.name.trim().isNotEmpty && state.color.trim().isNotEmpty;
    final bool canSubmit =
        !state.isSaving && state.hasChanges && isFormComplete;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              strings.manageTagsNameLabel,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            KopimTextField(
              controller: _nameController,
              placeholder: strings.manageTagsNameLabel,
              textInputAction: TextInputAction.next,
              onChanged: controller.updateName,
            ),
            if (state.nameHasError) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                strings.manageTagsNameRequired,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.manageTagsColorLabel),
              subtitle: Text(colorSubtitle),
              onTap: selectColor,
              trailing: CircleAvatar(
                key: const ValueKey<String>('tag-color-preview'),
                backgroundColor:
                    selectedColor ?? theme.colorScheme.surfaceContainerHigh,
                foregroundColor: theme.colorScheme.onSurface,
                child: selectedColor == null
                    ? const Icon(Icons.palette_outlined)
                    : null,
              ),
            ),
            if (state.colorHasError) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                strings.manageTagsColorRequired,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: const StadiumBorder(),
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: canSubmit ? controller.submit : null,
              icon: state.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(strings.manageTagsSaveCta),
            ),
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                strings.manageTagsSaveError(state.errorMessage!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<String?> _showTagColorPickerDialog({
  required BuildContext context,
  required AppLocalizations strings,
  Color? initialColor,
}) {
  return showDialog<String>(
    context: context,
    useRootNavigator: false,
    builder: (BuildContext dialogContext) {
      return _TagColorPickerDialog(
        initialColor: initialColor,
        strings: strings,
      );
    },
  );
}

class _TagColorPickerDialog extends StatefulWidget {
  const _TagColorPickerDialog({this.initialColor, required this.strings});

  final Color? initialColor;
  final AppLocalizations strings;

  @override
  State<_TagColorPickerDialog> createState() => _TagColorPickerDialogState();
}

class _TagColorPickerDialogState extends State<_TagColorPickerDialog> {
  Color? _draftColor;

  @override
  void initState() {
    super.initState();
    _draftColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.strings.manageTagsColorPickerTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: kCategoryPastelPalette
                .asMap()
                .entries
                .map((MapEntry<int, Color> entry) {
                  final Color color = entry.value;
                  final bool isSelected = _draftColor == color;
                  return InkResponse(
                    key: ValueKey<String>('tag-color-${entry.key}'),
                    radius: 24,
                    onTap: () => setState(() => _draftColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.strings.dialogCancel),
        ),
        FilledButton(
          onPressed: _draftColor == null
              ? null
              : () => Navigator.of(context).pop(colorToHex(_draftColor!)!),
          child: Text(widget.strings.dialogConfirm),
        ),
      ],
    );
  }
}

class _EmptyTagsView extends StatelessWidget {
  const _EmptyTagsView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorTagsView extends StatelessWidget {
  const _ErrorTagsView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
