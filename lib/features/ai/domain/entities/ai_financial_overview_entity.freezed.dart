// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_financial_overview_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiDataFilter {

 DateTime? get startDate; DateTime? get endDate; List<String> get accountIds; List<String> get categoryIds; int get topCategoriesLimit;
/// Create a copy of AiDataFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiDataFilterCopyWith<AiDataFilter> get copyWith => _$AiDataFilterCopyWithImpl<AiDataFilter>(this as AiDataFilter, _$identity);

  /// Serializes this AiDataFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiDataFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.accountIds, accountIds)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&(identical(other.topCategoriesLimit, topCategoriesLimit) || other.topCategoriesLimit == topCategoriesLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(accountIds),const DeepCollectionEquality().hash(categoryIds),topCategoriesLimit);

@override
String toString() {
  return 'AiDataFilter(startDate: $startDate, endDate: $endDate, accountIds: $accountIds, categoryIds: $categoryIds, topCategoriesLimit: $topCategoriesLimit)';
}


}

/// @nodoc
abstract mixin class $AiDataFilterCopyWith<$Res>  {
  factory $AiDataFilterCopyWith(AiDataFilter value, $Res Function(AiDataFilter) _then) = _$AiDataFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<String> accountIds, List<String> categoryIds, int topCategoriesLimit
});




}
/// @nodoc
class _$AiDataFilterCopyWithImpl<$Res>
    implements $AiDataFilterCopyWith<$Res> {
  _$AiDataFilterCopyWithImpl(this._self, this._then);

  final AiDataFilter _self;
  final $Res Function(AiDataFilter) _then;

/// Create a copy of AiDataFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? accountIds = null,Object? categoryIds = null,Object? topCategoriesLimit = null,}) {
  return _then(_self.copyWith(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,accountIds: null == accountIds ? _self.accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as List<String>,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,topCategoriesLimit: null == topCategoriesLimit ? _self.topCategoriesLimit : topCategoriesLimit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AiDataFilter].
extension AiDataFilterPatterns on AiDataFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiDataFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiDataFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiDataFilter value)  $default,){
final _that = this;
switch (_that) {
case _AiDataFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiDataFilter value)?  $default,){
final _that = this;
switch (_that) {
case _AiDataFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<String> accountIds,  List<String> categoryIds,  int topCategoriesLimit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiDataFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.accountIds,_that.categoryIds,_that.topCategoriesLimit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<String> accountIds,  List<String> categoryIds,  int topCategoriesLimit)  $default,) {final _that = this;
switch (_that) {
case _AiDataFilter():
return $default(_that.startDate,_that.endDate,_that.accountIds,_that.categoryIds,_that.topCategoriesLimit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startDate,  DateTime? endDate,  List<String> accountIds,  List<String> categoryIds,  int topCategoriesLimit)?  $default,) {final _that = this;
switch (_that) {
case _AiDataFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.accountIds,_that.categoryIds,_that.topCategoriesLimit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiDataFilter extends AiDataFilter {
  const _AiDataFilter({this.startDate, this.endDate, final  List<String> accountIds = const <String>[], final  List<String> categoryIds = const <String>[], this.topCategoriesLimit = 5}): _accountIds = accountIds,_categoryIds = categoryIds,super._();
  factory _AiDataFilter.fromJson(Map<String, dynamic> json) => _$AiDataFilterFromJson(json);

@override final  DateTime? startDate;
@override final  DateTime? endDate;
 final  List<String> _accountIds;
@override@JsonKey() List<String> get accountIds {
  if (_accountIds is EqualUnmodifiableListView) return _accountIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accountIds);
}

 final  List<String> _categoryIds;
@override@JsonKey() List<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryIds);
}

@override@JsonKey() final  int topCategoriesLimit;

/// Create a copy of AiDataFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiDataFilterCopyWith<_AiDataFilter> get copyWith => __$AiDataFilterCopyWithImpl<_AiDataFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiDataFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiDataFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._accountIds, _accountIds)&&const DeepCollectionEquality().equals(other._categoryIds, _categoryIds)&&(identical(other.topCategoriesLimit, topCategoriesLimit) || other.topCategoriesLimit == topCategoriesLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_accountIds),const DeepCollectionEquality().hash(_categoryIds),topCategoriesLimit);

@override
String toString() {
  return 'AiDataFilter(startDate: $startDate, endDate: $endDate, accountIds: $accountIds, categoryIds: $categoryIds, topCategoriesLimit: $topCategoriesLimit)';
}


}

