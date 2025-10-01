import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

/// Responsive screen that exposes profile editing backed by Riverpod state.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationTabContent content = buildProfileTabContent(context, ref);
    return Scaffold(
      appBar: content.appBarBuilder?.call(context, ref),
      body: content.bodyBuilder(context, ref),
      floatingActionButton: content.floatingActionButtonBuilder?.call(
        context,
        ref,
      ),
    );
  }
}

NavigationTabContent buildProfileTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  return NavigationTabContent(
    appBarBuilder: (BuildContext context, WidgetRef ref) =>
        AppBar(title: Text(AppLocalizations.of(context)!.profileTitle)),
    bodyBuilder: (BuildContext context, WidgetRef ref) {
      final AppLocalizations strings = AppLocalizations.of(context)!;
      final ThemeData theme = ref.watch(appThemeProvider);
      final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);

      return authState.when(
        loading: () => const _CenteredProgress(),
        error: (Object error, StackTrace? stackTrace) =>
            _ErrorView(message: error.toString()),
        data: (AuthUser? user) {
          if (user == null) {
            return _ErrorView(message: strings.profileSignInPrompt);
          }

          final AsyncValue<Profile?> profileAsync = ref.watch(
            profileControllerProvider(user.uid),
          );
          final ProfileFormParams params = ProfileFormParams(
            uid: user.uid,
            profile: profileAsync.asData?.value,
          );

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double maxWidth = constraints.maxWidth >= 600
                  ? 520.0
                  : double.infinity;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _ProfileForm(
                      theme: theme,
                      params: params,
                      profileAsync: profileAsync,
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

class _ProfileForm extends ConsumerWidget {
  const _ProfileForm({
    required this.theme,
    required this.params,
    required this.profileAsync,
  });

  final ThemeData theme;
  final ProfileFormParams params;
  final AsyncValue<Profile?> profileAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ProfileFormControllerProvider profileFormProvider =
        profileFormControllerProvider(params);

    final String name = ref.watch(
      profileFormProvider.select((ProfileFormState state) => state.name),
    );
    final ProfileCurrency currency = ref.watch(
      profileFormProvider.select((ProfileFormState state) => state.currency),
    );
    final String locale = ref.watch(
      profileFormProvider.select((ProfileFormState state) => state.locale),
    );
    final bool isSaving = ref.watch(
      profileFormProvider.select((ProfileFormState state) => state.isSaving),
    );
    final bool hasChanges = ref.watch(
      profileFormProvider.select((ProfileFormState state) => state.hasChanges),
    );
    final String? errorMessage = ref.watch(
      profileFormProvider.select(
        (ProfileFormState state) => state.errorMessage,
      ),
    );
    final Profile? initialProfile = ref.watch(
      profileFormProvider.select(
        (ProfileFormState state) => state.initialProfile,
      ),
    );

    final ProfileFormController formController = ref.read(
      profileFormProvider.notifier,
    );

    final List<String> locales = AppLocalizations.supportedLocales
        .map((Locale locale) => locale.toLanguageTag())
        .toList(growable: false);

    final int initialKey =
        initialProfile?.updatedAt.millisecondsSinceEpoch ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _CollapsibleSection(
          title: strings.profileSectionAccount,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                key: ValueKey<String>('name-$initialKey'),
                initialValue: name,
                onChanged: formController.updateName,
                decoration: InputDecoration(
                  labelText: strings.profileNameLabel,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProfileCurrency>(
                key: ValueKey<String>('currency-$initialKey-${currency.name}'),
                initialValue: currency,
                decoration: InputDecoration(
                  labelText: strings.profileCurrencyLabel,
                  border: const OutlineInputBorder(),
                ),
                items: ProfileCurrency.values
                    .map(
                      (ProfileCurrency value) =>
                          DropdownMenuItem<ProfileCurrency>(
                            value: value,
                            child: Text(value.name.toUpperCase()),
                          ),
                    )
                    .toList(growable: false),
                onChanged: (ProfileCurrency? value) {
                  if (value != null) {
                    formController.updateCurrency(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey<String>('locale-$initialKey-$locale'),
                initialValue: locale,
                decoration: InputDecoration(
                  labelText: strings.profileLocaleLabel,
                  border: const OutlineInputBorder(),
                ),
                items: locales
                    .map(
                      (String code) => DropdownMenuItem<String>(
                        value: code,
                        child: Text(code.toUpperCase()),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (String? value) {
                  if (value != null) {
                    formController.updateLocale(value);
                  }
                },
              ),
              if (profileAsync.hasError) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  strings.profileLoadError(profileAsync.error.toString()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              if (errorMessage != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: !isSaving && hasChanges
                        ? () => formController.submit()
                        : null,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(strings.profileSaveCta),
                  ),
                  const SizedBox(width: 16),
                  if (profileAsync.isLoading) const _CenteredProgress(size: 20),
                ],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout),
                label: Text(strings.profileSignOutCta),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(ManageCategoriesScreen.routeName);
          },
          icon: const Icon(Icons.category_outlined),
          label: Text(strings.profileManageCategoriesCta),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ThemeData>('theme', theme))
      ..add(DiagnosticsProperty<ProfileFormParams>('params', params))
      ..add(
        DiagnosticsProperty<AsyncValue<Profile?>>('profileAsync', profileAsync),
      );
  }
}

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          title: Text(title, style: theme.textTheme.titleMedium),
          children: <Widget>[child],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(DiagnosticsProperty<Widget>('child', child));
  }
}

class _CenteredProgress extends StatelessWidget {
  const _CenteredProgress({this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
  }
}
