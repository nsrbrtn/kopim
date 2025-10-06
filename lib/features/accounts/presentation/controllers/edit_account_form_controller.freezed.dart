// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_account_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditAccountFormState {

 AccountEntity get original; String get name; String get balanceInput; String get currency; String get type; bool get useCustomType; String get customType; bool get isSaving; bool get submissionSuccess; EditAccountFieldError? get nameError; EditAccountFieldError? get balanceError; EditAccountFieldError? get typeError; String? get errorMessage;
/// Create a copy of EditAccountFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditAccountFormStateCopyWith<EditAccountFormState> get copyWith => _$EditAccountFormStateCopyWithImpl<EditAccountFormState>(this as EditAccountFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditAccountFormState&&(identical(other.original, original) || other.original == original)&&(identical(other.name, name) || other.name == name)&&(identical(other.balanceInput, balanceInput) || other.balanceInput == balanceInput)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.type, type) || other.type == type)&&(identical(other.useCustomType, useCustomType) || other.useCustomType == useCustomType)&&(identical(other.customType, customType) || other.customType == customType)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.submissionSuccess, submissionSuccess) || other.submissionSuccess == submissionSuccess)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.balanceError, balanceError) || other.balanceError == balanceError)&&(identical(other.typeError, typeError) || other.typeError == typeError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,original,name,balanceInput,currency,type,useCustomType,customType,isSaving,submissionSuccess,nameError,balanceError,typeError,errorMessage);

