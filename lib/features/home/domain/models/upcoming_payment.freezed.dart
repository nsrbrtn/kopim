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

 String get occurrenceId; String get ruleId; String get title; double get amount; String get currency; DateTime get dueDate; String get accountId; String get categoryId;
/// Create a copy of UpcomingPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpcomingPaymentCopyWith<UpcomingPayment> get copyWith => _$UpcomingPaymentCopyWithImpl<UpcomingPayment>(this as UpcomingPayment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpcomingPayment&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,occurrenceId,ruleId,title,amount,currency,dueDate,accountId,categoryId);

@override
String toString() {
  return 'UpcomingPayment(occurrenceId: $occurrenceId, ruleId: $ruleId, title: $title, amount: $amount, currency: $currency, dueDate: $dueDate, accountId: $accountId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $UpcomingPaymentCopyWith<$Res>  {
  factory $UpcomingPaymentCopyWith(UpcomingPayment value, $Res Function(UpcomingPayment) _then) = _$UpcomingPaymentCopyWithImpl;
@useResult
$Res call({
 String occurrenceId, String ruleId, String title, double amount, String currency, DateTime dueDate, String accountId, String categoryId
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
@pragma('vm:prefer-inline') @override $Res call({Object? occurrenceId = null,Object? ruleId = null,Object? title = null,Object? amount = null,Object? currency = null,Object? dueDate = null,Object? accountId = null,Object? categoryId = null,}) {
  return _then(_self.copyWith(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String occurrenceId,  String ruleId,  String title,  double amount,  String currency,  DateTime dueDate,  String accountId,  String categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpcomingPayment() when $default != null:
return $default(_that.occurrenceId,_that.ruleId,_that.title,_that.amount,_that.currency,_that.dueDate,_that.accountId,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String occurrenceId,  String ruleId,  String title,  double amount,  String currency,  DateTime dueDate,  String accountId,  String categoryId)  $default,) {final _that = this;
switch (_that) {
case _UpcomingPayment():
return $default(_that.occurrenceId,_that.ruleId,_that.title,_that.amount,_that.currency,_that.dueDate,_that.accountId,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String occurrenceId,  String ruleId,  String title,  double amount,  String currency,  DateTime dueDate,  String accountId,  String categoryId)?  $default,) {final _that = this;
switch (_that) {
case _UpcomingPayment() when $default != null:
return $default(_that.occurrenceId,_that.ruleId,_that.title,_that.amount,_that.currency,_that.dueDate,_that.accountId,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _UpcomingPayment extends UpcomingPayment {
  const _UpcomingPayment({required this.occurrenceId, required this.ruleId, required this.title, required this.amount, required this.currency, required this.dueDate, required this.accountId, required this.categoryId}): super._();
  

@override final  String occurrenceId;
@override final  String ruleId;
@override final  String title;
@override final  double amount;
@override final  String currency;
@override final  DateTime dueDate;
@override final  String accountId;
@override final  String categoryId;

/// Create a copy of UpcomingPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpcomingPaymentCopyWith<_UpcomingPayment> get copyWith => __$UpcomingPaymentCopyWithImpl<_UpcomingPayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpcomingPayment&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,occurrenceId,ruleId,title,amount,currency,dueDate,accountId,categoryId);

@override
String toString() {
  return 'UpcomingPayment(occurrenceId: $occurrenceId, ruleId: $ruleId, title: $title, amount: $amount, currency: $currency, dueDate: $dueDate, accountId: $accountId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$UpcomingPaymentCopyWith<$Res> implements $UpcomingPaymentCopyWith<$Res> {
  factory _$UpcomingPaymentCopyWith(_UpcomingPayment value, $Res Function(_UpcomingPayment) _then) = __$UpcomingPaymentCopyWithImpl;
@override @useResult
$Res call({
 String occurrenceId, String ruleId, String title, double amount, String currency, DateTime dueDate, String accountId, String categoryId
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
@override @pragma('vm:prefer-inline') $Res call({Object? occurrenceId = null,Object? ruleId = null,Object? title = null,Object? amount = null,Object? currency = null,Object? dueDate = null,Object? accountId = null,Object? categoryId = null,}) {
  return _then(_UpcomingPayment(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
