// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentReminder {

 String get id; String get title; double get amount;@JsonKey(includeFromJson: false, includeToJson: false) BigInt? get amountMinor;@JsonKey(includeFromJson: false, includeToJson: false) int? get amountScale; int get whenAtMs; String? get note; bool get isDone; int? get lastNotifiedAtMs; int get createdAtMs; int get updatedAtMs;
/// Create a copy of PaymentReminder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentReminderCopyWith<PaymentReminder> get copyWith => _$PaymentReminderCopyWithImpl<PaymentReminder>(this as PaymentReminder, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentReminder&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.amountScale, amountScale) || other.amountScale == amountScale)&&(identical(other.whenAtMs, whenAtMs) || other.whenAtMs == whenAtMs)&&(identical(other.note, note) || other.note == note)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.lastNotifiedAtMs, lastNotifiedAtMs) || other.lastNotifiedAtMs == lastNotifiedAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,amount,amountMinor,amountScale,whenAtMs,note,isDone,lastNotifiedAtMs,createdAtMs,updatedAtMs);

@override
String toString() {
  return 'PaymentReminder(id: $id, title: $title, amount: $amount, amountMinor: $amountMinor, amountScale: $amountScale, whenAtMs: $whenAtMs, note: $note, isDone: $isDone, lastNotifiedAtMs: $lastNotifiedAtMs, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs)';
}


}

