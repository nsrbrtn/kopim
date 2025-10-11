// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_in_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignInRequest {

 String get email; String get password;
/// Create a copy of SignInRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInRequestCopyWith<SignInRequest> get copyWith => _$SignInRequestCopyWithImpl<SignInRequest>(this as SignInRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'SignInRequest(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $SignInRequestCopyWith<$Res>  {
  factory $SignInRequestCopyWith(SignInRequest value, $Res Function(SignInRequest) _then) = _$SignInRequestCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$SignInRequestCopyWithImpl<$Res>
    implements $SignInRequestCopyWith<$Res> {
  _$SignInRequestCopyWithImpl(this._self, this._then);

  final SignInRequest _self;
  final $Res Function(SignInRequest) _then;

/// Create a copy of SignInRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SignInRequest].
extension SignInRequestPatterns on SignInRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EmailSignInRequest value)?  email,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EmailSignInRequest() when email != null:
return email(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EmailSignInRequest value)  email,}){
final _that = this;
switch (_that) {
case EmailSignInRequest():
return email(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EmailSignInRequest value)?  email,}){
final _that = this;
switch (_that) {
case EmailSignInRequest() when email != null:
return email(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String email,  String password)?  email,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EmailSignInRequest() when email != null:
return email(_that.email,_that.password);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String email,  String password)  email,}) {final _that = this;
switch (_that) {
case EmailSignInRequest():
return email(_that.email,_that.password);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String email,  String password)?  email,}) {final _that = this;
switch (_that) {
case EmailSignInRequest() when email != null:
return email(_that.email,_that.password);case _:
  return null;

}
}

}

/// @nodoc


class EmailSignInRequest implements SignInRequest {
  const EmailSignInRequest({required this.email, required this.password});
  

@override final  String email;
@override final  String password;

/// Create a copy of SignInRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailSignInRequestCopyWith<EmailSignInRequest> get copyWith => _$EmailSignInRequestCopyWithImpl<EmailSignInRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailSignInRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'SignInRequest.email(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $EmailSignInRequestCopyWith<$Res> implements $SignInRequestCopyWith<$Res> {
  factory $EmailSignInRequestCopyWith(EmailSignInRequest value, $Res Function(EmailSignInRequest) _then) = _$EmailSignInRequestCopyWithImpl;
@override @useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$EmailSignInRequestCopyWithImpl<$Res>
    implements $EmailSignInRequestCopyWith<$Res> {
  _$EmailSignInRequestCopyWithImpl(this._self, this._then);

  final EmailSignInRequest _self;
  final $Res Function(EmailSignInRequest) _then;

/// Create a copy of SignInRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(EmailSignInRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
