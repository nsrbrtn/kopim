// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_account_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddAccountFormState {

 String get name; String get balanceInput; String get currency; String get type; bool get useCustomType; String get customType; bool get isSaving; bool get submissionSuccess; bool get isPrimary; AddAccountFieldError? get nameError; AddAccountFieldError? get balanceError; AddAccountFieldError? get typeError; String? get errorMessage; String? get color; String? get gradientId; String? get iconName; String? get iconStyle;
/// Create a copy of AddAccountFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddAccountFormStateCopyWith<AddAccountFormState> get copyWith => _$AddAccountFormStateCopyWithImpl<AddAccountFormState>(this as AddAccountFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddAccountFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.balanceInput, balanceInput) || other.balanceInput == balanceInput)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.type, type) || other.type == type)&&(identical(other.useCustomType, useCustomType) || other.useCustomType == useCustomType)&&(identical(other.customType, customType) || other.customType == customType)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.submissionSuccess, submissionSuccess) || other.submissionSuccess == submissionSuccess)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.balanceError, balanceError) || other.balanceError == balanceError)&&(identical(other.typeError, typeError) || other.typeError == typeError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.color, color) || other.color == color)&&(identical(other.gradientId, gradientId) || other.gradientId == gradientId)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.iconStyle, iconStyle) || other.iconStyle == iconStyle));
}


@override
int get hashCode => Object.hash(runtimeType,name,balanceInput,currency,type,useCustomType,customType,isSaving,submissionSuccess,isPrimary,nameError,balanceError,typeError,errorMessage,color,gradientId,iconName,iconStyle);

@override
String toString() {
  return 'AddAccountFormState(name: $name, balanceInput: $balanceInput, currency: $currency, type: $type, useCustomType: $useCustomType, customType: $customType, isSaving: $isSaving, submissionSuccess: $submissionSuccess, isPrimary: $isPrimary, nameError: $nameError, balanceError: $balanceError, typeError: $typeError, errorMessage: $errorMessage, color: $color, gradientId: $gradientId, iconName: $iconName, iconStyle: $iconStyle)';
}


}

