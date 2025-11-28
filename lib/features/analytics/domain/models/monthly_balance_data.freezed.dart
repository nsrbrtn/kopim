// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_balance_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MonthlyBalanceData {

 DateTime get month; double get totalBalance;
/// Create a copy of MonthlyBalanceData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyBalanceDataCopyWith<MonthlyBalanceData> get copyWith => _$MonthlyBalanceDataCopyWithImpl<MonthlyBalanceData>(this as MonthlyBalanceData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyBalanceData&&(identical(other.month, month) || other.month == month)&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance));
}


@override
int get hashCode => Object.hash(runtimeType,month,totalBalance);

@override
String toString() {
  return 'MonthlyBalanceData(month: $month, totalBalance: $totalBalance)';
}


}

/// @nodoc
abstract mixin class $MonthlyBalanceDataCopyWith<$Res>  {
  factory $MonthlyBalanceDataCopyWith(MonthlyBalanceData value, $Res Function(MonthlyBalanceData) _then) = _$MonthlyBalanceDataCopyWithImpl;
@useResult
$Res call({
 DateTime month, double totalBalance
});




}
/// @nodoc
class _$MonthlyBalanceDataCopyWithImpl<$Res>
    implements $MonthlyBalanceDataCopyWith<$Res> {
  _$MonthlyBalanceDataCopyWithImpl(this._self, this._then);

  final MonthlyBalanceData _self;
  final $Res Function(MonthlyBalanceData) _then;

/// Create a copy of MonthlyBalanceData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? totalBalance = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyBalanceData].
extension MonthlyBalanceDataPatterns on MonthlyBalanceData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyBalanceData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyBalanceData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyBalanceData value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyBalanceData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyBalanceData value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyBalanceData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime month,  double totalBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyBalanceData() when $default != null:
return $default(_that.month,_that.totalBalance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime month,  double totalBalance)  $default,) {final _that = this;
switch (_that) {
case _MonthlyBalanceData():
return $default(_that.month,_that.totalBalance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime month,  double totalBalance)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyBalanceData() when $default != null:
return $default(_that.month,_that.totalBalance);case _:
  return null;

}
}

}

/// @nodoc


class _MonthlyBalanceData extends MonthlyBalanceData {
  const _MonthlyBalanceData({required this.month, required this.totalBalance}): super._();
  

@override final  DateTime month;
@override final  double totalBalance;

/// Create a copy of MonthlyBalanceData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyBalanceDataCopyWith<_MonthlyBalanceData> get copyWith => __$MonthlyBalanceDataCopyWithImpl<_MonthlyBalanceData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyBalanceData&&(identical(other.month, month) || other.month == month)&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance));
}


@override
int get hashCode => Object.hash(runtimeType,month,totalBalance);

@override
String toString() {
  return 'MonthlyBalanceData(month: $month, totalBalance: $totalBalance)';
}


}

/// @nodoc
abstract mixin class _$MonthlyBalanceDataCopyWith<$Res> implements $MonthlyBalanceDataCopyWith<$Res> {
  factory _$MonthlyBalanceDataCopyWith(_MonthlyBalanceData value, $Res Function(_MonthlyBalanceData) _then) = __$MonthlyBalanceDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime month, double totalBalance
});




}
/// @nodoc
class __$MonthlyBalanceDataCopyWithImpl<$Res>
    implements _$MonthlyBalanceDataCopyWith<$Res> {
  __$MonthlyBalanceDataCopyWithImpl(this._self, this._then);

  final _MonthlyBalanceData _self;
  final $Res Function(_MonthlyBalanceData) _then;

/// Create a copy of MonthlyBalanceData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? totalBalance = null,}) {
  return _then(_MonthlyBalanceData(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
