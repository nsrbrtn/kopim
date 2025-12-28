import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';

import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_form_controller.freezed.dart';
part 'sign_in_form_controller.g.dart';

@freezed
abstract class SignInFormState with _$SignInFormState {
  const factory SignInFormState({
    @Default('') String email,
    @Default('') String password,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _SignInFormState;

  const SignInFormState._();

  bool get isEmailValid => email.trim().isNotEmpty;

  bool get isPasswordValid => password.length >= 6;

  bool get canSubmit => !isSubmitting && isEmailValid && isPasswordValid;
}

@riverpod
class SignInFormController extends _$SignInFormController {
  @override
  SignInFormState build() => const SignInFormState();

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            SignInRequest.email(
              email: state.email.trim(),
              password: state.password,
            ),
          );

      if (!ref.mounted) return; // провайдер уже уничтожен
      state = state.copyWith(isSubmitting: false);
    } on AuthFailure catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false, errorMessage: error.code);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: AuthFailure.unknown().code,
      );
    }
  }

  Future<void> continueOffline() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await ref.read(authControllerProvider.notifier).continueWithOfflineMode();

      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false);
    } on AuthFailure catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false, errorMessage: error.code);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: AuthFailure.unknown().code,
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  Future<void> resetPassword() async {
    if (!state.isEmailValid) {
      state = state.copyWith(
        errorMessage: 'Введите корректный email для сброса пароля.',
      );
      return;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(state.email.trim());

      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false);
    } on AuthFailure catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false, errorMessage: error.code);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: AuthFailure.unknown().code,
      );
    }
  }
}
