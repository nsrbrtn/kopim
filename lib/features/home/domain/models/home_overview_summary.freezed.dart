// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_overview_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeTopExpenseCategory {

 String? get categoryId; double get amount;
/// Create a copy of HomeTopExpenseCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeTopExpenseCategoryCopyWith<HomeTopExpenseCategory> get copyWith => _$HomeTopExpenseCategoryCopyWithImpl<HomeTopExpenseCategory>(this as HomeTopExpenseCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeTopExpenseCategory&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,amount);

@override
String toString() {
  return 'HomeTopExpenseCategory(categoryId: $categoryId, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $HomeTopExpenseCategoryCopyWith<$Res>  {
  factory $HomeTopExpenseCategoryCopyWith(HomeTopExpenseCategory value, $Res Function(HomeTopExpenseCategory) _then) = _$HomeTopExpenseCategoryCopyWithImpl;
@useResult
$Res call({
 String? categoryId, double amount
});




}
/// @nodoc
class _$HomeTopExpenseCategoryCopyWithImpl<$Res>
    implements $HomeTopExpenseCategoryCopyWith<$Res> {
  _$HomeTopExpenseCategoryCopyWithImpl(this._self, this._then);

  final HomeTopExpenseCategory _self;
  final $Res Function(HomeTopExpenseCategory) _then;

/// Create a copy of HomeTopExpenseCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = freezed,Object? amount = null,}) {
  return _then(_self.copyWith(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeTopExpenseCategory].
extension HomeTopExpenseCategoryPatterns on HomeTopExpenseCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeTopExpenseCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeTopExpenseCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeTopExpenseCategory value)  $default,){
final _that = this;
switch (_that) {
case _HomeTopExpenseCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeTopExpenseCategory value)?  $default,){
final _that = this;
switch (_that) {
case _HomeTopExpenseCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? categoryId,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeTopExpenseCategory() when $default != null:
return $default(_that.categoryId,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? categoryId,  double amount)  $default,) {final _that = this;
switch (_that) {
case _HomeTopExpenseCategory():
return $default(_that.categoryId,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? categoryId,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _HomeTopExpenseCategory() when $default != null:
return $default(_that.categoryId,_that.amount);case _:
  return null;

}
}

}

/// @nodoc


class _HomeTopExpenseCategory implements HomeTopExpenseCategory {
  const _HomeTopExpenseCategory({required this.categoryId, required this.amount});
  

@override final  String? categoryId;
@override final  double amount;

/// Create a copy of HomeTopExpenseCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeTopExpenseCategoryCopyWith<_HomeTopExpenseCategory> get copyWith => __$HomeTopExpenseCategoryCopyWithImpl<_HomeTopExpenseCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeTopExpenseCategory&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,amount);

@override
String toString() {
  return 'HomeTopExpenseCategory(categoryId: $categoryId, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$HomeTopExpenseCategoryCopyWith<$Res> implements $HomeTopExpenseCategoryCopyWith<$Res> {
  factory _$HomeTopExpenseCategoryCopyWith(_HomeTopExpenseCategory value, $Res Function(_HomeTopExpenseCategory) _then) = __$HomeTopExpenseCategoryCopyWithImpl;
@override @useResult
$Res call({
 String? categoryId, double amount
});




}
/// @nodoc
class __$HomeTopExpenseCategoryCopyWithImpl<$Res>
    implements _$HomeTopExpenseCategoryCopyWith<$Res> {
  __$HomeTopExpenseCategoryCopyWithImpl(this._self, this._then);

  final _HomeTopExpenseCategory _self;
  final $Res Function(_HomeTopExpenseCategory) _then;

/// Create a copy of HomeTopExpenseCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = freezed,Object? amount = null,}) {
  return _then(_HomeTopExpenseCategory(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$HomeOverviewSummary {

 double get totalBalance; double get todayIncome; double get todayExpense; HomeTopExpenseCategory? get topExpenseCategory;
/// Create a copy of HomeOverviewSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeOverviewSummaryCopyWith<HomeOverviewSummary> get copyWith => _$HomeOverviewSummaryCopyWithImpl<HomeOverviewSummary>(this as HomeOverviewSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeOverviewSummary&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance)&&(identical(other.todayIncome, todayIncome) || other.todayIncome == todayIncome)&&(identical(other.todayExpense, todayExpense) || other.todayExpense == todayExpense)&&(identical(other.topExpenseCategory, topExpenseCategory) || other.topExpenseCategory == topExpenseCategory));
}


@override
int get hashCode => Object.hash(runtimeType,totalBalance,todayIncome,todayExpense,topExpenseCategory);

@override
String toString() {
  return 'HomeOverviewSummary(totalBalance: $totalBalance, todayIncome: $todayIncome, todayExpense: $todayExpense, topExpenseCategory: $topExpenseCategory)';
}


}

/// @nodoc
abstract mixin class $HomeOverviewSummaryCopyWith<$Res>  {
  factory $HomeOverviewSummaryCopyWith(HomeOverviewSummary value, $Res Function(HomeOverviewSummary) _then) = _$HomeOverviewSummaryCopyWithImpl;
@useResult
$Res call({
 double totalBalance, double todayIncome, double todayExpense, HomeTopExpenseCategory? topExpenseCategory
});


$HomeTopExpenseCategoryCopyWith<$Res>? get topExpenseCategory;

}
/// @nodoc
class _$HomeOverviewSummaryCopyWithImpl<$Res>
    implements $HomeOverviewSummaryCopyWith<$Res> {
  _$HomeOverviewSummaryCopyWithImpl(this._self, this._then);

  final HomeOverviewSummary _self;
  final $Res Function(HomeOverviewSummary) _then;

/// Create a copy of HomeOverviewSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalBalance = null,Object? todayIncome = null,Object? todayExpense = null,Object? topExpenseCategory = freezed,}) {
  return _then(_self.copyWith(
totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as double,todayIncome: null == todayIncome ? _self.todayIncome : todayIncome // ignore: cast_nullable_to_non_nullable
as double,todayExpense: null == todayExpense ? _self.todayExpense : todayExpense // ignore: cast_nullable_to_non_nullable
as double,topExpenseCategory: freezed == topExpenseCategory ? _self.topExpenseCategory : topExpenseCategory // ignore: cast_nullable_to_non_nullable
as HomeTopExpenseCategory?,
  ));
}
/// Create a copy of HomeOverviewSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeTopExpenseCategoryCopyWith<$Res>? get topExpenseCategory {
    if (_self.topExpenseCategory == null) {
    return null;
  }

  return $HomeTopExpenseCategoryCopyWith<$Res>(_self.topExpenseCategory!, (value) {
    return _then(_self.copyWith(topExpenseCategory: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeOverviewSummary].
extension HomeOverviewSummaryPatterns on HomeOverviewSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeOverviewSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeOverviewSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeOverviewSummary value)  $default,){
final _that = this;
switch (_that) {
case _HomeOverviewSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeOverviewSummary value)?  $default,){
final _that = this;
switch (_that) {
case _HomeOverviewSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalBalance,  double todayIncome,  double todayExpense,  HomeTopExpenseCategory? topExpenseCategory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeOverviewSummary() when $default != null:
return $default(_that.totalBalance,_that.todayIncome,_that.todayExpense,_that.topExpenseCategory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalBalance,  double todayIncome,  double todayExpense,  HomeTopExpenseCategory? topExpenseCategory)  $default,) {final _that = this;
switch (_that) {
case _HomeOverviewSummary():
return $default(_that.totalBalance,_that.todayIncome,_that.todayExpense,_that.topExpenseCategory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalBalance,  double todayIncome,  double todayExpense,  HomeTopExpenseCategory? topExpenseCategory)?  $default,) {final _that = this;
switch (_that) {
case _HomeOverviewSummary() when $default != null:
return $default(_that.totalBalance,_that.todayIncome,_that.todayExpense,_that.topExpenseCategory);case _:
  return null;

}
}

}

/// @nodoc


class _HomeOverviewSummary implements HomeOverviewSummary {
  const _HomeOverviewSummary({required this.totalBalance, required this.todayIncome, required this.todayExpense, this.topExpenseCategory});
  

@override final  double totalBalance;
@override final  double todayIncome;
@override final  double todayExpense;
@override final  HomeTopExpenseCategory? topExpenseCategory;

/// Create a copy of HomeOverviewSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeOverviewSummaryCopyWith<_HomeOverviewSummary> get copyWith => __$HomeOverviewSummaryCopyWithImpl<_HomeOverviewSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeOverviewSummary&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance)&&(identical(other.todayIncome, todayIncome) || other.todayIncome == todayIncome)&&(identical(other.todayExpense, todayExpense) || other.todayExpense == todayExpense)&&(identical(other.topExpenseCategory, topExpenseCategory) || other.topExpenseCategory == topExpenseCategory));
}


@override
int get hashCode => Object.hash(runtimeType,totalBalance,todayIncome,todayExpense,topExpenseCategory);

@override
String toString() {
  return 'HomeOverviewSummary(totalBalance: $totalBalance, todayIncome: $todayIncome, todayExpense: $todayExpense, topExpenseCategory: $topExpenseCategory)';
}


}

/// @nodoc
abstract mixin class _$HomeOverviewSummaryCopyWith<$Res> implements $HomeOverviewSummaryCopyWith<$Res> {
  factory _$HomeOverviewSummaryCopyWith(_HomeOverviewSummary value, $Res Function(_HomeOverviewSummary) _then) = __$HomeOverviewSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalBalance, double todayIncome, double todayExpense, HomeTopExpenseCategory? topExpenseCategory
});


@override $HomeTopExpenseCategoryCopyWith<$Res>? get topExpenseCategory;

}
/// @nodoc
class __$HomeOverviewSummaryCopyWithImpl<$Res>
    implements _$HomeOverviewSummaryCopyWith<$Res> {
  __$HomeOverviewSummaryCopyWithImpl(this._self, this._then);

  final _HomeOverviewSummary _self;
  final $Res Function(_HomeOverviewSummary) _then;

/// Create a copy of HomeOverviewSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalBalance = null,Object? todayIncome = null,Object? todayExpense = null,Object? topExpenseCategory = freezed,}) {
  return _then(_HomeOverviewSummary(
totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as double,todayIncome: null == todayIncome ? _self.todayIncome : todayIncome // ignore: cast_nullable_to_non_nullable
as double,todayExpense: null == todayExpense ? _self.todayExpense : todayExpense // ignore: cast_nullable_to_non_nullable
as double,topExpenseCategory: freezed == topExpenseCategory ? _self.topExpenseCategory : topExpenseCategory // ignore: cast_nullable_to_non_nullable
as HomeTopExpenseCategory?,
  ));
}

/// Create a copy of HomeOverviewSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeTopExpenseCategoryCopyWith<$Res>? get topExpenseCategory {
    if (_self.topExpenseCategory == null) {
    return null;
  }

  return $HomeTopExpenseCategoryCopyWith<$Res>(_self.topExpenseCategory!, (value) {
    return _then(_self.copyWith(topExpenseCategory: value));
  });
}
}

// dart format on
