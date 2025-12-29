import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/profile/presentation/controllers/sign_in_form_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/sign_up_form_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/features/profile/presentation/utils/auth_error_mapper.dart';

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
        if (!mounted) {
          return;
        }
        final String? previousError = previous?.errorMessage;
        final String? nextError = next.errorMessage;
        if (nextError != null && nextError != previousError) {
          final AppLocalizations strings = AppLocalizations.of(context)!;
          _showErrorSnackBar(AuthErrorMapper.map(nextError, strings));
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
        if (!mounted) {
          return;
        }
        final String? previousError = previous?.errorMessage;
        final String? nextError = next.errorMessage;
        if (nextError != null && nextError != previousError) {
          final AppLocalizations strings = AppLocalizations.of(context)!;
          _showErrorSnackBar(AuthErrorMapper.map(nextError, strings));
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

    // Determine field-specific errors for visual feedback
    final bool emailHasError =
        !_isSignUpMode &&
        errorMessage != null &&
        (errorMessage == 'user-not-found' || errorMessage == 'invalid-email');

    final bool passwordHasError =
        !_isSignUpMode &&
        errorMessage != null &&
        (errorMessage == 'wrong-password' || errorMessage == 'invalid-credential');

    final String logoAsset = theme.brightness == Brightness.dark
        ? 'assets/icons/logo_dark.png'
        : 'assets/icons/logo_light.png';

    final TextStyle subHeaderStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      fontSize: 22,
      height: 28 / 22,
      color: theme.colorScheme.onSurface,
    );

    final TextStyle labelStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.5,
      color: theme.colorScheme.onSurface,
    );

    final TextStyle linkStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.5,
      color: theme.colorScheme.primary,
    );

    final TextStyle dividerTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.5,
      color: theme.colorScheme.onSurfaceVariant,
    );

    final TextStyle bottomActionStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.4,
      color: theme.colorScheme.primary,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      logoAsset,
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Subheader
              Text(
                _isSignUpMode ? strings.signUpTitle : 'Войди для синхронизации',
                style: subHeaderStyle,
              ),
              const SizedBox(height: 16),

              // Form
              if (_isSignUpMode) ...<Widget>[
                _buildLabel(strings.signInEmailLabel, labelStyle),
                const SizedBox(height: 10),
                KopimTextField(
                  controller: _signUpEmailController,
                  focusNode: _signUpEmailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isSubmitting,
                  onSubmitted: (_) => _signUpPasswordFocusNode.requestFocus(),
                  placeholder: 'name@example.com',
                ),
                const SizedBox(height: 16),

                _buildLabel(strings.signInPasswordLabel, labelStyle),
                const SizedBox(height: 10),
                KopimTextField(
                  controller: _signUpPasswordController,
                  focusNode: _signUpPasswordFocusNode,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  enabled: !isSubmitting,
                  onSubmitted: (_) =>
                      _signUpConfirmPasswordFocusNode.requestFocus(),
                  placeholder: '••••••••',
                ),
                const SizedBox(height: 16),

                _buildLabel(strings.signUpConfirmPasswordLabel, labelStyle),
                const SizedBox(height: 10),
                KopimTextField(
                  controller: _signUpConfirmPasswordController,
                  focusNode: _signUpConfirmPasswordFocusNode,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  enabled: !isSubmitting,
                  onSubmitted: (_) =>
                      _signUpDisplayNameFocusNode.requestFocus(),
                  placeholder: '••••••••',
                ),
                const SizedBox(height: 16),

                _buildLabel(strings.signUpDisplayNameLabel, labelStyle),
                const SizedBox(height: 10),
                KopimTextField(
                  controller: _signUpDisplayNameController,
                  focusNode: _signUpDisplayNameFocusNode,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  enabled: !isSubmitting,
                  onSubmitted: (_) => _onSignUpSubmit(signUpController),
                  placeholder: 'Иван Иванов',
                ),
              ] else ...<Widget>[
                // Email
                _buildLabel('Введите вашу почту', labelStyle),
                const SizedBox(height: 10),
                KopimTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isSubmitting,
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  placeholder: 'name@example.com',
                  hasError: emailHasError,
                ),
                const SizedBox(height: 16),

                // Password Label Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Введите ваш пароль', style: labelStyle),
                    GestureDetector(
                      onTap: () async {
                        await controller.resetPassword();
                        if (!context.mounted) {
                          return;
                        }
                        final SignInFormState latestState = ref.read(
                          signInFormControllerProvider,
                        );
                        if (latestState.errorMessage == null &&
                            !latestState.isSubmitting) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Письмо для сброса пароля отправлено на вашу почту',
                              ),
                            ),
                          );
                        }
                      },
                      child: Text('Забыли пароль?', style: linkStyle),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                KopimTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  enabled: !isSubmitting,
                  onSubmitted: (_) => _onSubmit(controller),
                  placeholder: '••••••••',
                  hasError: passwordHasError,
                ),
              ],

              const SizedBox(height: 24),

              // Error Message
              if (errorMessage != null) ...<Widget>[
                Text(
                  AuthErrorMapper.map(errorMessage, strings),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],

              // Offline Notice
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

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _isSignUpMode
                        ? (signUpState.canSubmit
                              ? () => _onSignUpSubmit(signUpController)
                              : null)
                        : (formState.canSubmit
                              ? () => _onSubmit(controller)
                              : null),
                    style: FilledButton.styleFrom(
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0.15,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isSignUpMode ? 'Создать' : 'Войти'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outlineVariant,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('или', style: dividerTextStyle),
                  ),
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outlineVariant,
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: isBusy ? null : () => controller.continueOffline(),
                    child: Text('Продолжить офлайн', style: bottomActionStyle),
                  ),
                  GestureDetector(
                    onTap: isBusy
                        ? null
                        : () => _toggleMode(
                            controller: controller,
                            signUpController: signUpController,
                          ),
                    child: Text(
                      _isSignUpMode ? 'Войти в аккаунт' : 'Создать аккаунт',
                      style: bottomActionStyle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, TextStyle style) {
    return Text(text, style: style);
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
