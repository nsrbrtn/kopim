import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_up_form_controller.freezed.dart';
part 'sign_up_form_controller.g.dart';

@freezed
abstract class SignUpFormState with _$SignUpFormState {
  const factory SignUpFormState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default('') String displayName,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _SignUpFormState;

  const SignUpFormState._();

  bool get isEmailValid => email.trim().isNotEmpty;

  bool get isPasswordValid => password.length >= 6;

  bool get doPasswordsMatch =>
      password == confirmPassword && confirmPassword.isNotEmpty;

  bool get canSubmit =>
      !isSubmitting && isEmailValid && isPasswordValid && doPasswordsMatch;
}

@riverpod
class SignUpFormController extends _$SignUpFormController {
  @override
  SignUpFormState build() => const SignUpFormState();

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, errorMessage: null);
  }

  void updateDisplayName(String value) {
    state = state.copyWith(displayName: value, errorMessage: null);
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final String? trimmedDisplayName = state.displayName.trim().isEmpty
          ? null
          : state.displayName.trim();
      await ref
          .read(authControllerProvider.notifier)
          .signUp(
            SignUpRequest.email(
              email: state.email.trim(),
              password: state.password,
              displayName: trimmedDisplayName,
            ),
          );

      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false);
    } on AuthFailure catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: AuthFailure.unknown().message,
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
