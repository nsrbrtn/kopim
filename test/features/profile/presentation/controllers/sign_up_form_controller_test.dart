import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/sign_up_form_controller.dart';
import 'package:riverpod/riverpod.dart';

class _TestAuthController extends AuthController {
  _TestAuthController();

  SignUpRequest? lastRequest;
  AuthFailure? failure;

  @override
  Future<AuthUser?> build() async => null;

  @override
  Future<void> signUp(SignUpRequest request) async {
    lastRequest = request;
    if (failure != null) {
      throw failure!;
    }
  }
}

void main() {
  group('SignUpFormController', () {
    test('initial state is empty', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SignUpFormState state = container.read(
        signUpFormControllerProvider,
      );

      expect(state.email, isEmpty);
      expect(state.password, isEmpty);
      expect(state.confirmPassword, isEmpty);
      expect(state.displayName, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('updates fields and resets error', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SignUpFormController controller = container.read(
        signUpFormControllerProvider.notifier,
      );

      controller.updateEmail('user@example.com');
      controller.updatePassword('secret123');
      controller.updateConfirmPassword('secret123');
      controller.updateDisplayName('User');

      final SignUpFormState state = container.read(
        signUpFormControllerProvider,
      );

      expect(state.email, 'user@example.com');
      expect(state.password, 'secret123');
      expect(state.confirmPassword, 'secret123');
      expect(state.displayName, 'User');
      expect(state.canSubmit, isTrue);
    });

    test('submit delegates to auth controller', () async {
      final _TestAuthController testAuthController = _TestAuthController();
      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(() => testAuthController),
        ],
      );
      addTearDown(container.dispose);

      final SignUpFormController controller = container.read(
        signUpFormControllerProvider.notifier,
      );

      controller.updateEmail('user@example.com');
      controller.updatePassword('secret123');
      controller.updateConfirmPassword('secret123');
      controller.updateDisplayName('Test User');

      await controller.submit();

      expect(
        testAuthController.lastRequest,
        const SignUpRequest.email(
          email: 'user@example.com',
          password: 'secret123',
          displayName: 'Test User',
        ),
      );

      final SignUpFormState state = container.read(
        signUpFormControllerProvider,
      );
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

      final SignUpFormController controller = container.read(
        signUpFormControllerProvider.notifier,
      );

      controller.updateEmail('user@example.com');
      controller.updatePassword('secret123');
      controller.updateConfirmPassword('secret123');

      testAuthController.failure = const AuthFailure(
        code: 'invalid',
        message: 'Invalid password',
      );

      await controller.submit();

      final SignUpFormState state = container.read(
        signUpFormControllerProvider,
      );
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, 'Invalid password');
    });
  });
}
