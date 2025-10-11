import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_request.freezed.dart';

@freezed
sealed class SignInRequest with _$SignInRequest {
  const factory SignInRequest.email({
    required String email,
    required String password,
  }) = EmailSignInRequest;
}