/// @nodoc
abstract mixin class $PaymentReminderCopyWith<$Res>  {
  factory $PaymentReminderCopyWith(PaymentReminder value, $Res Function(PaymentReminder) _then) = _$PaymentReminderCopyWithImpl;
@useResult
$Res call({
 String id, String title, double amount,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? amountMinor,@JsonKey(includeFromJson: false, includeToJson: false) int? amountScale, int whenAtMs, String? note, bool isDone, int? lastNotifiedAtMs, int createdAtMs, int updatedAtMs
});




}
/// @nodoc
class _$PaymentReminderCopyWithImpl<$Res>
    implements $PaymentReminderCopyWith<$Res> {
  _$PaymentReminderCopyWithImpl(this._self, this._then);

  final PaymentReminder _self;
  final $Res Function(PaymentReminder) _then;

/// Create a copy of PaymentReminder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? amount = null,Object? amountMinor = freezed,Object? amountScale = freezed,Object? whenAtMs = null,Object? note = freezed,Object? isDone = null,Object? lastNotifiedAtMs = freezed,Object? createdAtMs = null,Object? updatedAtMs = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,amountScale: freezed == amountScale ? _self.amountScale : amountScale // ignore: cast_nullable_to_non_nullable
as int?,whenAtMs: null == whenAtMs ? _self.whenAtMs : whenAtMs // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,lastNotifiedAtMs: freezed == lastNotifiedAtMs ? _self.lastNotifiedAtMs : lastNotifiedAtMs // ignore: cast_nullable_to_non_nullable
as int?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentReminder].
extension PaymentReminderPatterns on PaymentReminder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentReminder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentReminder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentReminder value)  $default,){
final _that = this;
switch (_that) {
case _PaymentReminder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentReminder value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentReminder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  double amount, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? amountMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? amountScale,  int whenAtMs,  String? note,  bool isDone,  int? lastNotifiedAtMs,  int createdAtMs,  int updatedAtMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentReminder() when $default != null:
return $default(_that.id,_that.title,_that.amount,_that.amountMinor,_that.amountScale,_that.whenAtMs,_that.note,_that.isDone,_that.lastNotifiedAtMs,_that.createdAtMs,_that.updatedAtMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  double amount, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? amountMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? amountScale,  int whenAtMs,  String? note,  bool isDone,  int? lastNotifiedAtMs,  int createdAtMs,  int updatedAtMs)  $default,) {final _that = this;
switch (_that) {
case _PaymentReminder():
return $default(_that.id,_that.title,_that.amount,_that.amountMinor,_that.amountScale,_that.whenAtMs,_that.note,_that.isDone,_that.lastNotifiedAtMs,_that.createdAtMs,_that.updatedAtMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  double amount, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? amountMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? amountScale,  int whenAtMs,  String? note,  bool isDone,  int? lastNotifiedAtMs,  int createdAtMs,  int updatedAtMs)?  $default,) {final _that = this;
switch (_that) {
case _PaymentReminder() when $default != null:
return $default(_that.id,_that.title,_that.amount,_that.amountMinor,_that.amountScale,_that.whenAtMs,_that.note,_that.isDone,_that.lastNotifiedAtMs,_that.createdAtMs,_that.updatedAtMs);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentReminder extends PaymentReminder {
  const _PaymentReminder({required this.id, required this.title, required this.amount, @JsonKey(includeFromJson: false, includeToJson: false) this.amountMinor, @JsonKey(includeFromJson: false, includeToJson: false) this.amountScale, required this.whenAtMs, this.note, required this.isDone, this.lastNotifiedAtMs, required this.createdAtMs, required this.updatedAtMs}): super._();
  

@override final  String id;
@override final  String title;
@override final  double amount;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  BigInt? amountMinor;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  int? amountScale;
@override final  int whenAtMs;
@override final  String? note;
@override final  bool isDone;
@override final  int? lastNotifiedAtMs;
@override final  int createdAtMs;
@override final  int updatedAtMs;

/// Create a copy of PaymentReminder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentReminderCopyWith<_PaymentReminder> get copyWith => __$PaymentReminderCopyWithImpl<_PaymentReminder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentReminder&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.amountScale, amountScale) || other.amountScale == amountScale)&&(identical(other.whenAtMs, whenAtMs) || other.whenAtMs == whenAtMs)&&(identical(other.note, note) || other.note == note)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.lastNotifiedAtMs, lastNotifiedAtMs) || other.lastNotifiedAtMs == lastNotifiedAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,amount,amountMinor,amountScale,whenAtMs,note,isDone,lastNotifiedAtMs,createdAtMs,updatedAtMs);

@override
String toString() {
  return 'PaymentReminder(id: $id, title: $title, amount: $amount, amountMinor: $amountMinor, amountScale: $amountScale, whenAtMs: $whenAtMs, note: $note, isDone: $isDone, lastNotifiedAtMs: $lastNotifiedAtMs, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs)';
}


}

/// @nodoc
abstract mixin class _$PaymentReminderCopyWith<$Res> implements $PaymentReminderCopyWith<$Res> {
  factory _$PaymentReminderCopyWith(_PaymentReminder value, $Res Function(_PaymentReminder) _then) = __$PaymentReminderCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double amount,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? amountMinor,@JsonKey(includeFromJson: false, includeToJson: false) int? amountScale, int whenAtMs, String? note, bool isDone, int? lastNotifiedAtMs, int createdAtMs, int updatedAtMs
});




}
/// @nodoc
class __$PaymentReminderCopyWithImpl<$Res>
    implements _$PaymentReminderCopyWith<$Res> {
  __$PaymentReminderCopyWithImpl(this._self, this._then);

  final _PaymentReminder _self;
  final $Res Function(_PaymentReminder) _then;

/// Create a copy of PaymentReminder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? amount = null,Object? amountMinor = freezed,Object? amountScale = freezed,Object? whenAtMs = null,Object? note = freezed,Object? isDone = null,Object? lastNotifiedAtMs = freezed,Object? createdAtMs = null,Object? updatedAtMs = null,}) {
  return _then(_PaymentReminder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,amountScale: freezed == amountScale ? _self.amountScale : amountScale // ignore: cast_nullable_to_non_nullable
as int?,whenAtMs: null == whenAtMs ? _self.whenAtMs : whenAtMs // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,lastNotifiedAtMs: freezed == lastNotifiedAtMs ? _self.lastNotifiedAtMs : lastNotifiedAtMs // ignore: cast_nullable_to_non_nullable
as int?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
