// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignUpFormState {

 String get email; String get password; String get confirmPassword; String get displayName; bool get isSubmitting; String? get errorMessage;
/// Create a copy of SignUpFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpFormStateCopyWith<SignUpFormState> get copyWith => _$SignUpFormStateCopyWithImpl<SignUpFormState>(this as SignUpFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpFormState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,confirmPassword,displayName,isSubmitting,errorMessage);

@override
String toString() {
  return 'SignUpFormState(email: $email, password: $password, confirmPassword: $confirmPassword, displayName: $displayName, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $SignUpFormStateCopyWith<$Res>  {
  factory $SignUpFormStateCopyWith(SignUpFormState value, $Res Function(SignUpFormState) _then) = _$SignUpFormStateCopyWithImpl;
@useResult
$Res call({
 String email, String password, String confirmPassword, String displayName, bool isSubmitting, String? errorMessage
});




}
/// @nodoc
class _$SignUpFormStateCopyWithImpl<$Res>
    implements $SignUpFormStateCopyWith<$Res> {
  _$SignUpFormStateCopyWithImpl(this._self, this._then);

  final SignUpFormState _self;
  final $Res Function(SignUpFormState) _then;

/// Create a copy of SignUpFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? confirmPassword = null,Object? displayName = null,Object? isSubmitting = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SignUpFormState].
extension SignUpFormStatePatterns on SignUpFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignUpFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignUpFormState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignUpFormState value)  $default,){
final _that = this;
switch (_that) {
case _SignUpFormState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignUpFormState value)?  $default,){
final _that = this;
switch (_that) {
case _SignUpFormState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  String confirmPassword,  String displayName,  bool isSubmitting,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignUpFormState() when $default != null:
return $default(_that.email,_that.password,_that.confirmPassword,_that.displayName,_that.isSubmitting,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  String confirmPassword,  String displayName,  bool isSubmitting,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SignUpFormState():
return $default(_that.email,_that.password,_that.confirmPassword,_that.displayName,_that.isSubmitting,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  String confirmPassword,  String displayName,  bool isSubmitting,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SignUpFormState() when $default != null:
return $default(_that.email,_that.password,_that.confirmPassword,_that.displayName,_that.isSubmitting,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SignUpFormState extends SignUpFormState {
  const _SignUpFormState({this.email = '', this.password = '', this.confirmPassword = '', this.displayName = '', this.isSubmitting = false, this.errorMessage}): super._();
  

@override@JsonKey() final  String email;
@override@JsonKey() final  String password;
@override@JsonKey() final  String confirmPassword;
@override@JsonKey() final  String displayName;
@override@JsonKey() final  bool isSubmitting;
@override final  String? errorMessage;

/// Create a copy of SignUpFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignUpFormStateCopyWith<_SignUpFormState> get copyWith => __$SignUpFormStateCopyWithImpl<_SignUpFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpFormState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,confirmPassword,displayName,isSubmitting,errorMessage);

@override
String toString() {
  return 'SignUpFormState(email: $email, password: $password, confirmPassword: $confirmPassword, displayName: $displayName, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SignUpFormStateCopyWith<$Res> implements $SignUpFormStateCopyWith<$Res> {
  factory _$SignUpFormStateCopyWith(_SignUpFormState value, $Res Function(_SignUpFormState) _then) = __$SignUpFormStateCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String confirmPassword, String displayName, bool isSubmitting, String? errorMessage
});




}
/// @nodoc
class __$SignUpFormStateCopyWithImpl<$Res>
    implements _$SignUpFormStateCopyWith<$Res> {
  __$SignUpFormStateCopyWithImpl(this._self, this._then);

  final _SignUpFormState _self;
  final $Res Function(_SignUpFormState) _then;

/// Create a copy of SignUpFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? confirmPassword = null,Object? displayName = null,Object? isSubmitting = null,Object? errorMessage = freezed,}) {
  return _then(_SignUpFormState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
