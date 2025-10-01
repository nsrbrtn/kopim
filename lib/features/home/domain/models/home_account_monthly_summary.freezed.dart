// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_account_monthly_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeAccountMonthlySummary {

 double get income; double get expense;
/// Create a copy of HomeAccountMonthlySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeAccountMonthlySummaryCopyWith<HomeAccountMonthlySummary> get copyWith => _$HomeAccountMonthlySummaryCopyWithImpl<HomeAccountMonthlySummary>(this as HomeAccountMonthlySummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeAccountMonthlySummary&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,income,expense);

@override
String toString() {
  return 'HomeAccountMonthlySummary(income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class $HomeAccountMonthlySummaryCopyWith<$Res>  {
  factory $HomeAccountMonthlySummaryCopyWith(HomeAccountMonthlySummary value, $Res Function(HomeAccountMonthlySummary) _then) = _$HomeAccountMonthlySummaryCopyWithImpl;
@useResult
$Res call({
 double income, double expense
});




}
/// @nodoc
class _$HomeAccountMonthlySummaryCopyWithImpl<$Res>
    implements $HomeAccountMonthlySummaryCopyWith<$Res> {
  _$HomeAccountMonthlySummaryCopyWithImpl(this._self, this._then);

  final HomeAccountMonthlySummary _self;
  final $Res Function(HomeAccountMonthlySummary) _then;

/// Create a copy of HomeAccountMonthlySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? income = null,Object? expense = null,}) {
  return _then(_self.copyWith(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeAccountMonthlySummary].
extension HomeAccountMonthlySummaryPatterns on HomeAccountMonthlySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeAccountMonthlySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeAccountMonthlySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeAccountMonthlySummary value)  $default,){
final _that = this;
switch (_that) {
case _HomeAccountMonthlySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeAccountMonthlySummary value)?  $default,){
final _that = this;
switch (_that) {
case _HomeAccountMonthlySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double income,  double expense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeAccountMonthlySummary() when $default != null:
return $default(_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double income,  double expense)  $default,) {final _that = this;
switch (_that) {
case _HomeAccountMonthlySummary():
return $default(_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double income,  double expense)?  $default,) {final _that = this;
switch (_that) {
case _HomeAccountMonthlySummary() when $default != null:
return $default(_that.income,_that.expense);case _:
  return null;

}
}

}

/// @nodoc


class _HomeAccountMonthlySummary extends HomeAccountMonthlySummary {
  const _HomeAccountMonthlySummary({required this.income, required this.expense}): super._();
  

@override final  double income;
@override final  double expense;

/// Create a copy of HomeAccountMonthlySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeAccountMonthlySummaryCopyWith<_HomeAccountMonthlySummary> get copyWith => __$HomeAccountMonthlySummaryCopyWithImpl<_HomeAccountMonthlySummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeAccountMonthlySummary&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,income,expense);

@override
String toString() {
  return 'HomeAccountMonthlySummary(income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class _$HomeAccountMonthlySummaryCopyWith<$Res> implements $HomeAccountMonthlySummaryCopyWith<$Res> {
  factory _$HomeAccountMonthlySummaryCopyWith(_HomeAccountMonthlySummary value, $Res Function(_HomeAccountMonthlySummary) _then) = __$HomeAccountMonthlySummaryCopyWithImpl;
@override @useResult
$Res call({
 double income, double expense
});




}
/// @nodoc
class __$HomeAccountMonthlySummaryCopyWithImpl<$Res>
    implements _$HomeAccountMonthlySummaryCopyWith<$Res> {
  __$HomeAccountMonthlySummaryCopyWithImpl(this._self, this._then);

  final _HomeAccountMonthlySummary _self;
  final $Res Function(_HomeAccountMonthlySummary) _then;

/// Create a copy of HomeAccountMonthlySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? income = null,Object? expense = null,}) {
  return _then(_HomeAccountMonthlySummary(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
