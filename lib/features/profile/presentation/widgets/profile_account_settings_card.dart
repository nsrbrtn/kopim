import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/widgets/kopim_dropdown_field.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_form_controller.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:kopim/features/profile/presentation/utils/auth_error_mapper.dart';
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
          email: user.email,
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
    required this.email,
  });

  final String uid;
  final AsyncValue<Profile?> profileAsync;
  final bool isAnonymous;
  final String? email;

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
          if (widget.isAnonymous && !AppRuntimeConfig.isOffline) ...<Widget>[
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
          if (!widget.isAnonymous) ...<Widget>[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isSaving
                  ? null
                  : () => _showDeleteAccountDialog(context, ref, strings),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(strings.profileDeleteAccountCta),
            ),
          ],
          if (widget.profileAsync.isLoading) ...<Widget>[
            const SizedBox(height: 12),
            const _CenteredProgress(size: 20),
          ],
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations strings,
  ) async {
    final TextEditingController confirmationController =
        TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final String confirmationPhrase = strings.profileDeleteAccountPhrase;
    bool isSubmitting = false;
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder:
              (
                BuildContext dialogBodyContext,
                void Function(void Function()) setState,
              ) {
                final bool canSubmit =
                    confirmationController.text.trim() == confirmationPhrase &&
                    passwordController.text.isNotEmpty &&
                    !isSubmitting;

                return AlertDialog(
                  title: Text(strings.profileDeleteAccountTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(strings.profileDeleteAccountDescription),
                      if (widget.email != null &&
                          widget.email!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          widget.email!,
                          style: Theme.of(dialogBodyContext).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  dialogBodyContext,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmationController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: strings.profileDeleteAccountConfirmLabel,
                          helperText: strings.profileDeleteAccountConfirmHint(
                            confirmationPhrase,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: strings.profileDeleteAccountPasswordLabel,
                        ),
                      ),
                      if (errorText != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          errorText!,
                          style: Theme.of(dialogBodyContext).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  dialogBodyContext,
                                ).colorScheme.error,
                              ),
                        ),
                      ],
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      child: Text(strings.cancelButtonLabel),
                    ),
                    FilledButton(
                      onPressed: canSubmit
                          ? () async {
                              setState(() {
                                isSubmitting = true;
                                errorText = null;
                              });
                              try {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .deleteAccount(
                                      currentPassword: passwordController.text
                                          .trim(),
                                    );
                                if (!dialogBodyContext.mounted) {
                                  return;
                                }
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(dialogBodyContext)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        strings.profileDeleteAccountSuccess,
                                      ),
                                    ),
                                  );
                              } on AuthFailure catch (failure) {
                                setState(() {
                                  isSubmitting = false;
                                  errorText = AuthErrorMapper.map(
                                    failure.code,
                                    strings,
                                  );
                                });
                              }
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(
                          dialogBodyContext,
                        ).colorScheme.error,
                        foregroundColor: Theme.of(
                          dialogBodyContext,
                        ).colorScheme.onError,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(strings.profileDeleteAccountAction),
                    ),
                  ],
                );
              },
        );
      },
    );

    confirmationController.dispose();
    passwordController.dispose();
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
