// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_goal_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditGoalState {

 SavingGoal? get original; String get name; String get targetInput; String? get nameError; String? get targetError; String? get note; bool get isSaving; bool get submissionSuccess; String? get errorMessage;
/// Create a copy of EditGoalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditGoalStateCopyWith<EditGoalState> get copyWith => _$EditGoalStateCopyWithImpl<EditGoalState>(this as EditGoalState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditGoalState&&(identical(other.original, original) || other.original == original)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetInput, targetInput) || other.targetInput == targetInput)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.targetError, targetError) || other.targetError == targetError)&&(identical(other.note, note) || other.note == note)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.submissionSuccess, submissionSuccess) || other.submissionSuccess == submissionSuccess)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,original,name,targetInput,nameError,targetError,note,isSaving,submissionSuccess,errorMessage);

@override
String toString() {
  return 'EditGoalState(original: $original, name: $name, targetInput: $targetInput, nameError: $nameError, targetError: $targetError, note: $note, isSaving: $isSaving, submissionSuccess: $submissionSuccess, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $EditGoalStateCopyWith<$Res>  {
  factory $EditGoalStateCopyWith(EditGoalState value, $Res Function(EditGoalState) _then) = _$EditGoalStateCopyWithImpl;
@useResult
$Res call({
 SavingGoal? original, String name, String targetInput, String? nameError, String? targetError, String? note, bool isSaving, bool submissionSuccess, String? errorMessage
});


$SavingGoalCopyWith<$Res>? get original;

}
/// @nodoc
class _$EditGoalStateCopyWithImpl<$Res>
    implements $EditGoalStateCopyWith<$Res> {
  _$EditGoalStateCopyWithImpl(this._self, this._then);

  final EditGoalState _self;
  final $Res Function(EditGoalState) _then;

/// Create a copy of EditGoalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? original = freezed,Object? name = null,Object? targetInput = null,Object? nameError = freezed,Object? targetError = freezed,Object? note = freezed,Object? isSaving = null,Object? submissionSuccess = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as SavingGoal?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetInput: null == targetInput ? _self.targetInput : targetInput // ignore: cast_nullable_to_non_nullable
as String,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as String?,targetError: freezed == targetError ? _self.targetError : targetError // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,submissionSuccess: null == submissionSuccess ? _self.submissionSuccess : submissionSuccess // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EditGoalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavingGoalCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $SavingGoalCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditGoalState].
extension EditGoalStatePatterns on EditGoalState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditGoalState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditGoalState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditGoalState value)  $default,){
final _that = this;
switch (_that) {
case _EditGoalState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditGoalState value)?  $default,){
final _that = this;
switch (_that) {
case _EditGoalState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SavingGoal? original,  String name,  String targetInput,  String? nameError,  String? targetError,  String? note,  bool isSaving,  bool submissionSuccess,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditGoalState() when $default != null:
return $default(_that.original,_that.name,_that.targetInput,_that.nameError,_that.targetError,_that.note,_that.isSaving,_that.submissionSuccess,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SavingGoal? original,  String name,  String targetInput,  String? nameError,  String? targetError,  String? note,  bool isSaving,  bool submissionSuccess,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _EditGoalState():
return $default(_that.original,_that.name,_that.targetInput,_that.nameError,_that.targetError,_that.note,_that.isSaving,_that.submissionSuccess,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SavingGoal? original,  String name,  String targetInput,  String? nameError,  String? targetError,  String? note,  bool isSaving,  bool submissionSuccess,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _EditGoalState() when $default != null:
return $default(_that.original,_that.name,_that.targetInput,_that.nameError,_that.targetError,_that.note,_that.isSaving,_that.submissionSuccess,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _EditGoalState implements EditGoalState {
  const _EditGoalState({this.original, this.name = '', this.targetInput = '', this.nameError, this.targetError, this.note, this.isSaving = false, this.submissionSuccess = false, this.errorMessage});
  

@override final  SavingGoal? original;
@override@JsonKey() final  String name;
@override@JsonKey() final  String targetInput;
@override final  String? nameError;
@override final  String? targetError;
@override final  String? note;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool submissionSuccess;
@override final  String? errorMessage;

/// Create a copy of EditGoalState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditGoalStateCopyWith<_EditGoalState> get copyWith => __$EditGoalStateCopyWithImpl<_EditGoalState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditGoalState&&(identical(other.original, original) || other.original == original)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetInput, targetInput) || other.targetInput == targetInput)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.targetError, targetError) || other.targetError == targetError)&&(identical(other.note, note) || other.note == note)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.submissionSuccess, submissionSuccess) || other.submissionSuccess == submissionSuccess)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,original,name,targetInput,nameError,targetError,note,isSaving,submissionSuccess,errorMessage);

@override
String toString() {
  return 'EditGoalState(original: $original, name: $name, targetInput: $targetInput, nameError: $nameError, targetError: $targetError, note: $note, isSaving: $isSaving, submissionSuccess: $submissionSuccess, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$EditGoalStateCopyWith<$Res> implements $EditGoalStateCopyWith<$Res> {
  factory _$EditGoalStateCopyWith(_EditGoalState value, $Res Function(_EditGoalState) _then) = __$EditGoalStateCopyWithImpl;
@override @useResult
$Res call({
 SavingGoal? original, String name, String targetInput, String? nameError, String? targetError, String? note, bool isSaving, bool submissionSuccess, String? errorMessage
});


@override $SavingGoalCopyWith<$Res>? get original;

}
/// @nodoc
class __$EditGoalStateCopyWithImpl<$Res>
    implements _$EditGoalStateCopyWith<$Res> {
  __$EditGoalStateCopyWithImpl(this._self, this._then);

  final _EditGoalState _self;
  final $Res Function(_EditGoalState) _then;

/// Create a copy of EditGoalState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? original = freezed,Object? name = null,Object? targetInput = null,Object? nameError = freezed,Object? targetError = freezed,Object? note = freezed,Object? isSaving = null,Object? submissionSuccess = null,Object? errorMessage = freezed,}) {
  return _then(_EditGoalState(
original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as SavingGoal?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetInput: null == targetInput ? _self.targetInput : targetInput // ignore: cast_nullable_to_non_nullable
as String,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as String?,targetError: freezed == targetError ? _self.targetError : targetError // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,submissionSuccess: null == submissionSuccess ? _self.submissionSuccess : submissionSuccess // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EditGoalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavingGoalCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $SavingGoalCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
