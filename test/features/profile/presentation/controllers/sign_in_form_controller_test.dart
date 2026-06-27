import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/core/di/injectors.dart';
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

class _TestCloudAuthRepository implements AuthRepository {
  String? lastResetEmail;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  Future<void> deleteCurrentUser() async {}

  @override
  Future<AuthUser> reauthenticate(SignInRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    lastResetEmail = email;
  }

  @override
  Future<AuthUser> signIn(SignInRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInAnonymously() {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInOffline() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser> signUp(SignUpRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> forceRefreshIdToken() async {}
}

void main() {
  group('SignInFormController', () {
    test('initial state is empty', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SignInFormState state = container.read(
        signInFormControllerProvider,
      );

      expect(state.email, isEmpty);
      expect(state.password, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('updates email and password and resets errors', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SignInFormController controller = container.read(
        signInFormControllerProvider.notifier,
      );

      controller.updateEmail('user@example.com');
      controller.updatePassword('secret123');

      final SignInFormState state = container.read(
        signInFormControllerProvider,
      );

      expect(state.email, 'user@example.com');
      expect(state.password, 'secret123');
      expect(state.canSubmit, isTrue);
    });

    test(
      'submit delegates to auth controller and clears error on success',
      () async {
        final _TestAuthController testAuthController = _TestAuthController();
        final ProviderContainer container = ProviderContainer(
          // ignore: always_specify_types
          overrides: [
            authControllerProvider.overrideWith(() => testAuthController),
          ],
        );
        addTearDown(container.dispose);

        final SignInFormController controller = container.read(
          signInFormControllerProvider.notifier,
        );

        controller.updateEmail('user@example.com');
        controller.updatePassword('secret123');

        await controller.submit();

        expect(
          testAuthController.lastRequest,
          const SignInRequest.email(
            email: 'user@example.com',
            password: 'secret123',
          ),
        );
        final SignInFormState state = container.read(
          signInFormControllerProvider,
        );
        expect(state.isSubmitting, isFalse);
        expect(state.errorMessage, isNull);
      },
    );

    test('submit surfaces auth failure message', () async {
      final _TestAuthController testAuthController = _TestAuthController();
      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(() => testAuthController),
        ],
      );
      addTearDown(container.dispose);

      final SignInFormController controller = container.read(
        signInFormControllerProvider.notifier,
      );

      controller.updateEmail('user@example.com');
      controller.updatePassword('secret123');

      testAuthController.failure = const AuthFailure(
        code: 'invalid',
        message: 'Invalid credentials',
      );

      await controller.submit();

      final SignInFormState state = container.read(
        signInFormControllerProvider,
      );
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, 'invalid');
    });

    test('resetPassword uses cloud auth repository directly', () async {
      final _TestCloudAuthRepository cloudAuthRepository =
          _TestCloudAuthRepository();
      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types
        overrides: [
          cloudAuthRepositoryProvider.overrideWithValue(cloudAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      final SignInFormController controller = container.read(
        signInFormControllerProvider.notifier,
      );

      controller.updateEmail('user@example.com');
      await controller.resetPassword();

      expect(cloudAuthRepository.lastResetEmail, 'user@example.com');
      final SignInFormState state = container.read(
        signInFormControllerProvider,
      );
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNull);
    });
  });
}
