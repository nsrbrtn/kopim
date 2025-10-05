import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/presentation/controllers/sign_in_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

bool _isOffline(List<ConnectivityResult> results) {
  if (results.isEmpty) {
    return true;
  }
  return results.every(
    (ConnectivityResult result) => result == ConnectivityResult.none,
  );
}

final StreamProvider<bool> _signInOfflineProvider =
    StreamProvider.autoDispose<bool>((Ref ref) async* {
      final Connectivity connectivity = ref.watch(connectivityProvider);
      final List<ConnectivityResult> initial = await connectivity
          .checkConnectivity();
      yield _isOffline(initial);

      yield* connectivity.onConnectivityChanged.map(_isOffline);
    });

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  ProviderSubscription<SignInFormState>? _signInFormSubscription;

  @override
  void initState() {
    super.initState();
    final SignInFormController controller = ref.read(
      signInFormControllerProvider.notifier,
    );
    final SignInFormState initialState = ref.read(signInFormControllerProvider);
    _emailController = TextEditingController(text: initialState.email);
    _passwordController = TextEditingController(text: initialState.password);
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _emailController.addListener(() {
      controller.updateEmail(_emailController.text);
    });
    _passwordController.addListener(() {
      controller.updatePassword(_passwordController.text);
    });

    _signInFormSubscription = ref.listenManual<SignInFormState>(
      signInFormControllerProvider,
      (SignInFormState? previous, SignInFormState next) {
        if (previous?.isSubmitting == true && !next.isSubmitting) {
          if (!mounted) {
            return;
          }
          if (next.errorMessage == null) {
            _passwordController.clear();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _signInFormSubscription?.close();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final SignInFormState formState = ref.watch(signInFormControllerProvider);
    final SignInFormController controller = ref.read(
      signInFormControllerProvider.notifier,
    );
    final AsyncValue<bool> isOffline = ref.watch(_signInOfflineProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    strings.signInTitle,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.signInSubtitle,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    autofillHints: const <String>[AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: strings.signInEmailLabel,
                    ),
                    textInputAction: TextInputAction.next,
                    enabled: !formState.isSubmitting,
                    onFieldSubmitted: (_) {
                      _passwordFocusNode.requestFocus();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: true,
                    autofillHints: const <String>[AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: strings.signInPasswordLabel,
                    ),
                    enabled: !formState.isSubmitting,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onSubmit(controller),
                  ),
                  const SizedBox(height: 16),
                  isOffline.when(
                    data: (bool offline) => offline
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              strings.signInOfflineNotice,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (Object error, StackTrace stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                  if (formState.errorMessage != null) ...<Widget>[
                    Text(
                      formState.errorMessage ?? strings.signInError,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: formState.canSubmit
                        ? () => _onSubmit(controller)
                        : null,
                    child: formState.isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(strings.signInLoading),
                            ],
                          )
                        : Text(strings.signInSubmitCta),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: formState.isSubmitting
                        ? null
                        : () => controller.signInWithGoogle(),
                    icon: const Icon(Icons.login),
                    label: Text(strings.signInGoogleCta),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: formState.isSubmitting
                        ? null
                        : () => controller.continueOffline(),
                    icon: const Icon(Icons.wifi_off),
                    label: Text(strings.signInOfflineCta),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(SignInFormController controller) {
    return controller.submit();
  }
}
