import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/overview/domain/entities/overview_preferences.dart';
import 'package:kopim/features/overview/presentation/controllers/overview_preferences_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class OverviewSettingsScreen extends ConsumerWidget {
  const OverviewSettingsScreen({super.key});

  static const String routeName = '/overview/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final KopimLayout layout = context.kopimLayout;
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<OverviewPreferences> preferencesAsync = ref.watch(
      overviewPreferencesControllerProvider,
    );
    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      homeAccountsProvider,
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      homeCategoriesProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(strings.overviewSettingsTitle)),
      body: preferencesAsync.when(
        data: (OverviewPreferences preferences) {
          return ListView(
            padding: EdgeInsets.all(layout.spacing.between),
            children: <Widget>[
              _SectionHeader(title: strings.overviewSettingsAccountsSection),
              accountsAsync.when(
                data: (List<AccountEntity> accounts) {
                  if (accounts.isEmpty) {
                    return _SectionPlaceholder(
                      message: strings.homeAccountsEmpty,
                    );
                  }
                  return _AccountsSelection(
                    accounts: accounts,
                    preferences: preferences,
                  );
                },
                loading: () => _SectionLoading(theme: theme),
                error: (Object error, _) => _SectionError(
                  message: strings.homeAccountsError(error.toString()),
                ),
              ),
              SizedBox(height: layout.spacing.between),
              _SectionHeader(title: strings.overviewSettingsCategoriesSection),
              categoriesAsync.when(
                data: (List<Category> categories) {
                  final List<Category> rootCategories = _rootCategories(
                    categories,
                  );
                  if (rootCategories.isEmpty) {
                    return _SectionPlaceholder(
                      message: strings.manageCategoriesEmpty,
                    );
                  }
                  return _CategoriesSelection(
                    categories: rootCategories,
                    preferences: preferences,
                  );
                },
                loading: () => _SectionLoading(theme: theme),
                error: (Object error, _) => _SectionError(
                  message: strings.manageCategoriesListError(error.toString()),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
        error: (Object error, _) => Center(
          child: Text(
            error.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _AccountsSelection extends ConsumerWidget {
  const _AccountsSelection({required this.accounts, required this.preferences});

  final List<AccountEntity> accounts;
  final OverviewPreferences preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Set<String> allIds = accounts
        .map((AccountEntity account) => account.id)
        .toSet();
    final Set<String> selectedIds = _resolveSelection(
      allIds,
      preferences.accountIds,
    );
    return Column(
      children: accounts
          .map((AccountEntity account) {
            final bool isSelected = selectedIds.contains(account.id);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (bool? value) {
                final Set<String> updated = Set<String>.from(selectedIds);
                if (value == true) {
                  updated.add(account.id);
                } else {
                  updated.remove(account.id);
                }
                ref
                    .read(overviewPreferencesControllerProvider.notifier)
                    .setAccountSelection(
                      selectedIds: updated,
                      allIds: allIds.toList(growable: false),
                    );
              },
              title: Text(account.name),
              controlAffinity: ListTileControlAffinity.leading,
            );
          })
          .toList(growable: false),
    );
  }
}

class _CategoriesSelection extends ConsumerWidget {
  const _CategoriesSelection({
    required this.categories,
    required this.preferences,
  });

  final List<Category> categories;
  final OverviewPreferences preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Set<String> allIds = categories
        .map((Category category) => category.id)
        .toSet();
    final Set<String> selectedIds = _resolveSelection(
      allIds,
      preferences.categoryIds,
    );
    return Column(
      children: categories
          .map((Category category) {
            final bool isSelected = selectedIds.contains(category.id);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (bool? value) {
                final Set<String> updated = Set<String>.from(selectedIds);
                if (value == true) {
                  updated.add(category.id);
                } else {
                  updated.remove(category.id);
                }
                ref
                    .read(overviewPreferencesControllerProvider.notifier)
                    .setCategorySelection(
                      selectedIds: updated,
                      allIds: allIds.toList(growable: false),
                    );
              },
              title: Text(category.name),
              controlAffinity: ListTileControlAffinity.leading,
            );
          })
          .toList(growable: false),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}

Set<String> _resolveSelection(Set<String> allIds, List<String>? storedIds) {
  if (storedIds == null) {
    return allIds;
  }
  return storedIds.where(allIds.contains).toSet();
}

List<Category> _rootCategories(List<Category> categories) {
  final Set<String> ids = categories
      .map((Category category) => category.id)
      .toSet();
  final List<Category> roots = categories
      .where((Category category) {
        final String? parentId = category.parentId;
        if (parentId == null || parentId.isEmpty) {
          return true;
        }
        return !ids.contains(parentId);
      })
      .toList(growable: false);
  roots.sort((Category a, Category b) => a.name.compareTo(b.name));
  return roots;
}