/// @nodoc
abstract mixin class $AddAccountFormStateCopyWith<$Res>  {
  factory $AddAccountFormStateCopyWith(AddAccountFormState value, $Res Function(AddAccountFormState) _then) = _$AddAccountFormStateCopyWithImpl;
@useResult
$Res call({
 String name, String balanceInput, String currency, String type, bool useCustomType, String customType, bool isSaving, bool submissionSuccess, bool isPrimary, AddAccountFieldError? nameError, AddAccountFieldError? balanceError, AddAccountFieldError? typeError, String? errorMessage, String? color, String? gradientId, String? iconName, String? iconStyle
});




}
/// @nodoc
class _$AddAccountFormStateCopyWithImpl<$Res>
    implements $AddAccountFormStateCopyWith<$Res> {
  _$AddAccountFormStateCopyWithImpl(this._self, this._then);

  final AddAccountFormState _self;
  final $Res Function(AddAccountFormState) _then;

/// Create a copy of AddAccountFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? balanceInput = null,Object? currency = null,Object? type = null,Object? useCustomType = null,Object? customType = null,Object? isSaving = null,Object? submissionSuccess = null,Object? isPrimary = null,Object? nameError = freezed,Object? balanceError = freezed,Object? typeError = freezed,Object? errorMessage = freezed,Object? color = freezed,Object? gradientId = freezed,Object? iconName = freezed,Object? iconStyle = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balanceInput: null == balanceInput ? _self.balanceInput : balanceInput // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,useCustomType: null == useCustomType ? _self.useCustomType : useCustomType // ignore: cast_nullable_to_non_nullable
as bool,customType: null == customType ? _self.customType : customType // ignore: cast_nullable_to_non_nullable
as String,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,submissionSuccess: null == submissionSuccess ? _self.submissionSuccess : submissionSuccess // ignore: cast_nullable_to_non_nullable
as bool,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as AddAccountFieldError?,balanceError: freezed == balanceError ? _self.balanceError : balanceError // ignore: cast_nullable_to_non_nullable
as AddAccountFieldError?,typeError: freezed == typeError ? _self.typeError : typeError // ignore: cast_nullable_to_non_nullable
as AddAccountFieldError?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,gradientId: freezed == gradientId ? _self.gradientId : gradientId // ignore: cast_nullable_to_non_nullable
as String?,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,iconStyle: freezed == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddAccountFormState].
extension AddAccountFormStatePatterns on AddAccountFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddAccountFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddAccountFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddAccountFormState value)  $default,){
final _that = this;
switch (_that) {
case _AddAccountFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddAccountFormState value)?  $default,){
final _that = this;
switch (_that) {
case _AddAccountFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String balanceInput,  String currency,  String type,  bool useCustomType,  String customType,  bool isSaving,  bool submissionSuccess,  bool isPrimary,  AddAccountFieldError? nameError,  AddAccountFieldError? balanceError,  AddAccountFieldError? typeError,  String? errorMessage,  String? color,  String? gradientId,  String? iconName,  String? iconStyle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddAccountFormState() when $default != null:
return $default(_that.name,_that.balanceInput,_that.currency,_that.type,_that.useCustomType,_that.customType,_that.isSaving,_that.submissionSuccess,_that.isPrimary,_that.nameError,_that.balanceError,_that.typeError,_that.errorMessage,_that.color,_that.gradientId,_that.iconName,_that.iconStyle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String balanceInput,  String currency,  String type,  bool useCustomType,  String customType,  bool isSaving,  bool submissionSuccess,  bool isPrimary,  AddAccountFieldError? nameError,  AddAccountFieldError? balanceError,  AddAccountFieldError? typeError,  String? errorMessage,  String? color,  String? gradientId,  String? iconName,  String? iconStyle)  $default,) {final _that = this;
switch (_that) {
case _AddAccountFormState():
return $default(_that.name,_that.balanceInput,_that.currency,_that.type,_that.useCustomType,_that.customType,_that.isSaving,_that.submissionSuccess,_that.isPrimary,_that.nameError,_that.balanceError,_that.typeError,_that.errorMessage,_that.color,_that.gradientId,_that.iconName,_that.iconStyle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String balanceInput,  String currency,  String type,  bool useCustomType,  String customType,  bool isSaving,  bool submissionSuccess,  bool isPrimary,  AddAccountFieldError? nameError,  AddAccountFieldError? balanceError,  AddAccountFieldError? typeError,  String? errorMessage,  String? color,  String? gradientId,  String? iconName,  String? iconStyle)?  $default,) {final _that = this;
switch (_that) {
case _AddAccountFormState() when $default != null:
return $default(_that.name,_that.balanceInput,_that.currency,_that.type,_that.useCustomType,_that.customType,_that.isSaving,_that.submissionSuccess,_that.isPrimary,_that.nameError,_that.balanceError,_that.typeError,_that.errorMessage,_that.color,_that.gradientId,_that.iconName,_that.iconStyle);case _:
  return null;

}
}

}

/// @nodoc


class _AddAccountFormState extends AddAccountFormState {
  const _AddAccountFormState({this.name = '', this.balanceInput = '', this.currency = 'RUB', this.type = 'cash', this.useCustomType = false, this.customType = '', this.isSaving = false, this.submissionSuccess = false, this.isPrimary = false, this.nameError, this.balanceError, this.typeError, this.errorMessage, this.color, this.gradientId, this.iconName, this.iconStyle}): super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String balanceInput;
@override@JsonKey() final  String currency;
@override@JsonKey() final  String type;
@override@JsonKey() final  bool useCustomType;
@override@JsonKey() final  String customType;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool submissionSuccess;
@override@JsonKey() final  bool isPrimary;
@override final  AddAccountFieldError? nameError;
@override final  AddAccountFieldError? balanceError;
@override final  AddAccountFieldError? typeError;
@override final  String? errorMessage;
@override final  String? color;
@override final  String? gradientId;
@override final  String? iconName;
@override final  String? iconStyle;

/// Create a copy of AddAccountFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddAccountFormStateCopyWith<_AddAccountFormState> get copyWith => __$AddAccountFormStateCopyWithImpl<_AddAccountFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddAccountFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.balanceInput, balanceInput) || other.balanceInput == balanceInput)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.type, type) || other.type == type)&&(identical(other.useCustomType, useCustomType) || other.useCustomType == useCustomType)&&(identical(other.customType, customType) || other.customType == customType)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.submissionSuccess, submissionSuccess) || other.submissionSuccess == submissionSuccess)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.balanceError, balanceError) || other.balanceError == balanceError)&&(identical(other.typeError, typeError) || other.typeError == typeError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.color, color) || other.color == color)&&(identical(other.gradientId, gradientId) || other.gradientId == gradientId)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.iconStyle, iconStyle) || other.iconStyle == iconStyle));
}


@override
int get hashCode => Object.hash(runtimeType,name,balanceInput,currency,type,useCustomType,customType,isSaving,submissionSuccess,isPrimary,nameError,balanceError,typeError,errorMessage,color,gradientId,iconName,iconStyle);

@override
String toString() {
  return 'AddAccountFormState(name: $name, balanceInput: $balanceInput, currency: $currency, type: $type, useCustomType: $useCustomType, customType: $customType, isSaving: $isSaving, submissionSuccess: $submissionSuccess, isPrimary: $isPrimary, nameError: $nameError, balanceError: $balanceError, typeError: $typeError, errorMessage: $errorMessage, color: $color, gradientId: $gradientId, iconName: $iconName, iconStyle: $iconStyle)';
}


}

