// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_filter_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalyticsFilterState {

 DateTimeRange get dateRange; String? get accountId; String? get categoryId;
/// Create a copy of AnalyticsFilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsFilterStateCopyWith<AnalyticsFilterState> get copyWith => _$AnalyticsFilterStateCopyWithImpl<AnalyticsFilterState>(this as AnalyticsFilterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsFilterState&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,dateRange,accountId,categoryId);

@override
String toString() {
  return 'AnalyticsFilterState(dateRange: $dateRange, accountId: $accountId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $AnalyticsFilterStateCopyWith<$Res>  {
  factory $AnalyticsFilterStateCopyWith(AnalyticsFilterState value, $Res Function(AnalyticsFilterState) _then) = _$AnalyticsFilterStateCopyWithImpl;
@useResult
$Res call({
 DateTimeRange dateRange, String? accountId, String? categoryId
});




}
/// @nodoc
class _$AnalyticsFilterStateCopyWithImpl<$Res>
    implements $AnalyticsFilterStateCopyWith<$Res> {
  _$AnalyticsFilterStateCopyWithImpl(this._self, this._then);

  final AnalyticsFilterState _self;
  final $Res Function(AnalyticsFilterState) _then;

/// Create a copy of AnalyticsFilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateRange = null,Object? accountId = freezed,Object? categoryId = freezed,}) {
  return _then(_self.copyWith(
dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsFilterState].
extension AnalyticsFilterStatePatterns on AnalyticsFilterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsFilterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsFilterState value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsFilterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsFilterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTimeRange dateRange,  String? accountId,  String? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsFilterState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTimeRange dateRange,  String? accountId,  String? categoryId)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsFilterState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTimeRange dateRange,  String? accountId,  String? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsFilterState() when $default != null:
return $default(_that.dateRange,_that.accountId,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsFilterState extends AnalyticsFilterState {
  const _AnalyticsFilterState({required this.dateRange, this.accountId, this.categoryId}): super._();
  

@override final  DateTimeRange dateRange;
@override final  String? accountId;
@override final  String? categoryId;

/// Create a copy of AnalyticsFilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsFilterStateCopyWith<_AnalyticsFilterState> get copyWith => __$AnalyticsFilterStateCopyWithImpl<_AnalyticsFilterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsFilterState&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,dateRange,accountId,categoryId);

@override
String toString() {
  return 'AnalyticsFilterState(dateRange: $dateRange, accountId: $accountId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsFilterStateCopyWith<$Res> implements $AnalyticsFilterStateCopyWith<$Res> {
  factory _$AnalyticsFilterStateCopyWith(_AnalyticsFilterState value, $Res Function(_AnalyticsFilterState) _then) = __$AnalyticsFilterStateCopyWithImpl;
@override @useResult
$Res call({
 DateTimeRange dateRange, String? accountId, String? categoryId
});




}
/// @nodoc
class __$AnalyticsFilterStateCopyWithImpl<$Res>
    implements _$AnalyticsFilterStateCopyWith<$Res> {
  __$AnalyticsFilterStateCopyWithImpl(this._self, this._then);

  final _AnalyticsFilterState _self;
  final $Res Function(_AnalyticsFilterState) _then;

/// Create a copy of AnalyticsFilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateRange = null,Object? accountId = freezed,Object? categoryId = freezed,}) {
  return _then(_AnalyticsFilterState(
dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
