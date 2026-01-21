// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_details_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountTransactionsFilter {

 DateTimeRange? get dateRange; TransactionType? get type; String? get categoryId;
/// Create a copy of AccountTransactionsFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountTransactionsFilterCopyWith<AccountTransactionsFilter> get copyWith => _$AccountTransactionsFilterCopyWithImpl<AccountTransactionsFilter>(this as AccountTransactionsFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountTransactionsFilter&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,dateRange,type,categoryId);

@override
String toString() {
  return 'AccountTransactionsFilter(dateRange: $dateRange, type: $type, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $AccountTransactionsFilterCopyWith<$Res>  {
  factory $AccountTransactionsFilterCopyWith(AccountTransactionsFilter value, $Res Function(AccountTransactionsFilter) _then) = _$AccountTransactionsFilterCopyWithImpl;
@useResult
$Res call({
 DateTimeRange? dateRange, TransactionType? type, String? categoryId
});




}
/// @nodoc
class _$AccountTransactionsFilterCopyWithImpl<$Res>
    implements $AccountTransactionsFilterCopyWith<$Res> {
  _$AccountTransactionsFilterCopyWithImpl(this._self, this._then);

  final AccountTransactionsFilter _self;
  final $Res Function(AccountTransactionsFilter) _then;

/// Create a copy of AccountTransactionsFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateRange = freezed,Object? type = freezed,Object? categoryId = freezed,}) {
  return _then(_self.copyWith(
dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountTransactionsFilter].
extension AccountTransactionsFilterPatterns on AccountTransactionsFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountTransactionsFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountTransactionsFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountTransactionsFilter value)  $default,){
final _that = this;
switch (_that) {
case _AccountTransactionsFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountTransactionsFilter value)?  $default,){
final _that = this;
switch (_that) {
case _AccountTransactionsFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTimeRange? dateRange,  TransactionType? type,  String? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountTransactionsFilter() when $default != null:
return $default(_that.dateRange,_that.type,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTimeRange? dateRange,  TransactionType? type,  String? categoryId)  $default,) {final _that = this;
switch (_that) {
case _AccountTransactionsFilter():
return $default(_that.dateRange,_that.type,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTimeRange? dateRange,  TransactionType? type,  String? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _AccountTransactionsFilter() when $default != null:
return $default(_that.dateRange,_that.type,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _AccountTransactionsFilter extends AccountTransactionsFilter {
  const _AccountTransactionsFilter({this.dateRange, this.type, this.categoryId}): super._();
  

@override final  DateTimeRange? dateRange;
@override final  TransactionType? type;
@override final  String? categoryId;

/// Create a copy of AccountTransactionsFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountTransactionsFilterCopyWith<_AccountTransactionsFilter> get copyWith => __$AccountTransactionsFilterCopyWithImpl<_AccountTransactionsFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountTransactionsFilter&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,dateRange,type,categoryId);

@override
String toString() {
  return 'AccountTransactionsFilter(dateRange: $dateRange, type: $type, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$AccountTransactionsFilterCopyWith<$Res> implements $AccountTransactionsFilterCopyWith<$Res> {
  factory _$AccountTransactionsFilterCopyWith(_AccountTransactionsFilter value, $Res Function(_AccountTransactionsFilter) _then) = __$AccountTransactionsFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTimeRange? dateRange, TransactionType? type, String? categoryId
});




}
/// @nodoc
class __$AccountTransactionsFilterCopyWithImpl<$Res>
    implements _$AccountTransactionsFilterCopyWith<$Res> {
  __$AccountTransactionsFilterCopyWithImpl(this._self, this._then);

  final _AccountTransactionsFilter _self;
  final $Res Function(_AccountTransactionsFilter) _then;

/// Create a copy of AccountTransactionsFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateRange = freezed,Object? type = freezed,Object? categoryId = freezed,}) {
  return _then(_AccountTransactionsFilter(
dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AccountTransactionSummary {

 MoneyAmount get totalIncome; MoneyAmount get totalExpense;
/// Create a copy of AccountTransactionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountTransactionSummaryCopyWith<AccountTransactionSummary> get copyWith => _$AccountTransactionSummaryCopyWithImpl<AccountTransactionSummary>(this as AccountTransactionSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountTransactionSummary&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense));
}


@override
int get hashCode => Object.hash(runtimeType,totalIncome,totalExpense);

@override
String toString() {
  return 'AccountTransactionSummary(totalIncome: $totalIncome, totalExpense: $totalExpense)';
}


}

/// @nodoc
abstract mixin class $AccountTransactionSummaryCopyWith<$Res>  {
  factory $AccountTransactionSummaryCopyWith(AccountTransactionSummary value, $Res Function(AccountTransactionSummary) _then) = _$AccountTransactionSummaryCopyWithImpl;
@useResult
$Res call({
 MoneyAmount totalIncome, MoneyAmount totalExpense
});




}
/// @nodoc
class _$AccountTransactionSummaryCopyWithImpl<$Res>
    implements $AccountTransactionSummaryCopyWith<$Res> {
  _$AccountTransactionSummaryCopyWithImpl(this._self, this._then);

  final AccountTransactionSummary _self;
  final $Res Function(AccountTransactionSummary) _then;

/// Create a copy of AccountTransactionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalIncome = null,Object? totalExpense = null,}) {
  return _then(_self.copyWith(
totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as MoneyAmount,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as MoneyAmount,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountTransactionSummary].
extension AccountTransactionSummaryPatterns on AccountTransactionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountTransactionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountTransactionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountTransactionSummary value)  $default,){
final _that = this;
switch (_that) {
case _AccountTransactionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountTransactionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AccountTransactionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MoneyAmount totalIncome,  MoneyAmount totalExpense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountTransactionSummary() when $default != null:
return $default(_that.totalIncome,_that.totalExpense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MoneyAmount totalIncome,  MoneyAmount totalExpense)  $default,) {final _that = this;
switch (_that) {
case _AccountTransactionSummary():
return $default(_that.totalIncome,_that.totalExpense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MoneyAmount totalIncome,  MoneyAmount totalExpense)?  $default,) {final _that = this;
switch (_that) {
case _AccountTransactionSummary() when $default != null:
return $default(_that.totalIncome,_that.totalExpense);case _:
  return null;

}
}

}

/// @nodoc


class _AccountTransactionSummary extends AccountTransactionSummary {
  const _AccountTransactionSummary({required this.totalIncome, required this.totalExpense}): super._();
  

@override final  MoneyAmount totalIncome;
@override final  MoneyAmount totalExpense;

/// Create a copy of AccountTransactionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountTransactionSummaryCopyWith<_AccountTransactionSummary> get copyWith => __$AccountTransactionSummaryCopyWithImpl<_AccountTransactionSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountTransactionSummary&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense));
}


@override
int get hashCode => Object.hash(runtimeType,totalIncome,totalExpense);

@override
String toString() {
  return 'AccountTransactionSummary(totalIncome: $totalIncome, totalExpense: $totalExpense)';
}


}

/// @nodoc
abstract mixin class _$AccountTransactionSummaryCopyWith<$Res> implements $AccountTransactionSummaryCopyWith<$Res> {
  factory _$AccountTransactionSummaryCopyWith(_AccountTransactionSummary value, $Res Function(_AccountTransactionSummary) _then) = __$AccountTransactionSummaryCopyWithImpl;
@override @useResult
$Res call({
 MoneyAmount totalIncome, MoneyAmount totalExpense
});




}
/// @nodoc
class __$AccountTransactionSummaryCopyWithImpl<$Res>
    implements _$AccountTransactionSummaryCopyWith<$Res> {
  __$AccountTransactionSummaryCopyWithImpl(this._self, this._then);

  final _AccountTransactionSummary _self;
  final $Res Function(_AccountTransactionSummary) _then;

/// Create a copy of AccountTransactionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalIncome = null,Object? totalExpense = null,}) {
  return _then(_AccountTransactionSummary(
totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as MoneyAmount,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as MoneyAmount,
  ));
}


}

// dart format on