/// @nodoc
abstract mixin class _$AiDataFilterCopyWith<$Res> implements $AiDataFilterCopyWith<$Res> {
  factory _$AiDataFilterCopyWith(_AiDataFilter value, $Res Function(_AiDataFilter) _then) = __$AiDataFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<String> accountIds, List<String> categoryIds, int topCategoriesLimit
});




}
/// @nodoc
class __$AiDataFilterCopyWithImpl<$Res>
    implements _$AiDataFilterCopyWith<$Res> {
  __$AiDataFilterCopyWithImpl(this._self, this._then);

  final _AiDataFilter _self;
  final $Res Function(_AiDataFilter) _then;

/// Create a copy of AiDataFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? accountIds = null,Object? categoryIds = null,Object? topCategoriesLimit = null,}) {
  return _then(_AiDataFilter(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,accountIds: null == accountIds ? _self._accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as List<String>,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,topCategoriesLimit: null == topCategoriesLimit ? _self.topCategoriesLimit : topCategoriesLimit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MonthlyExpenseInsight {

 DateTime get month; double get totalExpense;
/// Create a copy of MonthlyExpenseInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyExpenseInsightCopyWith<MonthlyExpenseInsight> get copyWith => _$MonthlyExpenseInsightCopyWithImpl<MonthlyExpenseInsight>(this as MonthlyExpenseInsight, _$identity);

  /// Serializes this MonthlyExpenseInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyExpenseInsight&&(identical(other.month, month) || other.month == month)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,totalExpense);

@override
String toString() {
  return 'MonthlyExpenseInsight(month: $month, totalExpense: $totalExpense)';
}


}

/// @nodoc
abstract mixin class $MonthlyExpenseInsightCopyWith<$Res>  {
  factory $MonthlyExpenseInsightCopyWith(MonthlyExpenseInsight value, $Res Function(MonthlyExpenseInsight) _then) = _$MonthlyExpenseInsightCopyWithImpl;
@useResult
$Res call({
 DateTime month, double totalExpense
});




}
/// @nodoc
class _$MonthlyExpenseInsightCopyWithImpl<$Res>
    implements $MonthlyExpenseInsightCopyWith<$Res> {
  _$MonthlyExpenseInsightCopyWithImpl(this._self, this._then);

  final MonthlyExpenseInsight _self;
  final $Res Function(MonthlyExpenseInsight) _then;

/// Create a copy of MonthlyExpenseInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? totalExpense = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyExpenseInsight].
extension MonthlyExpenseInsightPatterns on MonthlyExpenseInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyExpenseInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyExpenseInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyExpenseInsight value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyExpenseInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyExpenseInsight value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyExpenseInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime month,  double totalExpense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyExpenseInsight() when $default != null:
return $default(_that.month,_that.totalExpense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime month,  double totalExpense)  $default,) {final _that = this;
switch (_that) {
case _MonthlyExpenseInsight():
return $default(_that.month,_that.totalExpense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime month,  double totalExpense)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyExpenseInsight() when $default != null:
return $default(_that.month,_that.totalExpense);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyExpenseInsight extends MonthlyExpenseInsight {
  const _MonthlyExpenseInsight({required this.month, required this.totalExpense}): super._();
  factory _MonthlyExpenseInsight.fromJson(Map<String, dynamic> json) => _$MonthlyExpenseInsightFromJson(json);

@override final  DateTime month;
@override final  double totalExpense;

/// Create a copy of MonthlyExpenseInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyExpenseInsightCopyWith<_MonthlyExpenseInsight> get copyWith => __$MonthlyExpenseInsightCopyWithImpl<_MonthlyExpenseInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyExpenseInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyExpenseInsight&&(identical(other.month, month) || other.month == month)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,totalExpense);

@override
String toString() {
  return 'MonthlyExpenseInsight(month: $month, totalExpense: $totalExpense)';
}


}

/// @nodoc
abstract mixin class _$MonthlyExpenseInsightCopyWith<$Res> implements $MonthlyExpenseInsightCopyWith<$Res> {
  factory _$MonthlyExpenseInsightCopyWith(_MonthlyExpenseInsight value, $Res Function(_MonthlyExpenseInsight) _then) = __$MonthlyExpenseInsightCopyWithImpl;
@override @useResult
$Res call({
 DateTime month, double totalExpense
});




}
/// @nodoc
class __$MonthlyExpenseInsightCopyWithImpl<$Res>
    implements _$MonthlyExpenseInsightCopyWith<$Res> {
  __$MonthlyExpenseInsightCopyWithImpl(this._self, this._then);

  final _MonthlyExpenseInsight _self;
  final $Res Function(_MonthlyExpenseInsight) _then;

/// Create a copy of MonthlyExpenseInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? totalExpense = null,}) {
  return _then(_MonthlyExpenseInsight(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$MonthlyIncomeInsight {

 DateTime get month; double get totalIncome;
/// Create a copy of MonthlyIncomeInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyIncomeInsightCopyWith<MonthlyIncomeInsight> get copyWith => _$MonthlyIncomeInsightCopyWithImpl<MonthlyIncomeInsight>(this as MonthlyIncomeInsight, _$identity);

  /// Serializes this MonthlyIncomeInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyIncomeInsight&&(identical(other.month, month) || other.month == month)&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,totalIncome);

@override
String toString() {
  return 'MonthlyIncomeInsight(month: $month, totalIncome: $totalIncome)';
}


}

/// @nodoc
abstract mixin class $MonthlyIncomeInsightCopyWith<$Res>  {
  factory $MonthlyIncomeInsightCopyWith(MonthlyIncomeInsight value, $Res Function(MonthlyIncomeInsight) _then) = _$MonthlyIncomeInsightCopyWithImpl;
@useResult
$Res call({
 DateTime month, double totalIncome
});




}
/// @nodoc
class _$MonthlyIncomeInsightCopyWithImpl<$Res>
    implements $MonthlyIncomeInsightCopyWith<$Res> {
  _$MonthlyIncomeInsightCopyWithImpl(this._self, this._then);

  final MonthlyIncomeInsight _self;
  final $Res Function(MonthlyIncomeInsight) _then;

/// Create a copy of MonthlyIncomeInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? totalIncome = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyIncomeInsight].
extension MonthlyIncomeInsightPatterns on MonthlyIncomeInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyIncomeInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyIncomeInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyIncomeInsight value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyIncomeInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyIncomeInsight value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyIncomeInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime month,  double totalIncome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyIncomeInsight() when $default != null:
return $default(_that.month,_that.totalIncome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime month,  double totalIncome)  $default,) {final _that = this;
switch (_that) {
case _MonthlyIncomeInsight():
return $default(_that.month,_that.totalIncome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime month,  double totalIncome)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyIncomeInsight() when $default != null:
return $default(_that.month,_that.totalIncome);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyIncomeInsight extends MonthlyIncomeInsight {
  const _MonthlyIncomeInsight({required this.month, required this.totalIncome}): super._();
  factory _MonthlyIncomeInsight.fromJson(Map<String, dynamic> json) => _$MonthlyIncomeInsightFromJson(json);

@override final  DateTime month;
@override final  double totalIncome;

/// Create a copy of MonthlyIncomeInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyIncomeInsightCopyWith<_MonthlyIncomeInsight> get copyWith => __$MonthlyIncomeInsightCopyWithImpl<_MonthlyIncomeInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyIncomeInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyIncomeInsight&&(identical(other.month, month) || other.month == month)&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,totalIncome);

@override
String toString() {
  return 'MonthlyIncomeInsight(month: $month, totalIncome: $totalIncome)';
}


}

/// @nodoc
abstract mixin class _$MonthlyIncomeInsightCopyWith<$Res> implements $MonthlyIncomeInsightCopyWith<$Res> {
  factory _$MonthlyIncomeInsightCopyWith(_MonthlyIncomeInsight value, $Res Function(_MonthlyIncomeInsight) _then) = __$MonthlyIncomeInsightCopyWithImpl;
@override @useResult
$Res call({
 DateTime month, double totalIncome
});




}
/// @nodoc
class __$MonthlyIncomeInsightCopyWithImpl<$Res>
    implements _$MonthlyIncomeInsightCopyWith<$Res> {
  __$MonthlyIncomeInsightCopyWithImpl(this._self, this._then);

  final _MonthlyIncomeInsight _self;
  final $Res Function(_MonthlyIncomeInsight) _then;

/// Create a copy of MonthlyIncomeInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? totalIncome = null,}) {
  return _then(_MonthlyIncomeInsight(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$CategoryExpenseInsight {

 String? get categoryId; String get displayName; double get totalExpense; String? get color;
/// Create a copy of CategoryExpenseInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryExpenseInsightCopyWith<CategoryExpenseInsight> get copyWith => _$CategoryExpenseInsightCopyWithImpl<CategoryExpenseInsight>(this as CategoryExpenseInsight, _$identity);

  /// Serializes this CategoryExpenseInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryExpenseInsight&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,displayName,totalExpense,color);

@override
String toString() {
  return 'CategoryExpenseInsight(categoryId: $categoryId, displayName: $displayName, totalExpense: $totalExpense, color: $color)';
}


}

/// @nodoc
abstract mixin class $CategoryExpenseInsightCopyWith<$Res>  {
  factory $CategoryExpenseInsightCopyWith(CategoryExpenseInsight value, $Res Function(CategoryExpenseInsight) _then) = _$CategoryExpenseInsightCopyWithImpl;
@useResult
$Res call({
 String? categoryId, String displayName, double totalExpense, String? color
});




}
/// @nodoc
class _$CategoryExpenseInsightCopyWithImpl<$Res>
    implements $CategoryExpenseInsightCopyWith<$Res> {
  _$CategoryExpenseInsightCopyWithImpl(this._self, this._then);

  final CategoryExpenseInsight _self;
  final $Res Function(CategoryExpenseInsight) _then;

/// Create a copy of CategoryExpenseInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = freezed,Object? displayName = null,Object? totalExpense = null,Object? color = freezed,}) {
  return _then(_self.copyWith(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryExpenseInsight].
extension CategoryExpenseInsightPatterns on CategoryExpenseInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryExpenseInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryExpenseInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryExpenseInsight value)  $default,){
final _that = this;
switch (_that) {
case _CategoryExpenseInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryExpenseInsight value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryExpenseInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? categoryId,  String displayName,  double totalExpense,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryExpenseInsight() when $default != null:
return $default(_that.categoryId,_that.displayName,_that.totalExpense,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? categoryId,  String displayName,  double totalExpense,  String? color)  $default,) {final _that = this;
switch (_that) {
case _CategoryExpenseInsight():
return $default(_that.categoryId,_that.displayName,_that.totalExpense,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? categoryId,  String displayName,  double totalExpense,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _CategoryExpenseInsight() when $default != null:
return $default(_that.categoryId,_that.displayName,_that.totalExpense,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryExpenseInsight extends CategoryExpenseInsight {
  const _CategoryExpenseInsight({this.categoryId, required this.displayName, required this.totalExpense, this.color}): super._();
  factory _CategoryExpenseInsight.fromJson(Map<String, dynamic> json) => _$CategoryExpenseInsightFromJson(json);

@override final  String? categoryId;
@override final  String displayName;
@override final  double totalExpense;
@override final  String? color;

/// Create a copy of CategoryExpenseInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryExpenseInsightCopyWith<_CategoryExpenseInsight> get copyWith => __$CategoryExpenseInsightCopyWithImpl<_CategoryExpenseInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryExpenseInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryExpenseInsight&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,displayName,totalExpense,color);

@override
String toString() {
  return 'CategoryExpenseInsight(categoryId: $categoryId, displayName: $displayName, totalExpense: $totalExpense, color: $color)';
}


}

/// @nodoc
abstract mixin class _$CategoryExpenseInsightCopyWith<$Res> implements $CategoryExpenseInsightCopyWith<$Res> {
  factory _$CategoryExpenseInsightCopyWith(_CategoryExpenseInsight value, $Res Function(_CategoryExpenseInsight) _then) = __$CategoryExpenseInsightCopyWithImpl;
@override @useResult
$Res call({
 String? categoryId, String displayName, double totalExpense, String? color
});




}
/// @nodoc
class __$CategoryExpenseInsightCopyWithImpl<$Res>
    implements _$CategoryExpenseInsightCopyWith<$Res> {
  __$CategoryExpenseInsightCopyWithImpl(this._self, this._then);

  final _CategoryExpenseInsight _self;
  final $Res Function(_CategoryExpenseInsight) _then;

/// Create a copy of CategoryExpenseInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = freezed,Object? displayName = null,Object? totalExpense = null,Object? color = freezed,}) {
  return _then(_CategoryExpenseInsight(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CategoryIncomeInsight {

 String? get categoryId; String get displayName; double get totalIncome; String? get color;
/// Create a copy of CategoryIncomeInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryIncomeInsightCopyWith<CategoryIncomeInsight> get copyWith => _$CategoryIncomeInsightCopyWithImpl<CategoryIncomeInsight>(this as CategoryIncomeInsight, _$identity);

  /// Serializes this CategoryIncomeInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryIncomeInsight&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,displayName,totalIncome,color);

@override
String toString() {
  return 'CategoryIncomeInsight(categoryId: $categoryId, displayName: $displayName, totalIncome: $totalIncome, color: $color)';
}


}

/// @nodoc
abstract mixin class $CategoryIncomeInsightCopyWith<$Res>  {
  factory $CategoryIncomeInsightCopyWith(CategoryIncomeInsight value, $Res Function(CategoryIncomeInsight) _then) = _$CategoryIncomeInsightCopyWithImpl;
@useResult
$Res call({
 String? categoryId, String displayName, double totalIncome, String? color
});




}
/// @nodoc
class _$CategoryIncomeInsightCopyWithImpl<$Res>
    implements $CategoryIncomeInsightCopyWith<$Res> {
  _$CategoryIncomeInsightCopyWithImpl(this._self, this._then);

  final CategoryIncomeInsight _self;
  final $Res Function(CategoryIncomeInsight) _then;

/// Create a copy of CategoryIncomeInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = freezed,Object? displayName = null,Object? totalIncome = null,Object? color = freezed,}) {
  return _then(_self.copyWith(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryIncomeInsight].
extension CategoryIncomeInsightPatterns on CategoryIncomeInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryIncomeInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryIncomeInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryIncomeInsight value)  $default,){
final _that = this;
switch (_that) {
case _CategoryIncomeInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryIncomeInsight value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryIncomeInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? categoryId,  String displayName,  double totalIncome,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryIncomeInsight() when $default != null:
return $default(_that.categoryId,_that.displayName,_that.totalIncome,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? categoryId,  String displayName,  double totalIncome,  String? color)  $default,) {final _that = this;
switch (_that) {
case _CategoryIncomeInsight():
return $default(_that.categoryId,_that.displayName,_that.totalIncome,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? categoryId,  String displayName,  double totalIncome,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _CategoryIncomeInsight() when $default != null:
return $default(_that.categoryId,_that.displayName,_that.totalIncome,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryIncomeInsight extends CategoryIncomeInsight {
  const _CategoryIncomeInsight({this.categoryId, required this.displayName, required this.totalIncome, this.color}): super._();
  factory _CategoryIncomeInsight.fromJson(Map<String, dynamic> json) => _$CategoryIncomeInsightFromJson(json);

@override final  String? categoryId;
@override final  String displayName;
@override final  double totalIncome;
@override final  String? color;

/// Create a copy of CategoryIncomeInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryIncomeInsightCopyWith<_CategoryIncomeInsight> get copyWith => __$CategoryIncomeInsightCopyWithImpl<_CategoryIncomeInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryIncomeInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryIncomeInsight&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,displayName,totalIncome,color);

@override
String toString() {
  return 'CategoryIncomeInsight(categoryId: $categoryId, displayName: $displayName, totalIncome: $totalIncome, color: $color)';
}


}

/// @nodoc
abstract mixin class _$CategoryIncomeInsightCopyWith<$Res> implements $CategoryIncomeInsightCopyWith<$Res> {
  factory _$CategoryIncomeInsightCopyWith(_CategoryIncomeInsight value, $Res Function(_CategoryIncomeInsight) _then) = __$CategoryIncomeInsightCopyWithImpl;
@override @useResult
$Res call({
 String? categoryId, String displayName, double totalIncome, String? color
});




}
/// @nodoc
class __$CategoryIncomeInsightCopyWithImpl<$Res>
    implements _$CategoryIncomeInsightCopyWith<$Res> {
  __$CategoryIncomeInsightCopyWithImpl(this._self, this._then);

  final _CategoryIncomeInsight _self;
  final $Res Function(_CategoryIncomeInsight) _then;

/// Create a copy of CategoryIncomeInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = freezed,Object? displayName = null,Object? totalIncome = null,Object? color = freezed,}) {
  return _then(_CategoryIncomeInsight(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BudgetForecastInsight {

 String get budgetId; String get title; DateTime get periodStart; DateTime get periodEnd; double get allocated; double get spent; double get projectedSpent; double get remaining; double get completionRate; BudgetForecastStatus get status; List<String> get categoryNames; List<String> get accountIds;
/// Create a copy of BudgetForecastInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetForecastInsightCopyWith<BudgetForecastInsight> get copyWith => _$BudgetForecastInsightCopyWithImpl<BudgetForecastInsight>(this as BudgetForecastInsight, _$identity);

  /// Serializes this BudgetForecastInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetForecastInsight&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId)&&(identical(other.title, title) || other.title == title)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.allocated, allocated) || other.allocated == allocated)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.projectedSpent, projectedSpent) || other.projectedSpent == projectedSpent)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.categoryNames, categoryNames)&&const DeepCollectionEquality().equals(other.accountIds, accountIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,budgetId,title,periodStart,periodEnd,allocated,spent,projectedSpent,remaining,completionRate,status,const DeepCollectionEquality().hash(categoryNames),const DeepCollectionEquality().hash(accountIds));

@override
String toString() {
  return 'BudgetForecastInsight(budgetId: $budgetId, title: $title, periodStart: $periodStart, periodEnd: $periodEnd, allocated: $allocated, spent: $spent, projectedSpent: $projectedSpent, remaining: $remaining, completionRate: $completionRate, status: $status, categoryNames: $categoryNames, accountIds: $accountIds)';
}


}

/// @nodoc
abstract mixin class $BudgetForecastInsightCopyWith<$Res>  {
  factory $BudgetForecastInsightCopyWith(BudgetForecastInsight value, $Res Function(BudgetForecastInsight) _then) = _$BudgetForecastInsightCopyWithImpl;
@useResult
$Res call({
 String budgetId, String title, DateTime periodStart, DateTime periodEnd, double allocated, double spent, double projectedSpent, double remaining, double completionRate, BudgetForecastStatus status, List<String> categoryNames, List<String> accountIds
});




}
/// @nodoc
class _$BudgetForecastInsightCopyWithImpl<$Res>
    implements $BudgetForecastInsightCopyWith<$Res> {
  _$BudgetForecastInsightCopyWithImpl(this._self, this._then);

  final BudgetForecastInsight _self;
  final $Res Function(BudgetForecastInsight) _then;

/// Create a copy of BudgetForecastInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? budgetId = null,Object? title = null,Object? periodStart = null,Object? periodEnd = null,Object? allocated = null,Object? spent = null,Object? projectedSpent = null,Object? remaining = null,Object? completionRate = null,Object? status = null,Object? categoryNames = null,Object? accountIds = null,}) {
  return _then(_self.copyWith(
budgetId: null == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,allocated: null == allocated ? _self.allocated : allocated // ignore: cast_nullable_to_non_nullable
as double,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,projectedSpent: null == projectedSpent ? _self.projectedSpent : projectedSpent // ignore: cast_nullable_to_non_nullable
as double,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as double,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetForecastStatus,categoryNames: null == categoryNames ? _self.categoryNames : categoryNames // ignore: cast_nullable_to_non_nullable
as List<String>,accountIds: null == accountIds ? _self.accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetForecastInsight].
extension BudgetForecastInsightPatterns on BudgetForecastInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetForecastInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetForecastInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetForecastInsight value)  $default,){
final _that = this;
switch (_that) {
case _BudgetForecastInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetForecastInsight value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetForecastInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String budgetId,  String title,  DateTime periodStart,  DateTime periodEnd,  double allocated,  double spent,  double projectedSpent,  double remaining,  double completionRate,  BudgetForecastStatus status,  List<String> categoryNames,  List<String> accountIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetForecastInsight() when $default != null:
return $default(_that.budgetId,_that.title,_that.periodStart,_that.periodEnd,_that.allocated,_that.spent,_that.projectedSpent,_that.remaining,_that.completionRate,_that.status,_that.categoryNames,_that.accountIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String budgetId,  String title,  DateTime periodStart,  DateTime periodEnd,  double allocated,  double spent,  double projectedSpent,  double remaining,  double completionRate,  BudgetForecastStatus status,  List<String> categoryNames,  List<String> accountIds)  $default,) {final _that = this;
switch (_that) {
case _BudgetForecastInsight():
return $default(_that.budgetId,_that.title,_that.periodStart,_that.periodEnd,_that.allocated,_that.spent,_that.projectedSpent,_that.remaining,_that.completionRate,_that.status,_that.categoryNames,_that.accountIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String budgetId,  String title,  DateTime periodStart,  DateTime periodEnd,  double allocated,  double spent,  double projectedSpent,  double remaining,  double completionRate,  BudgetForecastStatus status,  List<String> categoryNames,  List<String> accountIds)?  $default,) {final _that = this;
switch (_that) {
case _BudgetForecastInsight() when $default != null:
return $default(_that.budgetId,_that.title,_that.periodStart,_that.periodEnd,_that.allocated,_that.spent,_that.projectedSpent,_that.remaining,_that.completionRate,_that.status,_that.categoryNames,_that.accountIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetForecastInsight extends BudgetForecastInsight {
  const _BudgetForecastInsight({required this.budgetId, required this.title, required this.periodStart, required this.periodEnd, required this.allocated, required this.spent, required this.projectedSpent, required this.remaining, required this.completionRate, required this.status, final  List<String> categoryNames = const <String>[], final  List<String> accountIds = const <String>[]}): _categoryNames = categoryNames,_accountIds = accountIds,super._();
  factory _BudgetForecastInsight.fromJson(Map<String, dynamic> json) => _$BudgetForecastInsightFromJson(json);

@override final  String budgetId;
@override final  String title;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  double allocated;
@override final  double spent;
@override final  double projectedSpent;
@override final  double remaining;
@override final  double completionRate;
@override final  BudgetForecastStatus status;
 final  List<String> _categoryNames;
@override@JsonKey() List<String> get categoryNames {
  if (_categoryNames is EqualUnmodifiableListView) return _categoryNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryNames);
}

 final  List<String> _accountIds;
@override@JsonKey() List<String> get accountIds {
  if (_accountIds is EqualUnmodifiableListView) return _accountIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accountIds);
}


/// Create a copy of BudgetForecastInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetForecastInsightCopyWith<_BudgetForecastInsight> get copyWith => __$BudgetForecastInsightCopyWithImpl<_BudgetForecastInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetForecastInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetForecastInsight&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId)&&(identical(other.title, title) || other.title == title)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.allocated, allocated) || other.allocated == allocated)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.projectedSpent, projectedSpent) || other.projectedSpent == projectedSpent)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._categoryNames, _categoryNames)&&const DeepCollectionEquality().equals(other._accountIds, _accountIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,budgetId,title,periodStart,periodEnd,allocated,spent,projectedSpent,remaining,completionRate,status,const DeepCollectionEquality().hash(_categoryNames),const DeepCollectionEquality().hash(_accountIds));

@override
String toString() {
  return 'BudgetForecastInsight(budgetId: $budgetId, title: $title, periodStart: $periodStart, periodEnd: $periodEnd, allocated: $allocated, spent: $spent, projectedSpent: $projectedSpent, remaining: $remaining, completionRate: $completionRate, status: $status, categoryNames: $categoryNames, accountIds: $accountIds)';
}


}

/// @nodoc
abstract mixin class _$BudgetForecastInsightCopyWith<$Res> implements $BudgetForecastInsightCopyWith<$Res> {
  factory _$BudgetForecastInsightCopyWith(_BudgetForecastInsight value, $Res Function(_BudgetForecastInsight) _then) = __$BudgetForecastInsightCopyWithImpl;
@override @useResult
$Res call({
 String budgetId, String title, DateTime periodStart, DateTime periodEnd, double allocated, double spent, double projectedSpent, double remaining, double completionRate, BudgetForecastStatus status, List<String> categoryNames, List<String> accountIds
});




}
/// @nodoc
class __$BudgetForecastInsightCopyWithImpl<$Res>
    implements _$BudgetForecastInsightCopyWith<$Res> {
  __$BudgetForecastInsightCopyWithImpl(this._self, this._then);

  final _BudgetForecastInsight _self;
  final $Res Function(_BudgetForecastInsight) _then;

/// Create a copy of BudgetForecastInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? budgetId = null,Object? title = null,Object? periodStart = null,Object? periodEnd = null,Object? allocated = null,Object? spent = null,Object? projectedSpent = null,Object? remaining = null,Object? completionRate = null,Object? status = null,Object? categoryNames = null,Object? accountIds = null,}) {
  return _then(_BudgetForecastInsight(
budgetId: null == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,allocated: null == allocated ? _self.allocated : allocated // ignore: cast_nullable_to_non_nullable
as double,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,projectedSpent: null == projectedSpent ? _self.projectedSpent : projectedSpent // ignore: cast_nullable_to_non_nullable
as double,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as double,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetForecastStatus,categoryNames: null == categoryNames ? _self._categoryNames : categoryNames // ignore: cast_nullable_to_non_nullable
as List<String>,accountIds: null == accountIds ? _self._accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$AiFinancialOverview {

 List<MonthlyExpenseInsight> get monthlyExpenses; List<MonthlyIncomeInsight> get monthlyIncomes; List<CategoryExpenseInsight> get topCategories; List<CategoryIncomeInsight> get topIncomeCategories; List<BudgetForecastInsight> get budgetForecasts; DateTime get generatedAt;
/// Create a copy of AiFinancialOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiFinancialOverviewCopyWith<AiFinancialOverview> get copyWith => _$AiFinancialOverviewCopyWithImpl<AiFinancialOverview>(this as AiFinancialOverview, _$identity);

  /// Serializes this AiFinancialOverview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiFinancialOverview&&const DeepCollectionEquality().equals(other.monthlyExpenses, monthlyExpenses)&&const DeepCollectionEquality().equals(other.monthlyIncomes, monthlyIncomes)&&const DeepCollectionEquality().equals(other.topCategories, topCategories)&&const DeepCollectionEquality().equals(other.topIncomeCategories, topIncomeCategories)&&const DeepCollectionEquality().equals(other.budgetForecasts, budgetForecasts)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(monthlyExpenses),const DeepCollectionEquality().hash(monthlyIncomes),const DeepCollectionEquality().hash(topCategories),const DeepCollectionEquality().hash(topIncomeCategories),const DeepCollectionEquality().hash(budgetForecasts),generatedAt);

@override
String toString() {
  return 'AiFinancialOverview(monthlyExpenses: $monthlyExpenses, monthlyIncomes: $monthlyIncomes, topCategories: $topCategories, topIncomeCategories: $topIncomeCategories, budgetForecasts: $budgetForecasts, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class $AiFinancialOverviewCopyWith<$Res>  {
  factory $AiFinancialOverviewCopyWith(AiFinancialOverview value, $Res Function(AiFinancialOverview) _then) = _$AiFinancialOverviewCopyWithImpl;
@useResult
$Res call({
 List<MonthlyExpenseInsight> monthlyExpenses, List<MonthlyIncomeInsight> monthlyIncomes, List<CategoryExpenseInsight> topCategories, List<CategoryIncomeInsight> topIncomeCategories, List<BudgetForecastInsight> budgetForecasts, DateTime generatedAt
});




}
/// @nodoc
class _$AiFinancialOverviewCopyWithImpl<$Res>
    implements $AiFinancialOverviewCopyWith<$Res> {
  _$AiFinancialOverviewCopyWithImpl(this._self, this._then);

  final AiFinancialOverview _self;
  final $Res Function(AiFinancialOverview) _then;

/// Create a copy of AiFinancialOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthlyExpenses = null,Object? monthlyIncomes = null,Object? topCategories = null,Object? topIncomeCategories = null,Object? budgetForecasts = null,Object? generatedAt = null,}) {
  return _then(_self.copyWith(
monthlyExpenses: null == monthlyExpenses ? _self.monthlyExpenses : monthlyExpenses // ignore: cast_nullable_to_non_nullable
as List<MonthlyExpenseInsight>,monthlyIncomes: null == monthlyIncomes ? _self.monthlyIncomes : monthlyIncomes // ignore: cast_nullable_to_non_nullable
as List<MonthlyIncomeInsight>,topCategories: null == topCategories ? _self.topCategories : topCategories // ignore: cast_nullable_to_non_nullable
as List<CategoryExpenseInsight>,topIncomeCategories: null == topIncomeCategories ? _self.topIncomeCategories : topIncomeCategories // ignore: cast_nullable_to_non_nullable
as List<CategoryIncomeInsight>,budgetForecasts: null == budgetForecasts ? _self.budgetForecasts : budgetForecasts // ignore: cast_nullable_to_non_nullable
as List<BudgetForecastInsight>,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AiFinancialOverview].
extension AiFinancialOverviewPatterns on AiFinancialOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiFinancialOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiFinancialOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiFinancialOverview value)  $default,){
final _that = this;
switch (_that) {
case _AiFinancialOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiFinancialOverview value)?  $default,){
final _that = this;
switch (_that) {
case _AiFinancialOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MonthlyExpenseInsight> monthlyExpenses,  List<MonthlyIncomeInsight> monthlyIncomes,  List<CategoryExpenseInsight> topCategories,  List<CategoryIncomeInsight> topIncomeCategories,  List<BudgetForecastInsight> budgetForecasts,  DateTime generatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiFinancialOverview() when $default != null:
return $default(_that.monthlyExpenses,_that.monthlyIncomes,_that.topCategories,_that.topIncomeCategories,_that.budgetForecasts,_that.generatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MonthlyExpenseInsight> monthlyExpenses,  List<MonthlyIncomeInsight> monthlyIncomes,  List<CategoryExpenseInsight> topCategories,  List<CategoryIncomeInsight> topIncomeCategories,  List<BudgetForecastInsight> budgetForecasts,  DateTime generatedAt)  $default,) {final _that = this;
switch (_that) {
case _AiFinancialOverview():
return $default(_that.monthlyExpenses,_that.monthlyIncomes,_that.topCategories,_that.topIncomeCategories,_that.budgetForecasts,_that.generatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MonthlyExpenseInsight> monthlyExpenses,  List<MonthlyIncomeInsight> monthlyIncomes,  List<CategoryExpenseInsight> topCategories,  List<CategoryIncomeInsight> topIncomeCategories,  List<BudgetForecastInsight> budgetForecasts,  DateTime generatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AiFinancialOverview() when $default != null:
return $default(_that.monthlyExpenses,_that.monthlyIncomes,_that.topCategories,_that.topIncomeCategories,_that.budgetForecasts,_that.generatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiFinancialOverview extends AiFinancialOverview {
  const _AiFinancialOverview({required final  List<MonthlyExpenseInsight> monthlyExpenses, required final  List<MonthlyIncomeInsight> monthlyIncomes, required final  List<CategoryExpenseInsight> topCategories, required final  List<CategoryIncomeInsight> topIncomeCategories, required final  List<BudgetForecastInsight> budgetForecasts, required this.generatedAt}): _monthlyExpenses = monthlyExpenses,_monthlyIncomes = monthlyIncomes,_topCategories = topCategories,_topIncomeCategories = topIncomeCategories,_budgetForecasts = budgetForecasts,super._();
  factory _AiFinancialOverview.fromJson(Map<String, dynamic> json) => _$AiFinancialOverviewFromJson(json);

 final  List<MonthlyExpenseInsight> _monthlyExpenses;
@override List<MonthlyExpenseInsight> get monthlyExpenses {
  if (_monthlyExpenses is EqualUnmodifiableListView) return _monthlyExpenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlyExpenses);
}

 final  List<MonthlyIncomeInsight> _monthlyIncomes;
@override List<MonthlyIncomeInsight> get monthlyIncomes {
  if (_monthlyIncomes is EqualUnmodifiableListView) return _monthlyIncomes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlyIncomes);
}

 final  List<CategoryExpenseInsight> _topCategories;
@override List<CategoryExpenseInsight> get topCategories {
  if (_topCategories is EqualUnmodifiableListView) return _topCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topCategories);
}

 final  List<CategoryIncomeInsight> _topIncomeCategories;
@override List<CategoryIncomeInsight> get topIncomeCategories {
  if (_topIncomeCategories is EqualUnmodifiableListView) return _topIncomeCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topIncomeCategories);
}

 final  List<BudgetForecastInsight> _budgetForecasts;
@override List<BudgetForecastInsight> get budgetForecasts {
  if (_budgetForecasts is EqualUnmodifiableListView) return _budgetForecasts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_budgetForecasts);
}

@override final  DateTime generatedAt;

/// Create a copy of AiFinancialOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiFinancialOverviewCopyWith<_AiFinancialOverview> get copyWith => __$AiFinancialOverviewCopyWithImpl<_AiFinancialOverview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiFinancialOverviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiFinancialOverview&&const DeepCollectionEquality().equals(other._monthlyExpenses, _monthlyExpenses)&&const DeepCollectionEquality().equals(other._monthlyIncomes, _monthlyIncomes)&&const DeepCollectionEquality().equals(other._topCategories, _topCategories)&&const DeepCollectionEquality().equals(other._topIncomeCategories, _topIncomeCategories)&&const DeepCollectionEquality().equals(other._budgetForecasts, _budgetForecasts)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_monthlyExpenses),const DeepCollectionEquality().hash(_monthlyIncomes),const DeepCollectionEquality().hash(_topCategories),const DeepCollectionEquality().hash(_topIncomeCategories),const DeepCollectionEquality().hash(_budgetForecasts),generatedAt);

@override
String toString() {
  return 'AiFinancialOverview(monthlyExpenses: $monthlyExpenses, monthlyIncomes: $monthlyIncomes, topCategories: $topCategories, topIncomeCategories: $topIncomeCategories, budgetForecasts: $budgetForecasts, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class _$AiFinancialOverviewCopyWith<$Res> implements $AiFinancialOverviewCopyWith<$Res> {
  factory _$AiFinancialOverviewCopyWith(_AiFinancialOverview value, $Res Function(_AiFinancialOverview) _then) = __$AiFinancialOverviewCopyWithImpl;
@override @useResult
$Res call({
 List<MonthlyExpenseInsight> monthlyExpenses, List<MonthlyIncomeInsight> monthlyIncomes, List<CategoryExpenseInsight> topCategories, List<CategoryIncomeInsight> topIncomeCategories, List<BudgetForecastInsight> budgetForecasts, DateTime generatedAt
});




}
/// @nodoc
class __$AiFinancialOverviewCopyWithImpl<$Res>
    implements _$AiFinancialOverviewCopyWith<$Res> {
  __$AiFinancialOverviewCopyWithImpl(this._self, this._then);

  final _AiFinancialOverview _self;
  final $Res Function(_AiFinancialOverview) _then;

/// Create a copy of AiFinancialOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthlyExpenses = null,Object? monthlyIncomes = null,Object? topCategories = null,Object? topIncomeCategories = null,Object? budgetForecasts = null,Object? generatedAt = null,}) {
  return _then(_AiFinancialOverview(
monthlyExpenses: null == monthlyExpenses ? _self._monthlyExpenses : monthlyExpenses // ignore: cast_nullable_to_non_nullable
as List<MonthlyExpenseInsight>,monthlyIncomes: null == monthlyIncomes ? _self._monthlyIncomes : monthlyIncomes // ignore: cast_nullable_to_non_nullable
as List<MonthlyIncomeInsight>,topCategories: null == topCategories ? _self._topCategories : topCategories // ignore: cast_nullable_to_non_nullable
as List<CategoryExpenseInsight>,topIncomeCategories: null == topIncomeCategories ? _self._topIncomeCategories : topIncomeCategories // ignore: cast_nullable_to_non_nullable
as List<CategoryIncomeInsight>,budgetForecasts: null == budgetForecasts ? _self._budgetForecasts : budgetForecasts // ignore: cast_nullable_to_non_nullable
as List<BudgetForecastInsight>,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
