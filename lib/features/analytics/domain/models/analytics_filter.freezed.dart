// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalyticsFilter {

 DateTime get start; DateTime get end; String? get accountId; String? get categoryId;
/// Create a copy of AnalyticsFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsFilterCopyWith<AnalyticsFilter> get copyWith => _$AnalyticsFilterCopyWithImpl<AnalyticsFilter>(this as AnalyticsFilter, _$identity);

  /// Serializes this AnalyticsFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsFilter&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,accountId,categoryId);

@override
String toString() {
  return 'AnalyticsFilter(start: $start, end: $end, accountId: $accountId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $AnalyticsFilterCopyWith<$Res>  {
  factory $AnalyticsFilterCopyWith(AnalyticsFilter value, $Res Function(AnalyticsFilter) _then) = _$AnalyticsFilterCopyWithImpl;
@useResult
$Res call({
 DateTime start, DateTime end, String? accountId, String? categoryId
});




}
/// @nodoc
class _$AnalyticsFilterCopyWithImpl<$Res>
    implements $AnalyticsFilterCopyWith<$Res> {
  _$AnalyticsFilterCopyWithImpl(this._self, this._then);

  final AnalyticsFilter _self;
  final $Res Function(AnalyticsFilter) _then;

/// Create a copy of AnalyticsFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,Object? accountId = freezed,Object? categoryId = freezed,}) {
  return _then(_self.copyWith(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsFilter].
extension AnalyticsFilterPatterns on AnalyticsFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsFilter value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsFilter value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime start,  DateTime end,  String? accountId,  String? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsFilter() when $default != null:
return $default(_that.start,_that.end,_that.accountId,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime start,  DateTime end,  String? accountId,  String? categoryId)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsFilter():
return $default(_that.start,_that.end,_that.accountId,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime start,  DateTime end,  String? accountId,  String? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsFilter() when $default != null:
return $default(_that.start,_that.end,_that.accountId,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsFilter extends AnalyticsFilter {
  const _AnalyticsFilter({required this.start, required this.end, this.accountId, this.categoryId}): super._();
  factory _AnalyticsFilter.fromJson(Map<String, dynamic> json) => _$AnalyticsFilterFromJson(json);

@override final  DateTime start;
@override final  DateTime end;
@override final  String? accountId;
@override final  String? categoryId;

/// Create a copy of AnalyticsFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsFilterCopyWith<_AnalyticsFilter> get copyWith => __$AnalyticsFilterCopyWithImpl<_AnalyticsFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsFilter&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,accountId,categoryId);

@override
String toString() {
  return 'AnalyticsFilter(start: $start, end: $end, accountId: $accountId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsFilterCopyWith<$Res> implements $AnalyticsFilterCopyWith<$Res> {
  factory _$AnalyticsFilterCopyWith(_AnalyticsFilter value, $Res Function(_AnalyticsFilter) _then) = __$AnalyticsFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime start, DateTime end, String? accountId, String? categoryId
});




}
/// @nodoc
class __$AnalyticsFilterCopyWithImpl<$Res>
    implements _$AnalyticsFilterCopyWith<$Res> {
  __$AnalyticsFilterCopyWithImpl(this._self, this._then);

  final _AnalyticsFilter _self;
  final $Res Function(_AnalyticsFilter) _then;

/// Create a copy of AnalyticsFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? accountId = freezed,Object? categoryId = freezed,}) {
  return _then(_AnalyticsFilter(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