/// @nodoc
abstract mixin class _$AddAccountFormStateCopyWith<$Res> implements $AddAccountFormStateCopyWith<$Res> {
  factory _$AddAccountFormStateCopyWith(_AddAccountFormState value, $Res Function(_AddAccountFormState) _then) = __$AddAccountFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String balanceInput, String currency, String type, bool useCustomType, String customType, bool isSaving, bool submissionSuccess, bool isPrimary, AddAccountFieldError? nameError, AddAccountFieldError? balanceError, AddAccountFieldError? typeError, String? errorMessage, String? color, String? gradientId, String? iconName, String? iconStyle
});




}
/// @nodoc
class __$AddAccountFormStateCopyWithImpl<$Res>
    implements _$AddAccountFormStateCopyWith<$Res> {
  __$AddAccountFormStateCopyWithImpl(this._self, this._then);

  final _AddAccountFormState _self;
  final $Res Function(_AddAccountFormState) _then;

/// Create a copy of AddAccountFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? balanceInput = null,Object? currency = null,Object? type = null,Object? useCustomType = null,Object? customType = null,Object? isSaving = null,Object? submissionSuccess = null,Object? isPrimary = null,Object? nameError = freezed,Object? balanceError = freezed,Object? typeError = freezed,Object? errorMessage = freezed,Object? color = freezed,Object? gradientId = freezed,Object? iconName = freezed,Object? iconStyle = freezed,}) {
  return _then(_AddAccountFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balanceInput: null == balanceInput ? _self.balanceInput : balanceInput // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,useCustomType: null == useCustomType ? _self.useCustomType : useCustomType // ignore: cast_nullable_to_non_nullable
as bool,customType: null == customType ? _self.customType : customType // ignore: cast_nullable_to_non_nullable
as String,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,submissionSuccess: null == submissionSuccess ? _self.submissionSuccess : submissionSuccess // ignore: cast_nullable_to_non_nullable
as bool,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as AddAccountFieldError?,balanceError: freezed == balanceError ? _self.balanceError : balanceError // ignore: cast_nullable_to_non_nullable
as AddAccountFieldError?,typeError: freezed == typeError ? _self.typeError : typeError // ignore: cast_nullable_to_non_nullable
as AddAccountFieldError?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,gradientId: freezed == gradientId ? _self.gradientId : gradientId // ignore: cast_nullable_to_non_nullable
as String?,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,iconStyle: freezed == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
