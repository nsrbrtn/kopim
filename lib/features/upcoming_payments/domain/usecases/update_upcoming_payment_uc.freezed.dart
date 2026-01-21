// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_upcoming_payment_uc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateUpcomingPaymentInput {

 String get id; String? get title; String? get accountId; String? get categoryId; MoneyAmount? get amount; int? get dayOfMonth; int? get notifyDaysBefore; String? get notifyTimeHhmm; ValueUpdate<String?> get note; bool? get autoPost; bool? get isActive;
/// Create a copy of UpdateUpcomingPaymentInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUpcomingPaymentInputCopyWith<UpdateUpcomingPaymentInput> get copyWith => _$UpdateUpcomingPaymentInputCopyWithImpl<UpdateUpcomingPaymentInput>(this as UpdateUpcomingPaymentInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUpcomingPaymentInput&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.notifyDaysBefore, notifyDaysBefore) || other.notifyDaysBefore == notifyDaysBefore)&&(identical(other.notifyTimeHhmm, notifyTimeHhmm) || other.notifyTimeHhmm == notifyTimeHhmm)&&(identical(other.note, note) || other.note == note)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,accountId,categoryId,amount,dayOfMonth,notifyDaysBefore,notifyTimeHhmm,note,autoPost,isActive);

