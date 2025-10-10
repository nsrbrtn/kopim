// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_upcoming_payment_uc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateUpcomingPaymentInput {

 String? get id; String get title; String get accountId; String get categoryId; double get amount; int get dayOfMonth; int get notifyDaysBefore; String get notifyTimeHhmm; String? get note; bool get autoPost;
/// Create a copy of CreateUpcomingPaymentInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateUpcomingPaymentInputCopyWith<CreateUpcomingPaymentInput> get copyWith => _$CreateUpcomingPaymentInputCopyWithImpl<CreateUpcomingPaymentInput>(this as CreateUpcomingPaymentInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateUpcomingPaymentInput&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.notifyDaysBefore, notifyDaysBefore) || other.notifyDaysBefore == notifyDaysBefore)&&(identical(other.notifyTimeHhmm, notifyTimeHhmm) || other.notifyTimeHhmm == notifyTimeHhmm)&&(identical(other.note, note) || other.note == note)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,accountId,categoryId,amount,dayOfMonth,notifyDaysBefore,notifyTimeHhmm,note,autoPost);

@override
String toString() {
  return 'CreateUpcomingPaymentInput(id: $id, title: $title, accountId: $accountId, categoryId: $categoryId, amount: $amount, dayOfMonth: $dayOfMonth, notifyDaysBefore: $notifyDaysBefore, notifyTimeHhmm: $notifyTimeHhmm, note: $note, autoPost: $autoPost)';
}


}

