import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_request.freezed.dart';

@freezed
sealed class SignUpRequest with _$SignUpRequest {
  const factory SignUpRequest.email({
    required String email,
    required String password,
    String? displayName,
  }) = EmailSignUpRequest;
}
