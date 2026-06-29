import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/sign_in_form_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/sign_up_form_controller.dart';
import 'package:kopim/features/app_shell/presentation/widgets/main_navigation_shell.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_preflight_screen.dart';
import 'package:kopim/features/profile/presentation/utils/auth_error_mapper.dart';
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
  const SignInScreen({
    super.key,
    this.startInSignUpMode = false,
    this.resumeCloudActivation = false,
  });

  static const String routeName = '/sign-in';
  static String buildRouteLocation({
    bool startInSignUpMode = false,
    bool resumeCloudActivation = false,
  }) {
    final Uri uri = Uri(
      path: routeName,
      queryParameters: <String, String>{
        if (startInSignUpMode) 'signUp': 'true',
        if (resumeCloudActivation) 'resumeCloudActivation': 'true',
      },
    );
    return uri.toString();
  }

  final bool startInSignUpMode;
  final bool resumeCloudActivation;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late bool _isSignUpMode;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _licenseKeyController;
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
  bool _postAuthNavigationScheduled = false;
  bool _postAuthNavigationHandled = false;

  bool _canStartInSignUpMode() {
    return ref.read(appCapabilitiesProvider).canRegisterInApp;
  }

  @override
  void initState() {
    super.initState();
    _isSignUpMode = widget.startInSignUpMode && _canStartInSignUpMode();
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
    _licenseKeyController = TextEditingController(text: '');
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
            _schedulePostAuthNavigation();
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
            _schedulePostAuthNavigation();
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
    final bool nextMode = widget.startInSignUpMode && _canStartInSignUpMode();
    if (oldWidget.startInSignUpMode != widget.startInSignUpMode &&
        nextMode != _isSignUpMode) {
      setState(() {
        _isSignUpMode = nextMode;
      });
    }
  }

  @override
  void dispose() {
    _signInFormSubscription?.close();
    _signUpFormSubscription?.close();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseKeyController.dispose();
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
    final AsyncValue<DataModeState> dataModeAsync = ref.watch(
      dataModeControllerProvider,
    );
    final ThemeData theme = Theme.of(context);
    final AppCapabilities capabilities = ref.watch(appCapabilitiesProvider);
    final bool canRegisterInApp = capabilities.canRegisterInApp;
    final bool isSignUpMode = canRegisterInApp && _isSignUpMode;
    final bool isSubmitting = isSignUpMode
        ? signUpState.isSubmitting
        : formState.isSubmitting;
    final bool isBusy = formState.isSubmitting || signUpState.isSubmitting;
    final String? errorMessage = isSignUpMode
        ? signUpState.errorMessage
        : formState.errorMessage;

    final bool emailHasError =
        !isSignUpMode &&
        errorMessage != null &&
        (errorMessage == 'user-not-found' || errorMessage == 'invalid-email');

    final bool passwordHasError =
        !isSignUpMode &&
        errorMessage != null &&
        (errorMessage == 'wrong-password' ||
            errorMessage == 'invalid-credential');

    final String logoAsset = theme.brightness == Brightness.dark
        ? 'assets/icons/kopim_logo.png'
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

    final bool isDevEntitlementGate =
        capabilities.canActivatePromoOrLicenseInApp;
    final bool showOfflineAction = capabilities.allowsLocalOnlyUsage;
    final CloudEntitlementState? entitlementState = dataModeAsync.maybeWhen(
      data: (DataModeState value) => value.entitlementState,
      orElse: () => null,
    );
    final bool isEntitlementStateResolving =
        isDevEntitlementGate && dataModeAsync.isLoading;
    final bool showEntitlementGate =
        isDevEntitlementGate &&
        !isEntitlementStateResolving &&
        entitlementState != CloudEntitlementState.active;
    final bool isEntitlementLoading =
        showEntitlementGate && dataModeAsync.isLoading;
    final bool isEntitlementInvalid =
        entitlementState == CloudEntitlementState.invalid;

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
              Text(
                isEntitlementStateResolving
                    ? 'Проверяем облачный доступ'
                    : showEntitlementGate
                    ? 'Активируй облачный доступ'
                    : (isSignUpMode
                          ? strings.signUpTitle
                          : 'Войдите в аккаунт'),
                style: subHeaderStyle,
              ),
              const SizedBox(height: 16),
              if (!isEntitlementStateResolving &&
                  !showEntitlementGate) ...<Widget>[
                Text(
                  canRegisterInApp
                      ? 'Войдите в облачный аккаунт или создайте новый, чтобы продолжить.'
                      : 'Войдите в аккаунт с активным доступом, чтобы включить облачную синхронизацию. Или продолжайте локально без аккаунта.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (isEntitlementStateResolving)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (showEntitlementGate)
                _buildEntitlementGate(
                  theme: theme,
                  labelStyle: labelStyle,
                  isBusy: isBusy,
                  isEntitlementLoading: isEntitlementLoading,
                  isEntitlementInvalid: isEntitlementInvalid,
                )
              else
                _buildAuthSection(
                  context: context,
                  strings: strings,
                  theme: theme,
                  controller: controller,
                  signUpController: signUpController,
                  formState: formState,
                  signUpState: signUpState,
                  isOffline: isOffline,
                  isSubmitting: isSubmitting,
                  isBusy: isBusy,
                  errorMessage: errorMessage,
                  emailHasError: emailHasError,
                  passwordHasError: passwordHasError,
                  isSignUpMode: isSignUpMode,
                  labelStyle: labelStyle,
                  linkStyle: linkStyle,
                  dividerTextStyle: dividerTextStyle,
                  bottomActionStyle: bottomActionStyle,
                  showOfflineAction: showOfflineAction,
                  capabilities: capabilities,
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntitlementGate({
    required ThemeData theme,
    required TextStyle labelStyle,
    required bool isBusy,
    required bool isEntitlementLoading,
    required bool isEntitlementInvalid,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Для dev-сборки сначала активируй лицензионный ключ, а затем войди или создай облачный аккаунт.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel('Лицензионный ключ', labelStyle),
        const SizedBox(height: 10),
        KopimTextField(
          controller: _licenseKeyController,
          textInputAction: TextInputAction.done,
          enabled: !isBusy && !isEntitlementLoading,
          onSubmitted: (_) => _activateEntitlementKey(),
          placeholder: 'DEMO-CLOUD-KEY',
          hasError: isEntitlementInvalid,
        ),
        if (isEntitlementInvalid) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            'Ключ не принят. Проверь значение и попробуй снова.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: isBusy || isEntitlementLoading
                  ? null
                  : _activateEntitlementKey,
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
              child: isEntitlementLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Активировать ключ'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthSection({
    required BuildContext context,
    required AppLocalizations strings,
    required ThemeData theme,
    required SignInFormController controller,
    required SignUpFormController signUpController,
    required SignInFormState formState,
    required SignUpFormState signUpState,
    required AsyncValue<bool> isOffline,
    required bool isSubmitting,
    required bool isBusy,
    required String? errorMessage,
    required bool emailHasError,
    required bool passwordHasError,
    required bool isSignUpMode,
    required TextStyle labelStyle,
    required TextStyle linkStyle,
    required TextStyle dividerTextStyle,
    required TextStyle bottomActionStyle,
    required bool showOfflineAction,
    required AppCapabilities capabilities,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isSignUpMode) ...<Widget>[
          _buildLabel(strings.signInEmailLabel, labelStyle),
          const SizedBox(height: 10),
          KopimTextField(
            controller: _signUpEmailController,
            focusNode: _signUpEmailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !isSubmitting,
            onSubmitted: (_) => _signUpPasswordFocusNode.requestFocus(),
            placeholder: strings.signInEmailPlaceholder,
          ),
          const SizedBox(height: 16),
          _buildLabel(strings.signInPasswordLabel, labelStyle),
          const SizedBox(height: 10),
          KopimTextField(
            controller: _signUpPasswordController,
            focusNode: _signUpPasswordFocusNode,
            obscureText: true,
            showObscureToggle: true,
            textInputAction: TextInputAction.next,
            enabled: !isSubmitting,
            onSubmitted: (_) => _signUpConfirmPasswordFocusNode.requestFocus(),
            placeholder: '••••••••',
          ),
          const SizedBox(height: 16),
          _buildLabel(strings.signUpConfirmPasswordLabel, labelStyle),
          const SizedBox(height: 10),
          KopimTextField(
            controller: _signUpConfirmPasswordController,
            focusNode: _signUpConfirmPasswordFocusNode,
            obscureText: true,
            showObscureToggle: true,
            textInputAction: TextInputAction.next,
            enabled: !isSubmitting,
            onSubmitted: (_) => _signUpDisplayNameFocusNode.requestFocus(),
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
            placeholder: strings.signInDisplayNamePlaceholder,
          ),
        ] else ...<Widget>[
          _buildLabel(strings.signInEmailLabel, labelStyle),
          const SizedBox(height: 10),
          KopimTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !isSubmitting,
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
            placeholder: strings.signInEmailPlaceholder,
            hasError: emailHasError,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(strings.signInPasswordLabel, style: labelStyle),
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
                      SnackBar(
                        duration: const Duration(seconds: 3),
                        content: Text(strings.signInResetPasswordSuccess),
                      ),
                    );
                  }
                },
                child: Text(strings.signInForgotPasswordCta, style: linkStyle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          KopimTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: true,
            showObscureToggle: true,
            textInputAction: TextInputAction.done,
            enabled: !isSubmitting,
            onSubmitted: (_) => _onSubmit(controller),
            placeholder: '••••••••',
            hasError: passwordHasError,
          ),
        ],
        const SizedBox(height: 24),
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
        SizedBox(
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: isSignUpMode
                  ? (signUpState.canSubmit
                        ? () => _onSignUpSubmit(signUpController)
                        : null)
                  : (formState.canSubmit ? () => _onSubmit(controller) : null),
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
                  : Text(isSignUpMode ? 'Создать' : 'Войти'),
            ),
          ),
        ),
        if (capabilities.canRegisterInApp || showOfflineAction) ...<Widget>[
          const SizedBox(height: 24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (showOfflineAction)
                GestureDetector(
                  onTap: isBusy ? null : () => controller.continueOffline(),
                  child: Text('Продолжить офлайн', style: bottomActionStyle),
                )
              else
                const SizedBox.shrink(),
              if (capabilities.canRegisterInApp)
                GestureDetector(
                  onTap: isBusy
                      ? null
                      : () => _toggleMode(
                          controller: controller,
                          signUpController: signUpController,
                        ),
                  child: Text(
                    isSignUpMode ? 'Войти в аккаунт' : 'Создать аккаунт',
                    style: bottomActionStyle,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(String text, TextStyle style) {
    return Text(text, style: style);
  }

  Future<void> _onSubmit(SignInFormController controller) {
    _resetPostAuthNavigation();
    return controller.submit();
  }

  Future<void> _onSignUpSubmit(SignUpFormController controller) {
    _resetPostAuthNavigation();
    return controller.submit();
  }

  Future<void> _activateEntitlementKey() {
    final String key = _licenseKeyController.text.trim();
    return ref
        .read(dataModeControllerProvider.notifier)
        .activateEntitlementKey(key);
  }

  void _resetPostAuthNavigation() {
    _postAuthNavigationScheduled = false;
    _postAuthNavigationHandled = false;
  }

  void _schedulePostAuthNavigation() {
    if (_postAuthNavigationScheduled || _postAuthNavigationHandled) {
      return;
    }
    _postAuthNavigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postAuthNavigationScheduled = false;
      if (!mounted || _postAuthNavigationHandled) {
        return;
      }
      _postAuthNavigationHandled = true;
      final AppCapabilities capabilities = ref.read(appCapabilitiesProvider);
      final GoRouter? router = GoRouter.maybeOf(context);
      if (widget.resumeCloudActivation) {
        if (router != null) {
          router.go(
            CloudActivationPreflightScreen.buildRouteLocation(
              autoAdvance: true,
            ),
          );
          return;
        }
        _navigateAfterRegularSignIn();
        return;
      }
      if (capabilities.canRunCloudSync) {
        if (router != null) {
          router.go(
            CloudActivationPreflightScreen.buildRouteLocation(
              autoAdvance: true,
              fallbackToHome: true,
            ),
          );
          return;
        }
        _navigateAfterRegularSignIn();
        return;
      }
      _navigateAfterRegularSignIn();
    });
  }

  void _navigateAfterRegularSignIn() {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router != null) {
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(MainNavigationShell.routeName);
      }
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
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
      SnackBar(duration: const Duration(seconds: 3), content: Text(message)),
    );
  }
}
