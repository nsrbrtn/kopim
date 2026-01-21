// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_overview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalyticsOverview {

 MoneyAmount get totalIncome; MoneyAmount get totalExpense; MoneyAmount get netBalance; List<AnalyticsCategoryBreakdown> get topExpenseCategories; List<AnalyticsCategoryBreakdown> get topIncomeCategories;
/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsOverviewCopyWith<AnalyticsOverview> get copyWith => _$AnalyticsOverviewCopyWithImpl<AnalyticsOverview>(this as AnalyticsOverview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsOverview&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.netBalance, netBalance) || other.netBalance == netBalance)&&const DeepCollectionEquality().equals(other.topExpenseCategories, topExpenseCategories)&&const DeepCollectionEquality().equals(other.topIncomeCategories, topIncomeCategories));
}


@override
int get hashCode => Object.hash(runtimeType,totalIncome,totalExpense,netBalance,const DeepCollectionEquality().hash(topExpenseCategories),const DeepCollectionEquality().hash(topIncomeCategories));

@override
String toString() {
  return 'AnalyticsOverview(totalIncome: $totalIncome, totalExpense: $totalExpense, netBalance: $netBalance, topExpenseCategories: $topExpenseCategories, topIncomeCategories: $topIncomeCategories)';
}


}

/// @nodoc
abstract mixin class $AnalyticsOverviewCopyWith<$Res>  {
  factory $AnalyticsOverviewCopyWith(AnalyticsOverview value, $Res Function(AnalyticsOverview) _then) = _$AnalyticsOverviewCopyWithImpl;
@useResult
$Res call({
 MoneyAmount totalIncome, MoneyAmount totalExpense, MoneyAmount netBalance, List<AnalyticsCategoryBreakdown> topExpenseCategories, List<AnalyticsCategoryBreakdown> topIncomeCategories
});




}
/// @nodoc
class _$AnalyticsOverviewCopyWithImpl<$Res>
    implements $AnalyticsOverviewCopyWith<$Res> {
  _$AnalyticsOverviewCopyWithImpl(this._self, this._then);

  final AnalyticsOverview _self;
  final $Res Function(AnalyticsOverview) _then;

/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalIncome = null,Object? totalExpense = null,Object? netBalance = null,Object? topExpenseCategories = null,Object? topIncomeCategories = null,}) {
  return _then(_self.copyWith(
totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as MoneyAmount,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as MoneyAmount,netBalance: null == netBalance ? _self.netBalance : netBalance // ignore: cast_nullable_to_non_nullable
as MoneyAmount,topExpenseCategories: null == topExpenseCategories ? _self.topExpenseCategories : topExpenseCategories // ignore: cast_nullable_to_non_nullable
as List<AnalyticsCategoryBreakdown>,topIncomeCategories: null == topIncomeCategories ? _self.topIncomeCategories : topIncomeCategories // ignore: cast_nullable_to_non_nullable
as List<AnalyticsCategoryBreakdown>,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsOverview].
extension AnalyticsOverviewPatterns on AnalyticsOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsOverview value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsOverview value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MoneyAmount totalIncome,  MoneyAmount totalExpense,  MoneyAmount netBalance,  List<AnalyticsCategoryBreakdown> topExpenseCategories,  List<AnalyticsCategoryBreakdown> topIncomeCategories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
return $default(_that.totalIncome,_that.totalExpense,_that.netBalance,_that.topExpenseCategories,_that.topIncomeCategories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MoneyAmount totalIncome,  MoneyAmount totalExpense,  MoneyAmount netBalance,  List<AnalyticsCategoryBreakdown> topExpenseCategories,  List<AnalyticsCategoryBreakdown> topIncomeCategories)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsOverview():
return $default(_that.totalIncome,_that.totalExpense,_that.netBalance,_that.topExpenseCategories,_that.topIncomeCategories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MoneyAmount totalIncome,  MoneyAmount totalExpense,  MoneyAmount netBalance,  List<AnalyticsCategoryBreakdown> topExpenseCategories,  List<AnalyticsCategoryBreakdown> topIncomeCategories)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
return $default(_that.totalIncome,_that.totalExpense,_that.netBalance,_that.topExpenseCategories,_that.topIncomeCategories);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsOverview extends AnalyticsOverview {
  const _AnalyticsOverview({required this.totalIncome, required this.totalExpense, required this.netBalance, required final  List<AnalyticsCategoryBreakdown> topExpenseCategories, required final  List<AnalyticsCategoryBreakdown> topIncomeCategories}): _topExpenseCategories = topExpenseCategories,_topIncomeCategories = topIncomeCategories,super._();
  

@override final  MoneyAmount totalIncome;
@override final  MoneyAmount totalExpense;
@override final  MoneyAmount netBalance;
 final  List<AnalyticsCategoryBreakdown> _topExpenseCategories;
@override List<AnalyticsCategoryBreakdown> get topExpenseCategories {
  if (_topExpenseCategories is EqualUnmodifiableListView) return _topExpenseCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topExpenseCategories);
}

 final  List<AnalyticsCategoryBreakdown> _topIncomeCategories;
@override List<AnalyticsCategoryBreakdown> get topIncomeCategories {
  if (_topIncomeCategories is EqualUnmodifiableListView) return _topIncomeCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topIncomeCategories);
}


/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsOverviewCopyWith<_AnalyticsOverview> get copyWith => __$AnalyticsOverviewCopyWithImpl<_AnalyticsOverview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsOverview&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.netBalance, netBalance) || other.netBalance == netBalance)&&const DeepCollectionEquality().equals(other._topExpenseCategories, _topExpenseCategories)&&const DeepCollectionEquality().equals(other._topIncomeCategories, _topIncomeCategories));
}


