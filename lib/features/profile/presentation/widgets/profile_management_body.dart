import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/theme/application/theme_mode_controller.dart';
import 'package:kopim/core/theme/domain/app_theme_mode.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_form_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/avatar_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/features/profile/presentation/widgets/settings_button_theme.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_overview_card.dart';

class ProfileManagementBody extends ConsumerWidget {
  const ProfileManagementBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
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
        final AsyncValue<UserProgress> progressAsync = ref.watch(
          userProgressProvider(user.uid),
        );
        final AsyncValue<void> avatarState = ref.watch(
          avatarControllerProvider,
        );

        ref.listen<AsyncValue<void>>(avatarControllerProvider, (
          AsyncValue<void>? previous,
          AsyncValue<void> next,
        ) {
          if (!context.mounted) {
            return;
          }
          if (next.hasError) {
            final String message = AppLocalizations.of(
              context,
            )!.profileAvatarUploadError;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
            return;
          }
          if (previous?.isLoading == true && next.hasValue) {
            final String message = AppLocalizations.of(
              context,
            )!.profileAvatarUploadSuccess;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }
        });

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
                    params: params,
                    profileAsync: profileAsync,
                    progressAsync: progressAsync,
                    avatarState: avatarState,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileForm extends ConsumerWidget {
  const _ProfileForm({
    required this.params,
    required this.profileAsync,
    required this.progressAsync,
    required this.avatarState,
  });

  final ProfileFormParams params;
  final AsyncValue<Profile?> profileAsync;
  final AsyncValue<UserProgress> progressAsync;
  final AsyncValue<void> avatarState;

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

    final ThemeData theme = Theme.of(context);

    final Profile? currentProfile = profileAsync.value ?? params.profile;

    return Theme(
      data: buildSettingsButtonTheme(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ProfileOverviewCard(
            profile: currentProfile,
            progressAsync: progressAsync,
            uid: params.uid,
            avatarState: avatarState,
          ),
          const SizedBox(height: 24),
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
                  key: ValueKey<String>(
                    'currency-$initialKey-${currency.name}',
                  ),
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
                    FilledButton.icon(
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
                    if (profileAsync.isLoading)
                      const _CenteredProgress(size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
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
          const ProfileThemePreferencesCard(),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ProfileFormParams>('params', params))
      ..add(
        DiagnosticsProperty<AsyncValue<Profile?>>('profileAsync', profileAsync),
      );
  }
}

class ProfileThemePreferencesCard extends ConsumerStatefulWidget {
  const ProfileThemePreferencesCard({super.key});

  @override
  ConsumerState<ProfileThemePreferencesCard> createState() =>
      _ProfileThemePreferencesCardState();
}

class _ProfileThemePreferencesCardState
    extends ConsumerState<ProfileThemePreferencesCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AppThemeMode mode = ref.watch(themeModeControllerProvider);
    final ThemeModeController controller = ref.read(
      themeModeControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);
    final Brightness brightness = theme.brightness;

    final bool isSystem = mode.maybeWhen(
      system: () => true,
      orElse: () => false,
    );
    final bool isDarkPreferred = mode.maybeWhen(
      dark: () => true,
      system: () => brightness == Brightness.dark,
      orElse: () => false,
    );

    final String subtitle = mode.when(
      system: () => strings.profileDarkModeSystemActive,
      light: () => strings.profileThemeLightDescription,
      dark: () => strings.profileThemeDarkDescription,
    );

    final List<_ThemeModeOption> options = <_ThemeModeOption>[
      _ThemeModeOption(
        mode: const AppThemeMode.system(),
        label: strings.profileThemeOptionSystem,
        description: strings.profileDarkModeSystemActive,
      ),
      _ThemeModeOption(
        mode: const AppThemeMode.light(),
        label: strings.profileThemeOptionLight,
        description: strings.profileThemeLightDescription,
      ),
      _ThemeModeOption(
        mode: const AppThemeMode.dark(),
        label: strings.profileThemeOptionDark,
        description: strings.profileThemeDarkDescription,
      ),
    ];
    final _ThemeModeOption activeOption = options.firstWhere(
      (_ThemeModeOption option) => option.mode == mode,
      orElse: () => options.first,
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          strings.profileThemeHeader,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(subtitle, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isDarkPreferred,
                    onChanged: (bool value) {
                      final AppThemeMode newMode = value
                          ? const AppThemeMode.dark()
                          : const AppThemeMode.light();
                      unawaited(controller.setMode(newMode));
                    },
                  ),
                  const SizedBox(width: 4),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_isExpanded) const Divider(height: 1),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SegmentedButton<AppThemeMode>(
                    segments: <ButtonSegment<AppThemeMode>>[
                      for (final _ThemeModeOption option in options)
                        ButtonSegment<AppThemeMode>(
                          value: option.mode,
                          label: Text(option.label),
                        ),
                    ],
                    selected: <AppThemeMode>{mode},
                    showSelectedIcon: false,
                    onSelectionChanged: (Set<AppThemeMode> selection) {
                      if (selection.isEmpty) {
                        return;
                      }
                      unawaited(controller.setMode(selection.first));
                    },
                  ),
                  if (activeOption.description != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      activeOption.description!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: isSystem
                          ? null
                          : () => unawaited(
                              controller.setMode(const AppThemeMode.system()),
                            ),
                      icon: const Icon(Icons.settings_backup_restore_outlined),
                      label: Text(strings.profileDarkModeSystemCta),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeModeOption {
  const _ThemeModeOption({
    required this.mode,
    required this.label,
    this.description,
  });

  final AppThemeMode mode;
  final String label;
  final String? description;
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
          key: PageStorageKey<String>('profile-section-$title'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          initiallyExpanded: true,
          title: Text(title, style: theme.textTheme.titleMedium),
          children: <Widget>[
            PageStorage(bucket: PageStorageBucket(), child: child),
          ],
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
