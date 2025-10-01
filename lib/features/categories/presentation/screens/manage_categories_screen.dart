import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/categories/presentation/controllers/category_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

/// Screen that exposes category creation and editing flows.
class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  static const String routeName = '/categories/manage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      manageCategoriesListProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(strings.profileManageCategoriesTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryEditor(context, ref),
        tooltip: strings.manageCategoriesAddAction,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          data: (List<Category> categories) {
            if (categories.isEmpty) {
              return _EmptyCategoriesView(
                message: strings.manageCategoriesEmpty,
              );
            }
            return _CategoriesList(
              categories: categories,
              onEdit: (Category category) =>
                  _showCategoryEditor(context, ref, category: category),
            );
          },
          error: (Object error, StackTrace? stackTrace) => _ErrorView(
            message: strings.manageCategoriesListError(error.toString()),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

Future<void> _showCategoryEditor(
  BuildContext context,
  WidgetRef ref, {
  Category? category,
}) async {
  final bool? didSave = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) {
      return _CategoryEditorSheet(category: category);
    },
  );

  if (didSave == true && context.mounted) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final String message = category == null
        ? strings.manageCategoriesSuccessCreate
        : strings.manageCategoriesSuccessUpdate;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CategoriesList extends StatelessWidget {
  const _CategoriesList({required this.categories, required this.onEdit});

  final List<Category> categories;
  final ValueChanged<Category> onEdit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (BuildContext context, int index) {
        final Category category = categories[index];
        final String typeLabel = category.type.toLowerCase() == 'income'
            ? strings.manageCategoriesTypeIncome
            : strings.manageCategoriesTypeExpense;
        final List<String> metadata = <String>[typeLabel];
        if (category.icon != null && category.icon!.isNotEmpty) {
          metadata.add(category.icon!);
        }
        if (category.color != null && category.color!.isNotEmpty) {
          metadata.add(category.color!);
        }
        return Card(
          child: ListTile(
            title: Text(category.name),
            subtitle: Text(metadata.join(' · ')),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: strings.manageCategoriesEditAction,
              onPressed: () => onEdit(category),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}

class _EmptyCategoriesView extends StatelessWidget {
  const _EmptyCategoriesView({required this.message});

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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

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

class _CategoryEditorSheet extends ConsumerWidget {
  const _CategoryEditorSheet({this.category});

  final Category? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final CategoryFormParams params = CategoryFormParams(initial: category);
    ref.listen<CategoryFormState>(categoryFormControllerProvider(params), (
      CategoryFormState? previous,
      CategoryFormState next,
    ) {
      if (next.isSuccess && previous?.isSuccess != next.isSuccess) {
        ref
            .read(categoryFormControllerProvider(params).notifier)
            .resetSuccess();
        Navigator.of(context).pop(true);
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                strings.manageCategoriesSaveError(next.errorMessage!),
              ),
            ),
          );
      }
    });

    final CategoryFormState state = ref.watch(
      categoryFormControllerProvider(params),
    );
    final CategoryFormController controller = ref.read(
      categoryFormControllerProvider(params).notifier,
    );

    final ThemeData theme = Theme.of(context);
    final String title = category == null
        ? strings.manageCategoriesCreateTitle
        : strings.manageCategoriesEditTitle;

    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;

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
            TextFormField(
              key: ValueKey<String>(
                'category-name-${state.id}-${state.updatedAt.millisecondsSinceEpoch}',
              ),
              initialValue: state.name,
              decoration: InputDecoration(
                labelText: strings.manageCategoriesNameLabel,
                errorText: state.nameHasError
                    ? strings.manageCategoriesNameRequired
                    : null,
              ),
              textInputAction: TextInputAction.next,
              onChanged: controller.updateName,
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: strings.manageCategoriesTypeLabel,
              ),
              child: SegmentedButton<String>(
                segments: <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'expense',
                    label: Text(strings.manageCategoriesTypeExpense),
                  ),
                  ButtonSegment<String>(
                    value: 'income',
                    label: Text(strings.manageCategoriesTypeIncome),
                  ),
                ],
                selected: <String>{state.type},
                onSelectionChanged: (Set<String> values) {
                  if (values.isEmpty) return;
                  controller.updateType(values.first);
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: ValueKey<String>(
                'category-icon-${state.id}-${state.updatedAt.millisecondsSinceEpoch}',
              ),
              initialValue: state.icon,
              decoration: InputDecoration(
                labelText: strings.manageCategoriesIconLabel,
              ),
              textInputAction: TextInputAction.next,
              onChanged: controller.updateIcon,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: ValueKey<String>(
                'category-color-${state.id}-${state.updatedAt.millisecondsSinceEpoch}',
              ),
              initialValue: state.color,
              decoration: InputDecoration(
                labelText: strings.manageCategoriesColorLabel,
              ),
              textInputAction: TextInputAction.done,
              onChanged: controller.updateColor,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: state.isSaving || !state.hasChanges
                  ? null
                  : () => controller.submit(),
              icon: state.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(strings.manageCategoriesSaveCta),
            ),
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                strings.manageCategoriesSaveError(state.errorMessage!),
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
