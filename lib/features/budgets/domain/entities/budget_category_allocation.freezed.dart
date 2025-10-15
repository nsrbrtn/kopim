// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_category_allocation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetCategoryAllocation {

 String get categoryId; double get limit;
/// Create a copy of BudgetCategoryAllocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetCategoryAllocationCopyWith<BudgetCategoryAllocation> get copyWith => _$BudgetCategoryAllocationCopyWithImpl<BudgetCategoryAllocation>(this as BudgetCategoryAllocation, _$identity);

  /// Serializes this BudgetCategoryAllocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetCategoryAllocation&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,limit);

@override
String toString() {
  return 'BudgetCategoryAllocation(categoryId: $categoryId, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $BudgetCategoryAllocationCopyWith<$Res>  {
  factory $BudgetCategoryAllocationCopyWith(BudgetCategoryAllocation value, $Res Function(BudgetCategoryAllocation) _then) = _$BudgetCategoryAllocationCopyWithImpl;
@useResult
$Res call({
 String categoryId, double limit
});




}
/// @nodoc
class _$BudgetCategoryAllocationCopyWithImpl<$Res>
    implements $BudgetCategoryAllocationCopyWith<$Res> {
  _$BudgetCategoryAllocationCopyWithImpl(this._self, this._then);

  final BudgetCategoryAllocation _self;
  final $Res Function(BudgetCategoryAllocation) _then;

/// Create a copy of BudgetCategoryAllocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? limit = null,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetCategoryAllocation].
extension BudgetCategoryAllocationPatterns on BudgetCategoryAllocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetCategoryAllocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetCategoryAllocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetCategoryAllocation value)  $default,){
final _that = this;
switch (_that) {
case _BudgetCategoryAllocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetCategoryAllocation value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetCategoryAllocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  double limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetCategoryAllocation() when $default != null:
return $default(_that.categoryId,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  double limit)  $default,) {final _that = this;
switch (_that) {
case _BudgetCategoryAllocation():
return $default(_that.categoryId,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  double limit)?  $default,) {final _that = this;
switch (_that) {
case _BudgetCategoryAllocation() when $default != null:
return $default(_that.categoryId,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetCategoryAllocation implements BudgetCategoryAllocation {
  const _BudgetCategoryAllocation({required this.categoryId, required this.limit});
  factory _BudgetCategoryAllocation.fromJson(Map<String, dynamic> json) => _$BudgetCategoryAllocationFromJson(json);

@override final  String categoryId;
@override final  double limit;

/// Create a copy of BudgetCategoryAllocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetCategoryAllocationCopyWith<_BudgetCategoryAllocation> get copyWith => __$BudgetCategoryAllocationCopyWithImpl<_BudgetCategoryAllocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetCategoryAllocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetCategoryAllocation&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,limit);

@override
String toString() {
  return 'BudgetCategoryAllocation(categoryId: $categoryId, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$BudgetCategoryAllocationCopyWith<$Res> implements $BudgetCategoryAllocationCopyWith<$Res> {
  factory _$BudgetCategoryAllocationCopyWith(_BudgetCategoryAllocation value, $Res Function(_BudgetCategoryAllocation) _then) = __$BudgetCategoryAllocationCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, double limit
});




}
/// @nodoc
class __$BudgetCategoryAllocationCopyWithImpl<$Res>
    implements _$BudgetCategoryAllocationCopyWith<$Res> {
  __$BudgetCategoryAllocationCopyWithImpl(this._self, this._then);

  final _BudgetCategoryAllocation _self;
  final $Res Function(_BudgetCategoryAllocation) _then;

/// Create a copy of BudgetCategoryAllocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? limit = null,}) {
  return _then(_BudgetCategoryAllocation(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
