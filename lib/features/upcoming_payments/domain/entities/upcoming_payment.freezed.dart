// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upcoming_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpcomingPayment {

 String get id; String get title; String get accountId; String get categoryId;@JsonKey(includeFromJson: false, includeToJson: false) BigInt? get amountMinor;@JsonKey(includeFromJson: false, includeToJson: false) int? get amountScale; int get dayOfMonth; int get notifyDaysBefore; String get notifyTimeHhmm; String? get note; bool get autoPost; bool get isActive; int? get nextRunAtMs; int? get nextNotifyAtMs; int get createdAtMs; int get updatedAtMs;
/// Create a copy of UpcomingPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpcomingPaymentCopyWith<UpcomingPayment> get copyWith => _$UpcomingPaymentCopyWithImpl<UpcomingPayment>(this as UpcomingPayment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpcomingPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.amountScale, amountScale) || other.amountScale == amountScale)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.notifyDaysBefore, notifyDaysBefore) || other.notifyDaysBefore == notifyDaysBefore)&&(identical(other.notifyTimeHhmm, notifyTimeHhmm) || other.notifyTimeHhmm == notifyTimeHhmm)&&(identical(other.note, note) || other.note == note)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.nextRunAtMs, nextRunAtMs) || other.nextRunAtMs == nextRunAtMs)&&(identical(other.nextNotifyAtMs, nextNotifyAtMs) || other.nextNotifyAtMs == nextNotifyAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,accountId,categoryId,amountMinor,amountScale,dayOfMonth,notifyDaysBefore,notifyTimeHhmm,note,autoPost,isActive,nextRunAtMs,nextNotifyAtMs,createdAtMs,updatedAtMs);

@override
String toString() {
  return 'UpcomingPayment(id: $id, title: $title, accountId: $accountId, categoryId: $categoryId, amountMinor: $amountMinor, amountScale: $amountScale, dayOfMonth: $dayOfMonth, notifyDaysBefore: $notifyDaysBefore, notifyTimeHhmm: $notifyTimeHhmm, note: $note, autoPost: $autoPost, isActive: $isActive, nextRunAtMs: $nextRunAtMs, nextNotifyAtMs: $nextNotifyAtMs, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs)';
}


}

