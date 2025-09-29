import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/sign_in_form_controller.dart';
import 'package:riverpod/riverpod.dart';

class _TestAuthController extends AuthController {
  _TestAuthController();

  SignInRequest? lastRequest;
  AuthFailure? failure;

  @override
  Future<AuthUser?> build() async => null;

  @override
  Future<void> signIn(SignInRequest request) async {
    lastRequest = request;
    if (failure != null) {
      throw failure!;
    }
  }
}

void main() {
  group('SignInFormController', () {
    test('initial state is empty', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SignInFormState state =
          container.read(signInFormControllerProvider);

      expect(state.email, isEmpty);
      expect(state.password, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('updates email and password and resets errors', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SignInFormController controller =
          container.read(signInFormControllerProvider.notifier);

      controller.updateEmail('user@example.com');
      controller.updatePassword('secret123');

      final SignInFormState state =
          container.read(signInFormControllerProvider);

      expect(state.email, 'user@example.com');
      expect(state.password, 'secret123');
      expect(state.canSubmit, isTrue);
    });

    test('submit delegates to auth controller and clears error on success', () async {
      final _TestAuthController testAuthController = _TestAuthController();
      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(() => testAuthController),
        ],
      );
      addTearDown(container.dispose);

      final SignInFormController controller =
          container.read(signInFormControllerProvider.notifier);

      controller.updateEmail('user@example.com');
      controller.updatePassword('secret123');

      await controller.submit();

      expect(
        testAuthController.lastRequest,
        const SignInRequest.email(email: 'user@example.com', password: 'secret123'),
      );
      final SignInFormState state =
          container.read(signInFormControllerProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('submit surfaces auth failure message', () async {
      final _TestAuthController testAuthController = _TestAuthController();
      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(() => testAuthController),
        ],
      );
      addTearDown(container.dispose);

      final SignInFormController controller =
          container.read(signInFormControllerProvider.notifier);

      controller.updateEmail('user@example.com');
      controller.updatePassword('secret123');

      testAuthController.failure =
          const AuthFailure(code: 'invalid', message: 'Invalid credentials');

      await controller.submit();

      final SignInFormState state =
          container.read(signInFormControllerProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, 'Invalid credentials');
    });

    test('signInWithGoogle delegates to auth controller', () async {
      final _TestAuthController testAuthController = _TestAuthController();
      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(() => testAuthController),
        ],
      );
      addTearDown(container.dispose);

      final SignInFormController controller =
          container.read(signInFormControllerProvider.notifier);

      await controller.signInWithGoogle();

      expect(testAuthController.lastRequest, const SignInRequest.google());
      final SignInFormState state =
          container.read(signInFormControllerProvider);
      expect(state.isSubmitting, isFalse);
    });
  });
}
