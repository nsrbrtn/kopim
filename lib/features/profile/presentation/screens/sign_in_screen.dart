import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/presentation/controllers/sign_in_form_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/sign_up_form_controller.dart';
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
  const SignInScreen({super.key, this.startInSignUpMode = false});

  static const String routeName = '/sign-in';

  final bool startInSignUpMode;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late bool _isSignUpMode;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _signUpEmailController;
  late final TextEditingController _signUpPasswordController;
  late final TextEditingController _signUpConfirmPasswordController;
  late final TextEditingController _signUpDisplayNameController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _signUpEmailFocusNode;
  late final FocusNode _signUpPasswordFocusNode;
  late final FocusNode _signUpConfirmPasswordFocusNode;
  late final FocusNode _signUpDisplayNameFocusNode;
  ProviderSubscription<SignInFormState>? _signInFormSubscription;
  ProviderSubscription<SignUpFormState>? _signUpFormSubscription;

  @override
  void initState() {
    super.initState();
    _isSignUpMode = widget.startInSignUpMode;
    final SignInFormController controller = ref.read(
      signInFormControllerProvider.notifier,
    );
    final SignInFormState initialState = ref.read(signInFormControllerProvider);
    final SignUpFormController signUpController = ref.read(
      signUpFormControllerProvider.notifier,
    );
    final SignUpFormState signUpInitialState = ref.read(
      signUpFormControllerProvider,
    );
    _emailController = TextEditingController(text: initialState.email);
    _passwordController = TextEditingController(text: initialState.password);
    _signUpEmailController = TextEditingController(
      text: signUpInitialState.email,
    );
    _signUpPasswordController = TextEditingController(
      text: signUpInitialState.password,
    );
    _signUpConfirmPasswordController = TextEditingController(
      text: signUpInitialState.confirmPassword,
    );
    _signUpDisplayNameController = TextEditingController(
      text: signUpInitialState.displayName,
    );
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _signUpEmailFocusNode = FocusNode();
    _signUpPasswordFocusNode = FocusNode();
    _signUpConfirmPasswordFocusNode = FocusNode();
    _signUpDisplayNameFocusNode = FocusNode();

    _emailController.addListener(() {
      controller.updateEmail(_emailController.text);
    });
    _passwordController.addListener(() {
      controller.updatePassword(_passwordController.text);
    });
    _signUpEmailController.addListener(() {
      signUpController.updateEmail(_signUpEmailController.text);
    });
    _signUpPasswordController.addListener(() {
      signUpController.updatePassword(_signUpPasswordController.text);
    });
    _signUpConfirmPasswordController.addListener(() {
      signUpController.updateConfirmPassword(
        _signUpConfirmPasswordController.text,
      );
    });
    _signUpDisplayNameController.addListener(() {
      signUpController.updateDisplayName(_signUpDisplayNameController.text);
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
    _signUpFormSubscription = ref.listenManual<SignUpFormState>(
      signUpFormControllerProvider,
      (SignUpFormState? previous, SignUpFormState next) {
        if (previous?.isSubmitting == true && !next.isSubmitting) {
          if (!mounted) {
            return;
          }
          if (next.errorMessage == null) {
            _signUpPasswordController.clear();
            _signUpConfirmPasswordController.clear();
          }
        }
      },
    );
  }

  @override
  void didUpdateWidget(covariant SignInScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startInSignUpMode != widget.startInSignUpMode &&
        widget.startInSignUpMode != _isSignUpMode) {
      setState(() {
        _isSignUpMode = widget.startInSignUpMode;
      });
    }
  }

  @override
  void dispose() {
    _signInFormSubscription?.close();
    _signUpFormSubscription?.close();
    _emailController.dispose();
    _passwordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    _signUpDisplayNameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _signUpEmailFocusNode.dispose();
    _signUpPasswordFocusNode.dispose();
    _signUpConfirmPasswordFocusNode.dispose();
    _signUpDisplayNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final SignInFormState formState = ref.watch(signInFormControllerProvider);
    final SignUpFormState signUpState = ref.watch(signUpFormControllerProvider);
    final SignInFormController controller = ref.read(
      signInFormControllerProvider.notifier,
    );
    final SignUpFormController signUpController = ref.read(
      signUpFormControllerProvider.notifier,
    );
    final AsyncValue<bool> isOffline = ref.watch(_signInOfflineProvider);
    final ThemeData theme = Theme.of(context);
    final bool isSubmitting = _isSignUpMode
        ? signUpState.isSubmitting
        : formState.isSubmitting;
    final bool isBusy = formState.isSubmitting || signUpState.isSubmitting;
    final String? errorMessage = _isSignUpMode
        ? signUpState.errorMessage
        : formState.errorMessage;

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
                    _isSignUpMode ? strings.signUpTitle : strings.signInTitle,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUpMode
                        ? strings.signUpSubtitle
                        : strings.signInSubtitle,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_isSignUpMode) ...<Widget>[
                    TextFormField(
                      controller: _signUpEmailController,
                      focusNode: _signUpEmailFocusNode,
                      autofillHints: const <String>[AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: strings.signInEmailLabel,
                      ),
                      textInputAction: TextInputAction.next,
                      enabled: !isSubmitting,
                      onFieldSubmitted: (_) {
                        _signUpPasswordFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _signUpPasswordController,
                      focusNode: _signUpPasswordFocusNode,
                      obscureText: true,
                      autofillHints: const <String>[AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: strings.signInPasswordLabel,
                      ),
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        _signUpConfirmPasswordFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _signUpConfirmPasswordController,
                      focusNode: _signUpConfirmPasswordFocusNode,
                      obscureText: true,
                      autofillHints: const <String>[AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: strings.signUpConfirmPasswordLabel,
                      ),
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        _signUpDisplayNameFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _signUpDisplayNameController,
                      focusNode: _signUpDisplayNameFocusNode,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: strings.signUpDisplayNameLabel,
                      ),
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) =>
                          _onSignUpSubmit(signUpController),
                    ),
                    const SizedBox(height: 16),
                  ] else ...<Widget>[
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      autofillHints: const <String>[AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: strings.signInEmailLabel,
                      ),
                      textInputAction: TextInputAction.next,
                      enabled: !isSubmitting,
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
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onSubmit(controller),
                    ),
                    const SizedBox(height: 16),
                  ],
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
                  if (errorMessage != null) ...<Widget>[
                    Text(
                      errorMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: _isSignUpMode
                        ? (signUpState.canSubmit
                              ? () => _onSignUpSubmit(signUpController)
                              : null)
                        : (formState.canSubmit
                              ? () => _onSubmit(controller)
                              : null),
                    child: isSubmitting
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
                              Text(
                                _isSignUpMode
                                    ? strings.signUpLoading
                                    : strings.signInLoading,
                              ),
                            ],
                          )
                        : Text(
                            _isSignUpMode
                                ? strings.signUpSubmitCta
                                : strings.signInSubmitCta,
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: isBusy
                        ? null
                        : () => controller.continueOffline(),
                    icon: const Icon(Icons.wifi_off),
                    label: Text(strings.signInOfflineCta),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isBusy
                        ? null
                        : () => _toggleMode(
                            controller: controller,
                            signUpController: signUpController,
                          ),
                    child: Text(
                      _isSignUpMode
                          ? strings.signInAlreadyHaveAccountCta
                          : strings.signInNoAccountCta,
                    ),
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

  Future<void> _onSignUpSubmit(SignUpFormController controller) {
    return controller.submit();
  }

  void _toggleMode({
    required SignInFormController controller,
    required SignUpFormController signUpController,
  }) {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
    });
    controller.clearError();
    signUpController.clearError();
  }
}
