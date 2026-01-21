// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saving_goal_category_breakdown.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingGoalCategoryBreakdown {

 String? get categoryId;@MoneyAmountJsonConverter() MoneyAmount get amount;
/// Create a copy of SavingGoalCategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingGoalCategoryBreakdownCopyWith<SavingGoalCategoryBreakdown> get copyWith => _$SavingGoalCategoryBreakdownCopyWithImpl<SavingGoalCategoryBreakdown>(this as SavingGoalCategoryBreakdown, _$identity);

  /// Serializes this SavingGoalCategoryBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingGoalCategoryBreakdown&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,amount);

@override
String toString() {
  return 'SavingGoalCategoryBreakdown(categoryId: $categoryId, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $SavingGoalCategoryBreakdownCopyWith<$Res>  {
  factory $SavingGoalCategoryBreakdownCopyWith(SavingGoalCategoryBreakdown value, $Res Function(SavingGoalCategoryBreakdown) _then) = _$SavingGoalCategoryBreakdownCopyWithImpl;
@useResult
$Res call({
 String? categoryId,@MoneyAmountJsonConverter() MoneyAmount amount
});




}
/// @nodoc
class _$SavingGoalCategoryBreakdownCopyWithImpl<$Res>
    implements $SavingGoalCategoryBreakdownCopyWith<$Res> {
  _$SavingGoalCategoryBreakdownCopyWithImpl(this._self, this._then);

  final SavingGoalCategoryBreakdown _self;
  final $Res Function(SavingGoalCategoryBreakdown) _then;

/// Create a copy of SavingGoalCategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = freezed,Object? amount = null,}) {
  return _then(_self.copyWith(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyAmount,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingGoalCategoryBreakdown].
extension SavingGoalCategoryBreakdownPatterns on SavingGoalCategoryBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingGoalCategoryBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingGoalCategoryBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingGoalCategoryBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _SavingGoalCategoryBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingGoalCategoryBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _SavingGoalCategoryBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? categoryId, @MoneyAmountJsonConverter()  MoneyAmount amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingGoalCategoryBreakdown() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? categoryId, @MoneyAmountJsonConverter()  MoneyAmount amount)  $default,) {final _that = this;
switch (_that) {
case _SavingGoalCategoryBreakdown():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? categoryId, @MoneyAmountJsonConverter()  MoneyAmount amount)?  $default,) {final _that = this;
switch (_that) {
case _SavingGoalCategoryBreakdown() when $default != null:
return $default(_that.categoryId,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingGoalCategoryBreakdown extends SavingGoalCategoryBreakdown {
  const _SavingGoalCategoryBreakdown({this.categoryId, @MoneyAmountJsonConverter() required this.amount}): super._();
  factory _SavingGoalCategoryBreakdown.fromJson(Map<String, dynamic> json) => _$SavingGoalCategoryBreakdownFromJson(json);

@override final  String? categoryId;
@override@MoneyAmountJsonConverter() final  MoneyAmount amount;

/// Create a copy of SavingGoalCategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingGoalCategoryBreakdownCopyWith<_SavingGoalCategoryBreakdown> get copyWith => __$SavingGoalCategoryBreakdownCopyWithImpl<_SavingGoalCategoryBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingGoalCategoryBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingGoalCategoryBreakdown&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,amount);

@override
String toString() {
  return 'SavingGoalCategoryBreakdown(categoryId: $categoryId, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$SavingGoalCategoryBreakdownCopyWith<$Res> implements $SavingGoalCategoryBreakdownCopyWith<$Res> {
  factory _$SavingGoalCategoryBreakdownCopyWith(_SavingGoalCategoryBreakdown value, $Res Function(_SavingGoalCategoryBreakdown) _then) = __$SavingGoalCategoryBreakdownCopyWithImpl;
@override @useResult
$Res call({
 String? categoryId,@MoneyAmountJsonConverter() MoneyAmount amount
});




}
/// @nodoc
class __$SavingGoalCategoryBreakdownCopyWithImpl<$Res>
    implements _$SavingGoalCategoryBreakdownCopyWith<$Res> {
  __$SavingGoalCategoryBreakdownCopyWithImpl(this._self, this._then);

  final _SavingGoalCategoryBreakdown _self;
  final $Res Function(_SavingGoalCategoryBreakdown) _then;

/// Create a copy of SavingGoalCategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = freezed,Object? amount = null,}) {
  return _then(_SavingGoalCategoryBreakdown(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyAmount,
  ));
}


}

// dart format on