@override
String toString() {
  return 'EditAccountFormState(original: $original, name: $name, balanceInput: $balanceInput, currency: $currency, type: $type, useCustomType: $useCustomType, customType: $customType, isSaving: $isSaving, submissionSuccess: $submissionSuccess, nameError: $nameError, balanceError: $balanceError, typeError: $typeError, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $EditAccountFormStateCopyWith<$Res>  {
  factory $EditAccountFormStateCopyWith(EditAccountFormState value, $Res Function(EditAccountFormState) _then) = _$EditAccountFormStateCopyWithImpl;
@useResult
$Res call({
 AccountEntity original, String name, String balanceInput, String currency, String type, bool useCustomType, String customType, bool isSaving, bool submissionSuccess, EditAccountFieldError? nameError, EditAccountFieldError? balanceError, EditAccountFieldError? typeError, String? errorMessage
});


$AccountEntityCopyWith<$Res> get original;

}
/// @nodoc
class _$EditAccountFormStateCopyWithImpl<$Res>
    implements $EditAccountFormStateCopyWith<$Res> {
  _$EditAccountFormStateCopyWithImpl(this._self, this._then);

  final EditAccountFormState _self;
  final $Res Function(EditAccountFormState) _then;

/// Create a copy of EditAccountFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? original = null,Object? name = null,Object? balanceInput = null,Object? currency = null,Object? type = null,Object? useCustomType = null,Object? customType = null,Object? isSaving = null,Object? submissionSuccess = null,Object? nameError = freezed,Object? balanceError = freezed,Object? typeError = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
original: null == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as AccountEntity,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balanceInput: null == balanceInput ? _self.balanceInput : balanceInput // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,useCustomType: null == useCustomType ? _self.useCustomType : useCustomType // ignore: cast_nullable_to_non_nullable
as bool,customType: null == customType ? _self.customType : customType // ignore: cast_nullable_to_non_nullable
as String,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,submissionSuccess: null == submissionSuccess ? _self.submissionSuccess : submissionSuccess // ignore: cast_nullable_to_non_nullable
as bool,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as EditAccountFieldError?,balanceError: freezed == balanceError ? _self.balanceError : balanceError // ignore: cast_nullable_to_non_nullable
as EditAccountFieldError?,typeError: freezed == typeError ? _self.typeError : typeError // ignore: cast_nullable_to_non_nullable
as EditAccountFieldError?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EditAccountFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountEntityCopyWith<$Res> get original {
  
  return $AccountEntityCopyWith<$Res>(_self.original, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditAccountFormState].
extension EditAccountFormStatePatterns on EditAccountFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditAccountFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditAccountFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditAccountFormState value)  $default,){
final _that = this;
switch (_that) {
case _EditAccountFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditAccountFormState value)?  $default,){
final _that = this;
switch (_that) {
case _EditAccountFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccountEntity original,  String name,  String balanceInput,  String currency,  String type,  bool useCustomType,  String customType,  bool isSaving,  bool submissionSuccess,  EditAccountFieldError? nameError,  EditAccountFieldError? balanceError,  EditAccountFieldError? typeError,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditAccountFormState() when $default != null:
return $default(_that.original,_that.name,_that.balanceInput,_that.currency,_that.type,_that.useCustomType,_that.customType,_that.isSaving,_that.submissionSuccess,_that.nameError,_that.balanceError,_that.typeError,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccountEntity original,  String name,  String balanceInput,  String currency,  String type,  bool useCustomType,  String customType,  bool isSaving,  bool submissionSuccess,  EditAccountFieldError? nameError,  EditAccountFieldError? balanceError,  EditAccountFieldError? typeError,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _EditAccountFormState():
return $default(_that.original,_that.name,_that.balanceInput,_that.currency,_that.type,_that.useCustomType,_that.customType,_that.isSaving,_that.submissionSuccess,_that.nameError,_that.balanceError,_that.typeError,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccountEntity original,  String name,  String balanceInput,  String currency,  String type,  bool useCustomType,  String customType,  bool isSaving,  bool submissionSuccess,  EditAccountFieldError? nameError,  EditAccountFieldError? balanceError,  EditAccountFieldError? typeError,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _EditAccountFormState() when $default != null:
return $default(_that.original,_that.name,_that.balanceInput,_that.currency,_that.type,_that.useCustomType,_that.customType,_that.isSaving,_that.submissionSuccess,_that.nameError,_that.balanceError,_that.typeError,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _EditAccountFormState extends EditAccountFormState {
  const _EditAccountFormState({required this.original, required this.name, required this.balanceInput, required this.currency, required this.type, this.useCustomType = false, this.customType = '', this.isSaving = false, this.submissionSuccess = false, this.nameError, this.balanceError, this.typeError, this.errorMessage}): super._();
  

@override final  AccountEntity original;
@override final  String name;
@override final  String balanceInput;
@override final  String currency;
@override final  String type;
@override@JsonKey() final  bool useCustomType;
@override@JsonKey() final  String customType;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool submissionSuccess;
@override final  EditAccountFieldError? nameError;
@override final  EditAccountFieldError? balanceError;
@override final  EditAccountFieldError? typeError;
@override final  String? errorMessage;

/// Create a copy of EditAccountFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditAccountFormStateCopyWith<_EditAccountFormState> get copyWith => __$EditAccountFormStateCopyWithImpl<_EditAccountFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditAccountFormState&&(identical(other.original, original) || other.original == original)&&(identical(other.name, name) || other.name == name)&&(identical(other.balanceInput, balanceInput) || other.balanceInput == balanceInput)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.type, type) || other.type == type)&&(identical(other.useCustomType, useCustomType) || other.useCustomType == useCustomType)&&(identical(other.customType, customType) || other.customType == customType)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.submissionSuccess, submissionSuccess) || other.submissionSuccess == submissionSuccess)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.balanceError, balanceError) || other.balanceError == balanceError)&&(identical(other.typeError, typeError) || other.typeError == typeError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,original,name,balanceInput,currency,type,useCustomType,customType,isSaving,submissionSuccess,nameError,balanceError,typeError,errorMessage);

@override
String toString() {
  return 'EditAccountFormState(original: $original, name: $name, balanceInput: $balanceInput, currency: $currency, type: $type, useCustomType: $useCustomType, customType: $customType, isSaving: $isSaving, submissionSuccess: $submissionSuccess, nameError: $nameError, balanceError: $balanceError, typeError: $typeError, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$EditAccountFormStateCopyWith<$Res> implements $EditAccountFormStateCopyWith<$Res> {
  factory _$EditAccountFormStateCopyWith(_EditAccountFormState value, $Res Function(_EditAccountFormState) _then) = __$EditAccountFormStateCopyWithImpl;
@override @useResult
$Res call({
 AccountEntity original, String name, String balanceInput, String currency, String type, bool useCustomType, String customType, bool isSaving, bool submissionSuccess, EditAccountFieldError? nameError, EditAccountFieldError? balanceError, EditAccountFieldError? typeError, String? errorMessage
});


@override $AccountEntityCopyWith<$Res> get original;

}
/// @nodoc
class __$EditAccountFormStateCopyWithImpl<$Res>
    implements _$EditAccountFormStateCopyWith<$Res> {
  __$EditAccountFormStateCopyWithImpl(this._self, this._then);

  final _EditAccountFormState _self;
  final $Res Function(_EditAccountFormState) _then;

/// Create a copy of EditAccountFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? original = null,Object? name = null,Object? balanceInput = null,Object? currency = null,Object? type = null,Object? useCustomType = null,Object? customType = null,Object? isSaving = null,Object? submissionSuccess = null,Object? nameError = freezed,Object? balanceError = freezed,Object? typeError = freezed,Object? errorMessage = freezed,}) {
  return _then(_EditAccountFormState(
original: null == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as AccountEntity,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balanceInput: null == balanceInput ? _self.balanceInput : balanceInput // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,useCustomType: null == useCustomType ? _self.useCustomType : useCustomType // ignore: cast_nullable_to_non_nullable
as bool,customType: null == customType ? _self.customType : customType // ignore: cast_nullable_to_non_nullable
as String,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,submissionSuccess: null == submissionSuccess ? _self.submissionSuccess : submissionSuccess // ignore: cast_nullable_to_non_nullable
as bool,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as EditAccountFieldError?,balanceError: freezed == balanceError ? _self.balanceError : balanceError // ignore: cast_nullable_to_non_nullable
as EditAccountFieldError?,typeError: freezed == typeError ? _self.typeError : typeError // ignore: cast_nullable_to_non_nullable
as EditAccountFieldError?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EditAccountFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountEntityCopyWith<$Res> get original {
  
  return $AccountEntityCopyWith<$Res>(_self.original, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
