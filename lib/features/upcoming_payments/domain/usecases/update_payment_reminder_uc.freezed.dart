// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_payment_reminder_uc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdatePaymentReminderInput {

 String get id; String? get title; MoneyAmount? get amount; DateTime? get whenLocal; ValueUpdate<String?> get note;
/// Create a copy of UpdatePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePaymentReminderInputCopyWith<UpdatePaymentReminderInput> get copyWith => _$UpdatePaymentReminderInputCopyWithImpl<UpdatePaymentReminderInput>(this as UpdatePaymentReminderInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePaymentReminderInput&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.whenLocal, whenLocal) || other.whenLocal == whenLocal)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,amount,whenLocal,note);

@override
String toString() {
  return 'UpdatePaymentReminderInput(id: $id, title: $title, amount: $amount, whenLocal: $whenLocal, note: $note)';
}


}

/// @nodoc
abstract mixin class $UpdatePaymentReminderInputCopyWith<$Res>  {
  factory $UpdatePaymentReminderInputCopyWith(UpdatePaymentReminderInput value, $Res Function(UpdatePaymentReminderInput) _then) = _$UpdatePaymentReminderInputCopyWithImpl;
@useResult
$Res call({
 String id, String? title, MoneyAmount? amount, DateTime? whenLocal, ValueUpdate<String?> note
});




}
/// @nodoc
class _$UpdatePaymentReminderInputCopyWithImpl<$Res>
    implements $UpdatePaymentReminderInputCopyWith<$Res> {
  _$UpdatePaymentReminderInputCopyWithImpl(this._self, this._then);

  final UpdatePaymentReminderInput _self;
  final $Res Function(UpdatePaymentReminderInput) _then;

/// Create a copy of UpdatePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? amount = freezed,Object? whenLocal = freezed,Object? note = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyAmount?,whenLocal: freezed == whenLocal ? _self.whenLocal : whenLocal // ignore: cast_nullable_to_non_nullable
as DateTime?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as ValueUpdate<String?>,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdatePaymentReminderInput].
extension UpdatePaymentReminderInputPatterns on UpdatePaymentReminderInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdatePaymentReminderInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatePaymentReminderInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdatePaymentReminderInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdatePaymentReminderInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdatePaymentReminderInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdatePaymentReminderInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  MoneyAmount? amount,  DateTime? whenLocal,  ValueUpdate<String?> note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdatePaymentReminderInput() when $default != null:
return $default(_that.id,_that.title,_that.amount,_that.whenLocal,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  MoneyAmount? amount,  DateTime? whenLocal,  ValueUpdate<String?> note)  $default,) {final _that = this;
switch (_that) {
case _UpdatePaymentReminderInput():
return $default(_that.id,_that.title,_that.amount,_that.whenLocal,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  MoneyAmount? amount,  DateTime? whenLocal,  ValueUpdate<String?> note)?  $default,) {final _that = this;
switch (_that) {
case _UpdatePaymentReminderInput() when $default != null:
return $default(_that.id,_that.title,_that.amount,_that.whenLocal,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _UpdatePaymentReminderInput implements UpdatePaymentReminderInput {
  const _UpdatePaymentReminderInput({required this.id, this.title, this.amount, this.whenLocal, this.note = const ValueUpdate<String?>.absent()});
  

@override final  String id;
@override final  String? title;
@override final  MoneyAmount? amount;
@override final  DateTime? whenLocal;
@override@JsonKey() final  ValueUpdate<String?> note;

/// Create a copy of UpdatePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePaymentReminderInputCopyWith<_UpdatePaymentReminderInput> get copyWith => __$UpdatePaymentReminderInputCopyWithImpl<_UpdatePaymentReminderInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePaymentReminderInput&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.whenLocal, whenLocal) || other.whenLocal == whenLocal)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,amount,whenLocal,note);

@override
String toString() {
  return 'UpdatePaymentReminderInput(id: $id, title: $title, amount: $amount, whenLocal: $whenLocal, note: $note)';
}


}

/// @nodoc
abstract mixin class _$UpdatePaymentReminderInputCopyWith<$Res> implements $UpdatePaymentReminderInputCopyWith<$Res> {
  factory _$UpdatePaymentReminderInputCopyWith(_UpdatePaymentReminderInput value, $Res Function(_UpdatePaymentReminderInput) _then) = __$UpdatePaymentReminderInputCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, MoneyAmount? amount, DateTime? whenLocal, ValueUpdate<String?> note
});




}
/// @nodoc
class __$UpdatePaymentReminderInputCopyWithImpl<$Res>
    implements _$UpdatePaymentReminderInputCopyWith<$Res> {
  __$UpdatePaymentReminderInputCopyWithImpl(this._self, this._then);

  final _UpdatePaymentReminderInput _self;
  final $Res Function(_UpdatePaymentReminderInput) _then;

/// Create a copy of UpdatePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? amount = freezed,Object? whenLocal = freezed,Object? note = null,}) {
  return _then(_UpdatePaymentReminderInput(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyAmount?,whenLocal: freezed == whenLocal ? _self.whenLocal : whenLocal // ignore: cast_nullable_to_non_nullable
as DateTime?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as ValueUpdate<String?>,
  ));
}


}

// dart format on
