import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_form_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/avatar_controller.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:kopim/features/profile/domain/exceptions/avatar_storage_exception.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/features/profile/presentation/widgets/settings_button_theme.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_overview_card.dart';
import 'package:kopim/core/widgets/kopim_dropdown_field.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';

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
          final AppLocalizations strings = AppLocalizations.of(context)!;
          if (next.hasError) {
            final String message = _mapAvatarError(strings, next.error);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
            return;
          }
          if (previous?.isLoading == true && next.hasValue) {
            final String message = strings.profileAvatarUploadSuccess;
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
                    authUser: user,
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

String _mapAvatarError(AppLocalizations strings, Object? error) {
  if (error is AvatarStorageException) {
    return strings.profileAvatarUploadError;
  }
  return strings.profileAvatarUploadError;
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({
    required this.params,
    required this.profileAsync,
    required this.progressAsync,
    required this.avatarState,
    required this.authUser,
  });

  final ProfileFormParams params;
  final AsyncValue<Profile?> profileAsync;
  final AsyncValue<UserProgress> progressAsync;
  final AsyncValue<void> avatarState;
  final AuthUser authUser;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();

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

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final ProfileFormControllerProvider _profileFormProvider;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _profileFormProvider = profileFormControllerProvider(widget.params);
    _nameController = TextEditingController();
    final ProfileFormState initialState = ref.read(_profileFormProvider);
    _nameController.text = initialState.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ProfileFormControllerProvider profileFormProvider =
        _profileFormProvider;
    ref.listen<ProfileFormState>(
      profileFormProvider,
      (ProfileFormState? previous, ProfileFormState next) {
        if (previous?.name != next.name &&
            _nameController.text != next.name) {
          _nameController.value = TextEditingValue(
            text: next.name,
            selection: TextSelection.collapsed(offset: next.name.length),
          );
        }
      },
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

    final Profile? currentProfile =
        widget.profileAsync.value ?? widget.params.profile;

    return Theme(
      data: buildSettingsButtonTheme(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (widget.authUser.isAnonymous) ...<Widget>[
            _AnonymousUpgradeBanner(
              strings: strings,
              onRegister: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SignInScreen(startInSignUpMode: true),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          ProfileOverviewCard(
            profile: currentProfile,
            progressAsync: widget.progressAsync,
            uid: widget.params.uid,
            avatarState: widget.avatarState,
          ),
          const SizedBox(height: 24),
          KopimExpandableSectionPlayful(
            key: const PageStorageKey<String>('profile-section-account'),
            title: strings.profileSectionAccount,
            leading: Icon(
              Icons.person_outline,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  strings.profileNameLabel,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                KopimTextField(
                  key: ValueKey<String>('name-$initialKey'),
                  controller: _nameController,
                  placeholder: strings.profileNameLabel,
                  fillColor: theme.colorScheme.surfaceContainerHigh,
                  onChanged: formController.updateName,
                ),
                const SizedBox(height: 16),
                KopimDropdownField<ProfileCurrency>(
                  key: ValueKey<String>('currency-$initialKey-${currency.name}'),
                  value: currency,
                  label: strings.profileCurrencyLabel,
                  items: ProfileCurrency.values
                      .map(
                        (ProfileCurrency value) => DropdownMenuItem<ProfileCurrency>(
                          value: value,
                          child: Text(value.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: formController.updateCurrency,
                  valueLabelBuilder: (ProfileCurrency? value) =>
                      value?.name.toUpperCase() ?? '',
                ),
                const SizedBox(height: 16),
                KopimDropdownField<String>(
                  key: ValueKey<String>('locale-$initialKey-$locale'),
                  value: locale,
                  label: strings.profileLocaleLabel,
                  items: locales
                      .map(
                        (String code) => DropdownMenuItem<String>(
                          value: code,
                          child: Text(code.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      formController.updateLocale(value);
                    }
                  },
                  valueLabelBuilder: (String? value) => value?.toUpperCase() ?? '',
                ),
                if (widget.profileAsync.hasError) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    strings.profileLoadError(
                      widget.profileAsync.error.toString(),
                    ),
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
                    if (widget.profileAsync.isLoading)
                      const _CenteredProgress(size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    final NavigatorState navigator = Navigator.of(context);
                    try {
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (!context.mounted) {
                        return;
                      }
                      navigator.popUntil(
                        (Route<dynamic> route) => route.isFirst,
                      );
                    } on AuthFailure catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text(error.message)));
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(strings.profileSignOutCta),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnonymousUpgradeBanner extends StatelessWidget {
  const _AnonymousUpgradeBanner({
    required this.strings,
    required this.onRegister,
  });

  final AppLocalizations strings;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.profileRegisterHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRegister,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(strings.profileRegisterCta),
            ),
          ],
        ),
      ),
    );
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