/// @nodoc
abstract mixin class $UpcomingPaymentCopyWith<$Res>  {
  factory $UpcomingPaymentCopyWith(UpcomingPayment value, $Res Function(UpcomingPayment) _then) = _$UpcomingPaymentCopyWithImpl;
@useResult
$Res call({
 String id, String title, String accountId, String categoryId,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? amountMinor,@JsonKey(includeFromJson: false, includeToJson: false) int? amountScale, int dayOfMonth, int notifyDaysBefore, String notifyTimeHhmm, String? note, bool autoPost, bool isActive, int? nextRunAtMs, int? nextNotifyAtMs, int createdAtMs, int updatedAtMs
});




}
/// @nodoc
class _$UpcomingPaymentCopyWithImpl<$Res>
    implements $UpcomingPaymentCopyWith<$Res> {
  _$UpcomingPaymentCopyWithImpl(this._self, this._then);

  final UpcomingPayment _self;
  final $Res Function(UpcomingPayment) _then;

/// Create a copy of UpcomingPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? accountId = null,Object? categoryId = null,Object? amountMinor = freezed,Object? amountScale = freezed,Object? dayOfMonth = null,Object? notifyDaysBefore = null,Object? notifyTimeHhmm = null,Object? note = freezed,Object? autoPost = null,Object? isActive = null,Object? nextRunAtMs = freezed,Object? nextNotifyAtMs = freezed,Object? createdAtMs = null,Object? updatedAtMs = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,amountScale: freezed == amountScale ? _self.amountScale : amountScale // ignore: cast_nullable_to_non_nullable
as int?,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,notifyDaysBefore: null == notifyDaysBefore ? _self.notifyDaysBefore : notifyDaysBefore // ignore: cast_nullable_to_non_nullable
as int,notifyTimeHhmm: null == notifyTimeHhmm ? _self.notifyTimeHhmm : notifyTimeHhmm // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,autoPost: null == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,nextRunAtMs: freezed == nextRunAtMs ? _self.nextRunAtMs : nextRunAtMs // ignore: cast_nullable_to_non_nullable
as int?,nextNotifyAtMs: freezed == nextNotifyAtMs ? _self.nextNotifyAtMs : nextNotifyAtMs // ignore: cast_nullable_to_non_nullable
as int?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UpcomingPayment].
extension UpcomingPaymentPatterns on UpcomingPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpcomingPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpcomingPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpcomingPayment value)  $default,){
final _that = this;
switch (_that) {
case _UpcomingPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpcomingPayment value)?  $default,){
final _that = this;
switch (_that) {
case _UpcomingPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String accountId,  String categoryId, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? amountMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? amountScale,  int dayOfMonth,  int notifyDaysBefore,  String notifyTimeHhmm,  String? note,  bool autoPost,  bool isActive,  int? nextRunAtMs,  int? nextNotifyAtMs,  int createdAtMs,  int updatedAtMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpcomingPayment() when $default != null:
return $default(_that.id,_that.title,_that.accountId,_that.categoryId,_that.amountMinor,_that.amountScale,_that.dayOfMonth,_that.notifyDaysBefore,_that.notifyTimeHhmm,_that.note,_that.autoPost,_that.isActive,_that.nextRunAtMs,_that.nextNotifyAtMs,_that.createdAtMs,_that.updatedAtMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String accountId,  String categoryId, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? amountMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? amountScale,  int dayOfMonth,  int notifyDaysBefore,  String notifyTimeHhmm,  String? note,  bool autoPost,  bool isActive,  int? nextRunAtMs,  int? nextNotifyAtMs,  int createdAtMs,  int updatedAtMs)  $default,) {final _that = this;
switch (_that) {
case _UpcomingPayment():
return $default(_that.id,_that.title,_that.accountId,_that.categoryId,_that.amountMinor,_that.amountScale,_that.dayOfMonth,_that.notifyDaysBefore,_that.notifyTimeHhmm,_that.note,_that.autoPost,_that.isActive,_that.nextRunAtMs,_that.nextNotifyAtMs,_that.createdAtMs,_that.updatedAtMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String accountId,  String categoryId, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? amountMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? amountScale,  int dayOfMonth,  int notifyDaysBefore,  String notifyTimeHhmm,  String? note,  bool autoPost,  bool isActive,  int? nextRunAtMs,  int? nextNotifyAtMs,  int createdAtMs,  int updatedAtMs)?  $default,) {final _that = this;
switch (_that) {
case _UpcomingPayment() when $default != null:
return $default(_that.id,_that.title,_that.accountId,_that.categoryId,_that.amountMinor,_that.amountScale,_that.dayOfMonth,_that.notifyDaysBefore,_that.notifyTimeHhmm,_that.note,_that.autoPost,_that.isActive,_that.nextRunAtMs,_that.nextNotifyAtMs,_that.createdAtMs,_that.updatedAtMs);case _:
  return null;

}
}

}

/// @nodoc


class _UpcomingPayment extends UpcomingPayment {
  const _UpcomingPayment({required this.id, required this.title, required this.accountId, required this.categoryId, @JsonKey(includeFromJson: false, includeToJson: false) this.amountMinor, @JsonKey(includeFromJson: false, includeToJson: false) this.amountScale, required this.dayOfMonth, required this.notifyDaysBefore, required this.notifyTimeHhmm, this.note, required this.autoPost, required this.isActive, this.nextRunAtMs, this.nextNotifyAtMs, required this.createdAtMs, required this.updatedAtMs}): super._();
  

@override final  String id;
@override final  String title;
@override final  String accountId;
@override final  String categoryId;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  BigInt? amountMinor;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  int? amountScale;
@override final  int dayOfMonth;
@override final  int notifyDaysBefore;
@override final  String notifyTimeHhmm;
@override final  String? note;
@override final  bool autoPost;
@override final  bool isActive;
@override final  int? nextRunAtMs;
@override final  int? nextNotifyAtMs;
@override final  int createdAtMs;
@override final  int updatedAtMs;

/// Create a copy of UpcomingPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpcomingPaymentCopyWith<_UpcomingPayment> get copyWith => __$UpcomingPaymentCopyWithImpl<_UpcomingPayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpcomingPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.amountScale, amountScale) || other.amountScale == amountScale)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.notifyDaysBefore, notifyDaysBefore) || other.notifyDaysBefore == notifyDaysBefore)&&(identical(other.notifyTimeHhmm, notifyTimeHhmm) || other.notifyTimeHhmm == notifyTimeHhmm)&&(identical(other.note, note) || other.note == note)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.nextRunAtMs, nextRunAtMs) || other.nextRunAtMs == nextRunAtMs)&&(identical(other.nextNotifyAtMs, nextNotifyAtMs) || other.nextNotifyAtMs == nextNotifyAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,accountId,categoryId,amountMinor,amountScale,dayOfMonth,notifyDaysBefore,notifyTimeHhmm,note,autoPost,isActive,nextRunAtMs,nextNotifyAtMs,createdAtMs,updatedAtMs);

@override
String toString() {
  return 'UpcomingPayment(id: $id, title: $title, accountId: $accountId, categoryId: $categoryId, amountMinor: $amountMinor, amountScale: $amountScale, dayOfMonth: $dayOfMonth, notifyDaysBefore: $notifyDaysBefore, notifyTimeHhmm: $notifyTimeHhmm, note: $note, autoPost: $autoPost, isActive: $isActive, nextRunAtMs: $nextRunAtMs, nextNotifyAtMs: $nextNotifyAtMs, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs)';
}


}

/// @nodoc
abstract mixin class _$UpcomingPaymentCopyWith<$Res> implements $UpcomingPaymentCopyWith<$Res> {
  factory _$UpcomingPaymentCopyWith(_UpcomingPayment value, $Res Function(_UpcomingPayment) _then) = __$UpcomingPaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String accountId, String categoryId,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? amountMinor,@JsonKey(includeFromJson: false, includeToJson: false) int? amountScale, int dayOfMonth, int notifyDaysBefore, String notifyTimeHhmm, String? note, bool autoPost, bool isActive, int? nextRunAtMs, int? nextNotifyAtMs, int createdAtMs, int updatedAtMs
});




}
/// @nodoc
class __$UpcomingPaymentCopyWithImpl<$Res>
    implements _$UpcomingPaymentCopyWith<$Res> {
  __$UpcomingPaymentCopyWithImpl(this._self, this._then);

  final _UpcomingPayment _self;
  final $Res Function(_UpcomingPayment) _then;

/// Create a copy of UpcomingPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? accountId = null,Object? categoryId = null,Object? amountMinor = freezed,Object? amountScale = freezed,Object? dayOfMonth = null,Object? notifyDaysBefore = null,Object? notifyTimeHhmm = null,Object? note = freezed,Object? autoPost = null,Object? isActive = null,Object? nextRunAtMs = freezed,Object? nextNotifyAtMs = freezed,Object? createdAtMs = null,Object? updatedAtMs = null,}) {
  return _then(_UpcomingPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,amountScale: freezed == amountScale ? _self.amountScale : amountScale // ignore: cast_nullable_to_non_nullable
as int?,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,notifyDaysBefore: null == notifyDaysBefore ? _self.notifyDaysBefore : notifyDaysBefore // ignore: cast_nullable_to_non_nullable
as int,notifyTimeHhmm: null == notifyTimeHhmm ? _self.notifyTimeHhmm : notifyTimeHhmm // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,autoPost: null == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,nextRunAtMs: freezed == nextRunAtMs ? _self.nextRunAtMs : nextRunAtMs // ignore: cast_nullable_to_non_nullable
as int?,nextNotifyAtMs: freezed == nextNotifyAtMs ? _self.nextNotifyAtMs : nextNotifyAtMs // ignore: cast_nullable_to_non_nullable
as int?,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
