// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_payment_reminder_uc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreatePaymentReminderInput {

 String? get id; String get title; double get amount; DateTime get whenLocal; String? get note;
/// Create a copy of CreatePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePaymentReminderInputCopyWith<CreatePaymentReminderInput> get copyWith => _$CreatePaymentReminderInputCopyWithImpl<CreatePaymentReminderInput>(this as CreatePaymentReminderInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePaymentReminderInput&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.whenLocal, whenLocal) || other.whenLocal == whenLocal)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,amount,whenLocal,note);

@override
String toString() {
  return 'CreatePaymentReminderInput(id: $id, title: $title, amount: $amount, whenLocal: $whenLocal, note: $note)';
}


}

/// @nodoc
abstract mixin class $CreatePaymentReminderInputCopyWith<$Res>  {
  factory $CreatePaymentReminderInputCopyWith(CreatePaymentReminderInput value, $Res Function(CreatePaymentReminderInput) _then) = _$CreatePaymentReminderInputCopyWithImpl;
@useResult
$Res call({
 String? id, String title, double amount, DateTime whenLocal, String? note
});




}
/// @nodoc
class _$CreatePaymentReminderInputCopyWithImpl<$Res>
    implements $CreatePaymentReminderInputCopyWith<$Res> {
  _$CreatePaymentReminderInputCopyWithImpl(this._self, this._then);

  final CreatePaymentReminderInput _self;
  final $Res Function(CreatePaymentReminderInput) _then;

/// Create a copy of CreatePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? amount = null,Object? whenLocal = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,whenLocal: null == whenLocal ? _self.whenLocal : whenLocal // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePaymentReminderInput].
extension CreatePaymentReminderInputPatterns on CreatePaymentReminderInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePaymentReminderInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePaymentReminderInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePaymentReminderInput value)  $default,){
final _that = this;
switch (_that) {
case _CreatePaymentReminderInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePaymentReminderInput value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePaymentReminderInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String title,  double amount,  DateTime whenLocal,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePaymentReminderInput() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String title,  double amount,  DateTime whenLocal,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreatePaymentReminderInput():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String title,  double amount,  DateTime whenLocal,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreatePaymentReminderInput() when $default != null:
return $default(_that.id,_that.title,_that.amount,_that.whenLocal,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _CreatePaymentReminderInput implements CreatePaymentReminderInput {
  const _CreatePaymentReminderInput({this.id, required this.title, required this.amount, required this.whenLocal, this.note});
  

@override final  String? id;
@override final  String title;
@override final  double amount;
@override final  DateTime whenLocal;
@override final  String? note;

/// Create a copy of CreatePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePaymentReminderInputCopyWith<_CreatePaymentReminderInput> get copyWith => __$CreatePaymentReminderInputCopyWithImpl<_CreatePaymentReminderInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePaymentReminderInput&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.whenLocal, whenLocal) || other.whenLocal == whenLocal)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,amount,whenLocal,note);

@override
String toString() {
  return 'CreatePaymentReminderInput(id: $id, title: $title, amount: $amount, whenLocal: $whenLocal, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreatePaymentReminderInputCopyWith<$Res> implements $CreatePaymentReminderInputCopyWith<$Res> {
  factory _$CreatePaymentReminderInputCopyWith(_CreatePaymentReminderInput value, $Res Function(_CreatePaymentReminderInput) _then) = __$CreatePaymentReminderInputCopyWithImpl;
@override @useResult
$Res call({
 String? id, String title, double amount, DateTime whenLocal, String? note
});




}
/// @nodoc
class __$CreatePaymentReminderInputCopyWithImpl<$Res>
    implements _$CreatePaymentReminderInputCopyWith<$Res> {
  __$CreatePaymentReminderInputCopyWithImpl(this._self, this._then);

  final _CreatePaymentReminderInput _self;
  final $Res Function(_CreatePaymentReminderInput) _then;

/// Create a copy of CreatePaymentReminderInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? amount = null,Object? whenLocal = null,Object? note = freezed,}) {
  return _then(_CreatePaymentReminderInput(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,whenLocal: null == whenLocal ? _self.whenLocal : whenLocal // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
