// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'all_transactions_filter_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AllTransactionsFilterState {

 DateTimeRange? get dateRange; String? get accountId; String? get categoryId;
/// Create a copy of AllTransactionsFilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllTransactionsFilterStateCopyWith<AllTransactionsFilterState> get copyWith => _$AllTransactionsFilterStateCopyWithImpl<AllTransactionsFilterState>(this as AllTransactionsFilterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllTransactionsFilterState&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,dateRange,accountId,categoryId);

@override
String toString() {
  return 'AllTransactionsFilterState(dateRange: $dateRange, accountId: $accountId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $AllTransactionsFilterStateCopyWith<$Res>  {
  factory $AllTransactionsFilterStateCopyWith(AllTransactionsFilterState value, $Res Function(AllTransactionsFilterState) _then) = _$AllTransactionsFilterStateCopyWithImpl;
@useResult
$Res call({
 DateTimeRange? dateRange, String? accountId, String? categoryId
});




}
/// @nodoc
class _$AllTransactionsFilterStateCopyWithImpl<$Res>
    implements $AllTransactionsFilterStateCopyWith<$Res> {
  _$AllTransactionsFilterStateCopyWithImpl(this._self, this._then);

  final AllTransactionsFilterState _self;
  final $Res Function(AllTransactionsFilterState) _then;

/// Create a copy of AllTransactionsFilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateRange = freezed,Object? accountId = freezed,Object? categoryId = freezed,}) {
  return _then(_self.copyWith(
dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AllTransactionsFilterState].
extension AllTransactionsFilterStatePatterns on AllTransactionsFilterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllTransactionsFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllTransactionsFilterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllTransactionsFilterState value)  $default,){
final _that = this;
switch (_that) {
case _AllTransactionsFilterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllTransactionsFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _AllTransactionsFilterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTimeRange? dateRange,  String? accountId,  String? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllTransactionsFilterState() when $default != null:
return $default(_that.dateRange,_that.accountId,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTimeRange? dateRange,  String? accountId,  String? categoryId)  $default,) {final _that = this;
switch (_that) {
case _AllTransactionsFilterState():
return $default(_that.dateRange,_that.accountId,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTimeRange? dateRange,  String? accountId,  String? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _AllTransactionsFilterState() when $default != null:
return $default(_that.dateRange,_that.accountId,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _AllTransactionsFilterState implements AllTransactionsFilterState {
  const _AllTransactionsFilterState({this.dateRange, this.accountId, this.categoryId});
  

@override final  DateTimeRange? dateRange;
@override final  String? accountId;
@override final  String? categoryId;

/// Create a copy of AllTransactionsFilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllTransactionsFilterStateCopyWith<_AllTransactionsFilterState> get copyWith => __$AllTransactionsFilterStateCopyWithImpl<_AllTransactionsFilterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllTransactionsFilterState&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,dateRange,accountId,categoryId);

@override
String toString() {
  return 'AllTransactionsFilterState(dateRange: $dateRange, accountId: $accountId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$AllTransactionsFilterStateCopyWith<$Res> implements $AllTransactionsFilterStateCopyWith<$Res> {
  factory _$AllTransactionsFilterStateCopyWith(_AllTransactionsFilterState value, $Res Function(_AllTransactionsFilterState) _then) = __$AllTransactionsFilterStateCopyWithImpl;
@override @useResult
$Res call({
 DateTimeRange? dateRange, String? accountId, String? categoryId
});




}
/// @nodoc
class __$AllTransactionsFilterStateCopyWithImpl<$Res>
    implements _$AllTransactionsFilterStateCopyWith<$Res> {
  __$AllTransactionsFilterStateCopyWithImpl(this._self, this._then);

  final _AllTransactionsFilterState _self;
  final $Res Function(_AllTransactionsFilterState) _then;

/// Create a copy of AllTransactionsFilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateRange = freezed,Object? accountId = freezed,Object? categoryId = freezed,}) {
  return _then(_AllTransactionsFilterState(
dateRange: freezed == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
