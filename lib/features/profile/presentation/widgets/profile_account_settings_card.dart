import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/widgets/kopim_dropdown_field.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_form_controller.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:kopim/features/profile/presentation/widgets/settings_button_theme.dart';
import 'package:kopim/l10n/app_localizations.dart';

class ProfileAccountSettingsCard extends ConsumerWidget {
  const ProfileAccountSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const _CenteredProgress(size: 24),
      error: (Object error, StackTrace? stackTrace) =>
          _InlineError(message: error.toString()),
      data: (AuthUser? user) {
        if (user == null) {
          return _InlineError(message: strings.profileSignInPrompt);
        }

        final AsyncValue<Profile?> profileAsync = ref.watch(
          profileControllerProvider(user.uid),
        );

        return _ProfileAccountForm(
          uid: user.uid,
          profileAsync: profileAsync,
          isAnonymous: user.isAnonymous,
        );
      },
    );
  }
}

class _ProfileAccountForm extends ConsumerStatefulWidget {
  const _ProfileAccountForm({
    required this.uid,
    required this.profileAsync,
    required this.isAnonymous,
  });

  final String uid;
  final AsyncValue<Profile?> profileAsync;
  final bool isAnonymous;

  @override
  ConsumerState<_ProfileAccountForm> createState() =>
      _ProfileAccountFormState();
}

class _ProfileAccountFormState extends ConsumerState<_ProfileAccountForm> {
  late ProfileFormControllerProvider _profileFormProvider;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _profileFormProvider = profileFormControllerProvider(
      ProfileFormParams(uid: widget.uid, profile: widget.profileAsync.value),
    );
    final ProfileFormState initialState = ref.read(_profileFormProvider);
    _nameController.text = initialState.name;
  }

  @override
  void didUpdateWidget(covariant _ProfileAccountForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Profile? currentProfile = widget.profileAsync.value;
    final Profile? oldProfile = oldWidget.profileAsync.value;
    if (currentProfile != oldProfile) {
      _profileFormProvider = profileFormControllerProvider(
        ProfileFormParams(uid: widget.uid, profile: currentProfile),
      );
      final ProfileFormState nextState = ref.read(_profileFormProvider);
      _nameController.value = TextEditingValue(
        text: nextState.name,
        selection: TextSelection.collapsed(offset: nextState.name.length),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ProfileFormControllerProvider provider = _profileFormProvider;

    ref.listen<ProfileFormState>(provider, (
      ProfileFormState? previous,
      ProfileFormState next,
    ) {
      if (previous?.name != next.name && _nameController.text != next.name) {
        _nameController.value = TextEditingValue(
          text: next.name,
          selection: TextSelection.collapsed(offset: next.name.length),
        );
      }
    });

    final ProfileCurrency currency = ref.watch(
      provider.select((ProfileFormState state) => state.currency),
    );
    final String locale = ref.watch(
      provider.select((ProfileFormState state) => state.locale),
    );
    final bool isSaving = ref.watch(
      provider.select((ProfileFormState state) => state.isSaving),
    );
    final bool hasChanges = ref.watch(
      provider.select((ProfileFormState state) => state.hasChanges),
    );
    final String? errorMessage = ref.watch(
      provider.select((ProfileFormState state) => state.errorMessage),
    );
    final Profile? initialProfile = ref.watch(
      provider.select((ProfileFormState state) => state.initialProfile),
    );

    final ProfileFormController formController = ref.read(provider.notifier);
    final List<String> locales = AppLocalizations.supportedLocales
        .map((Locale locale) => locale.toLanguageTag())
        .toList(growable: false);
    final int initialKey =
        initialProfile?.updatedAt.millisecondsSinceEpoch ?? 0;

    return Theme(
      data: buildSettingsButtonTheme(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.person_outline,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.profileSectionAccount,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          if (widget.isAnonymous) ...<Widget>[
            const SizedBox(height: 16),
            _AnonymousUpgradeBanner(strings: strings),
          ],
          const SizedBox(height: 16),
          Text(strings.profileNameLabel, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          KopimTextField(
            key: ValueKey<String>('profile-name-$initialKey'),
            controller: _nameController,
            placeholder: strings.profileNameLabel,
            fillColor: theme.colorScheme.surfaceContainerHigh,
            onChanged: formController.updateName,
          ),
          const SizedBox(height: 16),
          KopimDropdownField<ProfileCurrency>(
            key: ValueKey<String>(
              'profile-currency-$initialKey-${currency.name}',
            ),
            value: currency,
            label: strings.profileCurrencyLabel,
            items: ProfileCurrency.values
                .map(
                  (ProfileCurrency value) => DropdownMenuItem<ProfileCurrency>(
                    value: value,
                    child: Text(value.name.toUpperCase()),
                  ),
                )
                .toList(growable: false),
            onChanged: formController.updateCurrency,
            fillColor: theme.colorScheme.surfaceContainerHigh,
            valueLabelBuilder: (ProfileCurrency? value) =>
                value?.name.toUpperCase() ?? '',
          ),
          const SizedBox(height: 16),
          KopimDropdownField<String>(
            key: ValueKey<String>('profile-locale-$initialKey-$locale'),
            value: locale,
            label: strings.profileLocaleLabel,
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
            fillColor: theme.colorScheme.surfaceContainerHigh,
            valueLabelBuilder: (String? value) => value?.toUpperCase() ?? '',
          ),
          if (widget.profileAsync.hasError) ...<Widget>[
            const SizedBox(height: 12),
            _InlineError(
              message: strings.profileLoadError(
                widget.profileAsync.error.toString(),
              ),
            ),
          ],
          if (errorMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            _InlineError(message: errorMessage),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: !isSaving && hasChanges ? formController.submit : null,
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(strings.profileSaveCta),
          ),
          if (widget.profileAsync.isLoading) ...<Widget>[
            const SizedBox(height: 12),
            const _CenteredProgress(size: 20),
          ],
        ],
      ),
    );
  }
}

class _AnonymousUpgradeBanner extends StatelessWidget {
  const _AnonymousUpgradeBanner({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.profileRegisterHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SignInScreen(startInSignUpMode: true),
                ),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: Text(strings.profileRegisterCta),
          ),
        ],
      ),
    );
  }
}

class _CenteredProgress extends StatelessWidget {
  const _CenteredProgress({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
