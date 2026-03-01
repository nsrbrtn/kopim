import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/utils/auth_error_mapper.dart';
import 'package:kopim/l10n/app_localizations.dart';

class ProfileCredentialsSettingsCard extends ConsumerWidget {
  const ProfileCredentialsSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (Object error, StackTrace? stackTrace) => Text(
        error.toString(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
      data: (AuthUser? user) {
        if (user == null) {
          return Text(
            strings.profileSignInPrompt,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        if (user.isAnonymous) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Header(strings: strings),
              const SizedBox(height: 12),
              Text(
                strings.profileCredentialsAnonymousHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }

        return _CredentialsBody(user: user);
      },
    );
  }
}

class _CredentialsBody extends ConsumerStatefulWidget {
  const _CredentialsBody({required this.user});

  final AuthUser user;

  @override
  ConsumerState<_CredentialsBody> createState() => _CredentialsBodyState();
}

class _CredentialsBodyState extends ConsumerState<_CredentialsBody> {
  static const String _passwordMask = '••••••••';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Header(strings: strings),
        const SizedBox(height: 16),
        _CredentialsRow(
          label: strings.signInEmailLabel,
          value: widget.user.email ?? '-',
        ),
        const SizedBox(height: 12),
        _CredentialsRow(
          label: strings.signInPasswordLabel,
          value: _passwordMask,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => _showChangeEmailDialog(context),
          child: Text(strings.profileCredentialsChangeLoginCta),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _showChangePasswordDialog(context),
          child: Text(strings.profileCredentialsChangePasswordCta),
        ),
      ],
    );
  }

  Future<void> _showChangeEmailDialog(BuildContext context) async {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TextEditingController emailController = TextEditingController(
      text: widget.user.email ?? '',
    );
    final TextEditingController currentPasswordController =
        TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
                return AlertDialog(
                  title: Text(strings.profileCredentialsChangeLoginTitle),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: strings.profileCredentialsNewLoginLabel,
                          ),
                          validator: (String? value) {
                            final String text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return strings
                                  .profileCredentialsValidationRequired;
                            }
                            if (!text.contains('@')) {
                              return strings.authErrorInvalidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: currentPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText:
                                strings.profileCredentialsCurrentPasswordLabel,
                          ),
                          validator: (String? value) {
                            if ((value ?? '').isEmpty) {
                              return strings
                                  .profileCredentialsValidationRequired;
                            }
                            return null;
                          },
                        ),
                        if (errorText != null) ...<Widget>[
                          const SizedBox(height: 12),
                          Text(
                            errorText!,
                            style: Theme.of(dialogBodyContext)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    dialogBodyContext,
                                  ).colorScheme.error,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      child: Text(strings.cancelButtonLabel),
                    ),
                    FilledButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }
                              setState(() {
                                isSubmitting = true;
                                errorText = null;
                              });
                              try {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .updateEmail(
                                      newEmail: emailController.text.trim(),
                                      currentPassword:
                                          currentPasswordController.text,
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
                                        strings.profileCredentialsLoginUpdated,
                                      ),
                                    ),
                                  );
                              } on AuthFailure catch (failure) {
                                setState(() {
                                  errorText = AuthErrorMapper.map(
                                    failure.code,
                                    strings,
                                  );
                                  isSubmitting = false;
                                });
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(strings.saveButtonLabel),
                    ),
                  ],
                );
              },
        );
      },
    );

    emailController.dispose();
    currentPasswordController.dispose();
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
                return AlertDialog(
                  title: Text(strings.profileCredentialsChangePasswordTitle),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: currentPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText:
                                strings.profileCredentialsCurrentPasswordLabel,
                          ),
                          validator: (String? value) {
                            if ((value ?? '').isEmpty) {
                              return strings
                                  .profileCredentialsValidationRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText:
                                strings.profileCredentialsNewPasswordLabel,
                          ),
                          validator: (String? value) {
                            final String text = value ?? '';
                            if (text.isEmpty) {
                              return strings
                                  .profileCredentialsValidationRequired;
                            }
                            if (text.length < 6) {
                              return strings.authErrorWeakPassword;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText:
                                strings.profileCredentialsConfirmPasswordLabel,
                          ),
                          validator: (String? value) {
                            if ((value ?? '').isEmpty) {
                              return strings
                                  .profileCredentialsValidationRequired;
                            }
                            if (value != newPasswordController.text) {
                              return strings
                                  .profileCredentialsValidationPasswordMatch;
                            }
                            return null;
                          },
                        ),
                        if (errorText != null) ...<Widget>[
                          const SizedBox(height: 12),
                          Text(
                            errorText!,
                            style: Theme.of(dialogBodyContext)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    dialogBodyContext,
                                  ).colorScheme.error,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      child: Text(strings.cancelButtonLabel),
                    ),
                    FilledButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }
                              setState(() {
                                isSubmitting = true;
                                errorText = null;
                              });
                              try {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .updatePassword(
                                      currentPassword:
                                          currentPasswordController.text,
                                      newPassword: newPasswordController.text,
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
                                        strings
                                            .profileCredentialsPasswordUpdated,
                                      ),
                                    ),
                                  );
                              } on AuthFailure catch (failure) {
                                setState(() {
                                  errorText = AuthErrorMapper.map(
                                    failure.code,
                                    strings,
                                  );
                                  isSubmitting = false;
                                });
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(strings.saveButtonLabel),
                    ),
                  ],
                );
              },
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Icon(Icons.lock_outline, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            strings.profileCredentialsSectionTitle,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _CredentialsRow extends StatelessWidget {
  const _CredentialsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