@override
String toString() {
  return 'UpdateUpcomingPaymentInput(id: $id, title: $title, accountId: $accountId, categoryId: $categoryId, amount: $amount, dayOfMonth: $dayOfMonth, notifyDaysBefore: $notifyDaysBefore, notifyTimeHhmm: $notifyTimeHhmm, note: $note, autoPost: $autoPost, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $UpdateUpcomingPaymentInputCopyWith<$Res>  {
  factory $UpdateUpcomingPaymentInputCopyWith(UpdateUpcomingPaymentInput value, $Res Function(UpdateUpcomingPaymentInput) _then) = _$UpdateUpcomingPaymentInputCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? accountId, String? categoryId, MoneyAmount? amount, int? dayOfMonth, int? notifyDaysBefore, String? notifyTimeHhmm, ValueUpdate<String?> note, bool? autoPost, bool? isActive
});




}
/// @nodoc
class _$UpdateUpcomingPaymentInputCopyWithImpl<$Res>
    implements $UpdateUpcomingPaymentInputCopyWith<$Res> {
  _$UpdateUpcomingPaymentInputCopyWithImpl(this._self, this._then);

  final UpdateUpcomingPaymentInput _self;
  final $Res Function(UpdateUpcomingPaymentInput) _then;

/// Create a copy of UpdateUpcomingPaymentInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? accountId = freezed,Object? categoryId = freezed,Object? amount = freezed,Object? dayOfMonth = freezed,Object? notifyDaysBefore = freezed,Object? notifyTimeHhmm = freezed,Object? note = null,Object? autoPost = freezed,Object? isActive = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyAmount?,dayOfMonth: freezed == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int?,notifyDaysBefore: freezed == notifyDaysBefore ? _self.notifyDaysBefore : notifyDaysBefore // ignore: cast_nullable_to_non_nullable
as int?,notifyTimeHhmm: freezed == notifyTimeHhmm ? _self.notifyTimeHhmm : notifyTimeHhmm // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as ValueUpdate<String?>,autoPost: freezed == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateUpcomingPaymentInput].
extension UpdateUpcomingPaymentInputPatterns on UpdateUpcomingPaymentInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateUpcomingPaymentInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUpcomingPaymentInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateUpcomingPaymentInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdateUpcomingPaymentInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateUpcomingPaymentInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateUpcomingPaymentInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? accountId,  String? categoryId,  MoneyAmount? amount,  int? dayOfMonth,  int? notifyDaysBefore,  String? notifyTimeHhmm,  ValueUpdate<String?> note,  bool? autoPost,  bool? isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateUpcomingPaymentInput() when $default != null:
return $default(_that.id,_that.title,_that.accountId,_that.categoryId,_that.amount,_that.dayOfMonth,_that.notifyDaysBefore,_that.notifyTimeHhmm,_that.note,_that.autoPost,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? accountId,  String? categoryId,  MoneyAmount? amount,  int? dayOfMonth,  int? notifyDaysBefore,  String? notifyTimeHhmm,  ValueUpdate<String?> note,  bool? autoPost,  bool? isActive)  $default,) {final _that = this;
switch (_that) {
case _UpdateUpcomingPaymentInput():
return $default(_that.id,_that.title,_that.accountId,_that.categoryId,_that.amount,_that.dayOfMonth,_that.notifyDaysBefore,_that.notifyTimeHhmm,_that.note,_that.autoPost,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? accountId,  String? categoryId,  MoneyAmount? amount,  int? dayOfMonth,  int? notifyDaysBefore,  String? notifyTimeHhmm,  ValueUpdate<String?> note,  bool? autoPost,  bool? isActive)?  $default,) {final _that = this;
switch (_that) {
case _UpdateUpcomingPaymentInput() when $default != null:
return $default(_that.id,_that.title,_that.accountId,_that.categoryId,_that.amount,_that.dayOfMonth,_that.notifyDaysBefore,_that.notifyTimeHhmm,_that.note,_that.autoPost,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateUpcomingPaymentInput implements UpdateUpcomingPaymentInput {
  const _UpdateUpcomingPaymentInput({required this.id, this.title, this.accountId, this.categoryId, this.amount, this.dayOfMonth, this.notifyDaysBefore, this.notifyTimeHhmm, this.note = const ValueUpdate<String?>.absent(), this.autoPost, this.isActive});
  

@override final  String id;
@override final  String? title;
@override final  String? accountId;
@override final  String? categoryId;
@override final  MoneyAmount? amount;
@override final  int? dayOfMonth;
@override final  int? notifyDaysBefore;
@override final  String? notifyTimeHhmm;
@override@JsonKey() final  ValueUpdate<String?> note;
@override final  bool? autoPost;
@override final  bool? isActive;

/// Create a copy of UpdateUpcomingPaymentInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUpcomingPaymentInputCopyWith<_UpdateUpcomingPaymentInput> get copyWith => __$UpdateUpcomingPaymentInputCopyWithImpl<_UpdateUpcomingPaymentInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUpcomingPaymentInput&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.notifyDaysBefore, notifyDaysBefore) || other.notifyDaysBefore == notifyDaysBefore)&&(identical(other.notifyTimeHhmm, notifyTimeHhmm) || other.notifyTimeHhmm == notifyTimeHhmm)&&(identical(other.note, note) || other.note == note)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,accountId,categoryId,amount,dayOfMonth,notifyDaysBefore,notifyTimeHhmm,note,autoPost,isActive);

@override
String toString() {
  return 'UpdateUpcomingPaymentInput(id: $id, title: $title, accountId: $accountId, categoryId: $categoryId, amount: $amount, dayOfMonth: $dayOfMonth, notifyDaysBefore: $notifyDaysBefore, notifyTimeHhmm: $notifyTimeHhmm, note: $note, autoPost: $autoPost, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$UpdateUpcomingPaymentInputCopyWith<$Res> implements $UpdateUpcomingPaymentInputCopyWith<$Res> {
  factory _$UpdateUpcomingPaymentInputCopyWith(_UpdateUpcomingPaymentInput value, $Res Function(_UpdateUpcomingPaymentInput) _then) = __$UpdateUpcomingPaymentInputCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? accountId, String? categoryId, MoneyAmount? amount, int? dayOfMonth, int? notifyDaysBefore, String? notifyTimeHhmm, ValueUpdate<String?> note, bool? autoPost, bool? isActive
});




}
/// @nodoc
class __$UpdateUpcomingPaymentInputCopyWithImpl<$Res>
    implements _$UpdateUpcomingPaymentInputCopyWith<$Res> {
  __$UpdateUpcomingPaymentInputCopyWithImpl(this._self, this._then);

  final _UpdateUpcomingPaymentInput _self;
  final $Res Function(_UpdateUpcomingPaymentInput) _then;

/// Create a copy of UpdateUpcomingPaymentInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? accountId = freezed,Object? categoryId = freezed,Object? amount = freezed,Object? dayOfMonth = freezed,Object? notifyDaysBefore = freezed,Object? notifyTimeHhmm = freezed,Object? note = null,Object? autoPost = freezed,Object? isActive = freezed,}) {
  return _then(_UpdateUpcomingPaymentInput(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyAmount?,dayOfMonth: freezed == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int?,notifyDaysBefore: freezed == notifyDaysBefore ? _self.notifyDaysBefore : notifyDaysBefore // ignore: cast_nullable_to_non_nullable
as int?,notifyTimeHhmm: freezed == notifyTimeHhmm ? _self.notifyTimeHhmm : notifyTimeHhmm // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as ValueUpdate<String?>,autoPost: freezed == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
