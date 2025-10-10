// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_payment_reminder_uc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeletePaymentReminderInput {

 String get id;
/// Create a copy of DeletePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeletePaymentReminderInputCopyWith<DeletePaymentReminderInput> get copyWith => _$DeletePaymentReminderInputCopyWithImpl<DeletePaymentReminderInput>(this as DeletePaymentReminderInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeletePaymentReminderInput&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'DeletePaymentReminderInput(id: $id)';
}


}

/// @nodoc
abstract mixin class $DeletePaymentReminderInputCopyWith<$Res>  {
  factory $DeletePaymentReminderInputCopyWith(DeletePaymentReminderInput value, $Res Function(DeletePaymentReminderInput) _then) = _$DeletePaymentReminderInputCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$DeletePaymentReminderInputCopyWithImpl<$Res>
    implements $DeletePaymentReminderInputCopyWith<$Res> {
  _$DeletePaymentReminderInputCopyWithImpl(this._self, this._then);

  final DeletePaymentReminderInput _self;
  final $Res Function(DeletePaymentReminderInput) _then;

/// Create a copy of DeletePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeletePaymentReminderInput].
extension DeletePaymentReminderInputPatterns on DeletePaymentReminderInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeletePaymentReminderInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeletePaymentReminderInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeletePaymentReminderInput value)  $default,){
final _that = this;
switch (_that) {
case _DeletePaymentReminderInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeletePaymentReminderInput value)?  $default,){
final _that = this;
switch (_that) {
case _DeletePaymentReminderInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeletePaymentReminderInput() when $default != null:
return $default(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id)  $default,) {final _that = this;
switch (_that) {
case _DeletePaymentReminderInput():
return $default(_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id)?  $default,) {final _that = this;
switch (_that) {
case _DeletePaymentReminderInput() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _DeletePaymentReminderInput implements DeletePaymentReminderInput {
  const _DeletePaymentReminderInput({required this.id});
  

@override final  String id;

/// Create a copy of DeletePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeletePaymentReminderInputCopyWith<_DeletePaymentReminderInput> get copyWith => __$DeletePaymentReminderInputCopyWithImpl<_DeletePaymentReminderInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeletePaymentReminderInput&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'DeletePaymentReminderInput(id: $id)';
}


}

/// @nodoc
abstract mixin class _$DeletePaymentReminderInputCopyWith<$Res> implements $DeletePaymentReminderInputCopyWith<$Res> {
  factory _$DeletePaymentReminderInputCopyWith(_DeletePaymentReminderInput value, $Res Function(_DeletePaymentReminderInput) _then) = __$DeletePaymentReminderInputCopyWithImpl;
@override @useResult
$Res call({
 String id
});




}
/// @nodoc
class __$DeletePaymentReminderInputCopyWithImpl<$Res>
    implements _$DeletePaymentReminderInputCopyWith<$Res> {
  __$DeletePaymentReminderInputCopyWithImpl(this._self, this._then);

  final _DeletePaymentReminderInput _self;
  final $Res Function(_DeletePaymentReminderInput) _then;

/// Create a copy of DeletePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_DeletePaymentReminderInput(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
