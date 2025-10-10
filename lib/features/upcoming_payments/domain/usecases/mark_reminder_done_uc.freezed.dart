// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mark_reminder_done_uc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkReminderDoneInput {

 String get id; bool get isDone;
/// Create a copy of MarkReminderDoneInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkReminderDoneInputCopyWith<MarkReminderDoneInput> get copyWith => _$MarkReminderDoneInputCopyWithImpl<MarkReminderDoneInput>(this as MarkReminderDoneInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkReminderDoneInput&&(identical(other.id, id) || other.id == id)&&(identical(other.isDone, isDone) || other.isDone == isDone));
}


@override
int get hashCode => Object.hash(runtimeType,id,isDone);

@override
String toString() {
  return 'MarkReminderDoneInput(id: $id, isDone: $isDone)';
}


}

/// @nodoc
abstract mixin class $MarkReminderDoneInputCopyWith<$Res>  {
  factory $MarkReminderDoneInputCopyWith(MarkReminderDoneInput value, $Res Function(MarkReminderDoneInput) _then) = _$MarkReminderDoneInputCopyWithImpl;
@useResult
$Res call({
 String id, bool isDone
});




}
/// @nodoc
class _$MarkReminderDoneInputCopyWithImpl<$Res>
    implements $MarkReminderDoneInputCopyWith<$Res> {
  _$MarkReminderDoneInputCopyWithImpl(this._self, this._then);

  final MarkReminderDoneInput _self;
  final $Res Function(MarkReminderDoneInput) _then;

/// Create a copy of MarkReminderDoneInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isDone = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkReminderDoneInput].
extension MarkReminderDoneInputPatterns on MarkReminderDoneInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarkReminderDoneInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarkReminderDoneInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarkReminderDoneInput value)  $default,){
final _that = this;
switch (_that) {
case _MarkReminderDoneInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarkReminderDoneInput value)?  $default,){
final _that = this;
switch (_that) {
case _MarkReminderDoneInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isDone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarkReminderDoneInput() when $default != null:
return $default(_that.id,_that.isDone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isDone)  $default,) {final _that = this;
switch (_that) {
case _MarkReminderDoneInput():
return $default(_that.id,_that.isDone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isDone)?  $default,) {final _that = this;
switch (_that) {
case _MarkReminderDoneInput() when $default != null:
return $default(_that.id,_that.isDone);case _:
  return null;

}
}

}

/// @nodoc


class _MarkReminderDoneInput implements MarkReminderDoneInput {
  const _MarkReminderDoneInput({required this.id, required this.isDone});
  

@override final  String id;
@override final  bool isDone;

/// Create a copy of MarkReminderDoneInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkReminderDoneInputCopyWith<_MarkReminderDoneInput> get copyWith => __$MarkReminderDoneInputCopyWithImpl<_MarkReminderDoneInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkReminderDoneInput&&(identical(other.id, id) || other.id == id)&&(identical(other.isDone, isDone) || other.isDone == isDone));
}


@override
int get hashCode => Object.hash(runtimeType,id,isDone);

@override
String toString() {
  return 'MarkReminderDoneInput(id: $id, isDone: $isDone)';
}


}

/// @nodoc
abstract mixin class _$MarkReminderDoneInputCopyWith<$Res> implements $MarkReminderDoneInputCopyWith<$Res> {
  factory _$MarkReminderDoneInputCopyWith(_MarkReminderDoneInput value, $Res Function(_MarkReminderDoneInput) _then) = __$MarkReminderDoneInputCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isDone
});




}
/// @nodoc
class __$MarkReminderDoneInputCopyWithImpl<$Res>
    implements _$MarkReminderDoneInputCopyWith<$Res> {
  __$MarkReminderDoneInputCopyWithImpl(this._self, this._then);

  final _MarkReminderDoneInput _self;
  final $Res Function(_MarkReminderDoneInput) _then;

/// Create a copy of MarkReminderDoneInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isDone = null,}) {
  return _then(_MarkReminderDoneInput(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