/// @nodoc
abstract mixin class $CreateUpcomingPaymentInputCopyWith<$Res>  {
  factory $CreateUpcomingPaymentInputCopyWith(CreateUpcomingPaymentInput value, $Res Function(CreateUpcomingPaymentInput) _then) = _$CreateUpcomingPaymentInputCopyWithImpl;
@useResult
$Res call({
 String? id, String title, String accountId, String categoryId, double amount, int dayOfMonth, int notifyDaysBefore, String notifyTimeHhmm, String? note, bool autoPost
});




}
/// @nodoc
class _$CreateUpcomingPaymentInputCopyWithImpl<$Res>
    implements $CreateUpcomingPaymentInputCopyWith<$Res> {
  _$CreateUpcomingPaymentInputCopyWithImpl(this._self, this._then);

  final CreateUpcomingPaymentInput _self;
  final $Res Function(CreateUpcomingPaymentInput) _then;

/// Create a copy of CreateUpcomingPaymentInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? accountId = null,Object? categoryId = null,Object? amount = null,Object? dayOfMonth = null,Object? notifyDaysBefore = null,Object? notifyTimeHhmm = null,Object? note = freezed,Object? autoPost = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,notifyDaysBefore: null == notifyDaysBefore ? _self.notifyDaysBefore : notifyDaysBefore // ignore: cast_nullable_to_non_nullable
as int,notifyTimeHhmm: null == notifyTimeHhmm ? _self.notifyTimeHhmm : notifyTimeHhmm // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,autoPost: null == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateUpcomingPaymentInput].
extension CreateUpcomingPaymentInputPatterns on CreateUpcomingPaymentInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateUpcomingPaymentInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateUpcomingPaymentInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateUpcomingPaymentInput value)  $default,){
final _that = this;
switch (_that) {
case _CreateUpcomingPaymentInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateUpcomingPaymentInput value)?  $default,){
final _that = this;
switch (_that) {
case _CreateUpcomingPaymentInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String title,  String accountId,  String categoryId,  double amount,  int dayOfMonth,  int notifyDaysBefore,  String notifyTimeHhmm,  String? note,  bool autoPost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateUpcomingPaymentInput() when $default != null:
return $default(_that.id,_that.title,_that.accountId,_that.categoryId,_that.amount,_that.dayOfMonth,_that.notifyDaysBefore,_that.notifyTimeHhmm,_that.note,_that.autoPost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String title,  String accountId,  String categoryId,  double amount,  int dayOfMonth,  int notifyDaysBefore,  String notifyTimeHhmm,  String? note,  bool autoPost)  $default,) {final _that = this;
switch (_that) {
case _CreateUpcomingPaymentInput():
return $default(_that.id,_that.title,_that.accountId,_that.categoryId,_that.amount,_that.dayOfMonth,_that.notifyDaysBefore,_that.notifyTimeHhmm,_that.note,_that.autoPost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String title,  String accountId,  String categoryId,  double amount,  int dayOfMonth,  int notifyDaysBefore,  String notifyTimeHhmm,  String? note,  bool autoPost)?  $default,) {final _that = this;
switch (_that) {
case _CreateUpcomingPaymentInput() when $default != null:
return $default(_that.id,_that.title,_that.accountId,_that.categoryId,_that.amount,_that.dayOfMonth,_that.notifyDaysBefore,_that.notifyTimeHhmm,_that.note,_that.autoPost);case _:
  return null;

}
}

}

/// @nodoc


class _CreateUpcomingPaymentInput implements CreateUpcomingPaymentInput {
  const _CreateUpcomingPaymentInput({this.id, required this.title, required this.accountId, required this.categoryId, required this.amount, required this.dayOfMonth, required this.notifyDaysBefore, required this.notifyTimeHhmm, this.note, required this.autoPost});
  

@override final  String? id;
@override final  String title;
@override final  String accountId;
@override final  String categoryId;
@override final  double amount;
@override final  int dayOfMonth;
@override final  int notifyDaysBefore;
@override final  String notifyTimeHhmm;
@override final  String? note;
@override final  bool autoPost;

/// Create a copy of CreateUpcomingPaymentInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateUpcomingPaymentInputCopyWith<_CreateUpcomingPaymentInput> get copyWith => __$CreateUpcomingPaymentInputCopyWithImpl<_CreateUpcomingPaymentInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateUpcomingPaymentInput&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.notifyDaysBefore, notifyDaysBefore) || other.notifyDaysBefore == notifyDaysBefore)&&(identical(other.notifyTimeHhmm, notifyTimeHhmm) || other.notifyTimeHhmm == notifyTimeHhmm)&&(identical(other.note, note) || other.note == note)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,accountId,categoryId,amount,dayOfMonth,notifyDaysBefore,notifyTimeHhmm,note,autoPost);

@override
String toString() {
  return 'CreateUpcomingPaymentInput(id: $id, title: $title, accountId: $accountId, categoryId: $categoryId, amount: $amount, dayOfMonth: $dayOfMonth, notifyDaysBefore: $notifyDaysBefore, notifyTimeHhmm: $notifyTimeHhmm, note: $note, autoPost: $autoPost)';
}


}

/// @nodoc
abstract mixin class _$CreateUpcomingPaymentInputCopyWith<$Res> implements $CreateUpcomingPaymentInputCopyWith<$Res> {
  factory _$CreateUpcomingPaymentInputCopyWith(_CreateUpcomingPaymentInput value, $Res Function(_CreateUpcomingPaymentInput) _then) = __$CreateUpcomingPaymentInputCopyWithImpl;
@override @useResult
$Res call({
 String? id, String title, String accountId, String categoryId, double amount, int dayOfMonth, int notifyDaysBefore, String notifyTimeHhmm, String? note, bool autoPost
});




}
/// @nodoc
class __$CreateUpcomingPaymentInputCopyWithImpl<$Res>
    implements _$CreateUpcomingPaymentInputCopyWith<$Res> {
  __$CreateUpcomingPaymentInputCopyWithImpl(this._self, this._then);

  final _CreateUpcomingPaymentInput _self;
  final $Res Function(_CreateUpcomingPaymentInput) _then;

/// Create a copy of CreateUpcomingPaymentInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? accountId = null,Object? categoryId = null,Object? amount = null,Object? dayOfMonth = null,Object? notifyDaysBefore = null,Object? notifyTimeHhmm = null,Object? note = freezed,Object? autoPost = null,}) {
  return _then(_CreateUpcomingPaymentInput(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,notifyDaysBefore: null == notifyDaysBefore ? _self.notifyDaysBefore : notifyDaysBefore // ignore: cast_nullable_to_non_nullable
as int,notifyTimeHhmm: null == notifyTimeHhmm ? _self.notifyTimeHhmm : notifyTimeHhmm // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,autoPost: null == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