@override
int get hashCode => Object.hash(runtimeType,totalIncome,totalExpense,netBalance,const DeepCollectionEquality().hash(_topExpenseCategories),const DeepCollectionEquality().hash(_topIncomeCategories));

@override
String toString() {
  return 'AnalyticsOverview(totalIncome: $totalIncome, totalExpense: $totalExpense, netBalance: $netBalance, topExpenseCategories: $topExpenseCategories, topIncomeCategories: $topIncomeCategories)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsOverviewCopyWith<$Res> implements $AnalyticsOverviewCopyWith<$Res> {
  factory _$AnalyticsOverviewCopyWith(_AnalyticsOverview value, $Res Function(_AnalyticsOverview) _then) = __$AnalyticsOverviewCopyWithImpl;
@override @useResult
$Res call({
 MoneyAmount totalIncome, MoneyAmount totalExpense, MoneyAmount netBalance, List<AnalyticsCategoryBreakdown> topExpenseCategories, List<AnalyticsCategoryBreakdown> topIncomeCategories
});




}
/// @nodoc
class __$AnalyticsOverviewCopyWithImpl<$Res>
    implements _$AnalyticsOverviewCopyWith<$Res> {
  __$AnalyticsOverviewCopyWithImpl(this._self, this._then);

  final _AnalyticsOverview _self;
  final $Res Function(_AnalyticsOverview) _then;

/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalIncome = null,Object? totalExpense = null,Object? netBalance = null,Object? topExpenseCategories = null,Object? topIncomeCategories = null,}) {
  return _then(_AnalyticsOverview(
totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as MoneyAmount,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as MoneyAmount,netBalance: null == netBalance ? _self.netBalance : netBalance // ignore: cast_nullable_to_non_nullable
as MoneyAmount,topExpenseCategories: null == topExpenseCategories ? _self._topExpenseCategories : topExpenseCategories // ignore: cast_nullable_to_non_nullable
as List<AnalyticsCategoryBreakdown>,topIncomeCategories: null == topIncomeCategories ? _self._topIncomeCategories : topIncomeCategories // ignore: cast_nullable_to_non_nullable
as List<AnalyticsCategoryBreakdown>,
  ));
}


}

// dart format on
