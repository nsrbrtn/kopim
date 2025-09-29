import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

@freezed
abstract class AuthFailure with _$AuthFailure implements Exception {
  const AuthFailure._();

  const factory AuthFailure({required String code, required String message}) =
      _AuthFailure;

  factory AuthFailure.unknown([String? message]) => AuthFailure(
    code: 'unknown',
    message: message ?? 'Unknown authentication error occurred.',
  );
}
