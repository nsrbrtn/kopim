import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(appThemeProvider);
    final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: authState.when(
        loading: () => const _CenteredProgress(),
        error: (Object error, StackTrace? stackTrace) =>
            _ErrorView(message: error.toString()),
        data: (AuthUser? user) {
          if (user == null) {
            return const _ErrorView(
              message: 'Please sign in to manage your profile.',
            );
          }

          final AsyncValue<Profile?> profileAsync = ref.watch(
            profileControllerProvider(user.uid),
          );
          final Profile? profile = profileAsync.asData?.value;
          final ProfileFormParams params = ProfileFormParams(
            uid: user.uid,
            profile: profile,
          );
          final ProfileFormState formState = ref.watch(
            profileFormControllerProvider(params),
          );
          final ProfileFormController formController = ref.read(
            profileFormControllerProvider(params).notifier,
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
                      formState: formState,
                      formController: formController,
                      profileAsync: profileAsync,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProfileForm extends ConsumerWidget {
  const _ProfileForm({
    required this.theme,
    required this.formState,
    required this.formController,
    required this.profileAsync,
  });

  final ThemeData theme;
  final ProfileFormState formState;
  final ProfileFormController formController;
  final AsyncValue<Profile?> profileAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> locales = AppLocalizations.supportedLocales
        .map((Locale locale) => locale.toLanguageTag())
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionHeader(title: 'Account'),
        const SizedBox(height: 16),
        TextFormField(
          key: ValueKey<String>(
            'name-${formState.initialProfile?.updatedAt.millisecondsSinceEpoch ?? 0}',
          ),
          initialValue: formState.name,
          onChanged: formController.updateName,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ProfileCurrency>(
          initialValue: formState.currency,
          decoration: const InputDecoration(
            labelText: 'Currency',
            border: OutlineInputBorder(),
          ),
          items: ProfileCurrency.values
              .map(
                (ProfileCurrency currency) => DropdownMenuItem<ProfileCurrency>(
                  value: currency,
                  child: Text(currency.name.toUpperCase()),
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
          initialValue: formState.locale,
          decoration: const InputDecoration(
            labelText: 'Language',
            border: OutlineInputBorder(),
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
            'Failed to load profile: ${profileAsync.error}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (formState.errorMessage != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            formState.errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: !formState.isSaving && formState.hasChanges
                  ? () => formController.submit()
                  : null,
              icon: formState.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save Changes'),
            ),
            const SizedBox(width: 16),
            if (profileAsync.isLoading) const _CenteredProgress(size: 20),
          ],
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ThemeData>('theme', theme))
      ..add(DiagnosticsProperty<ProfileFormState>('formState', formState))
      ..add(
        DiagnosticsProperty<ProfileFormController>(
          'formController',
          formController,
        ),
      )
      ..add(
        DiagnosticsProperty<AsyncValue<Profile?>>('profileAsync', profileAsync),
      );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
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
