// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_category_breakdown.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalyticsCategoryBreakdown {

 String? get categoryId; double get amount; List<AnalyticsCategoryBreakdown> get children;
/// Create a copy of AnalyticsCategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsCategoryBreakdownCopyWith<AnalyticsCategoryBreakdown> get copyWith => _$AnalyticsCategoryBreakdownCopyWithImpl<AnalyticsCategoryBreakdown>(this as AnalyticsCategoryBreakdown, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsCategoryBreakdown&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,amount,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'AnalyticsCategoryBreakdown(categoryId: $categoryId, amount: $amount, children: $children)';
}


}

/// @nodoc
abstract mixin class $AnalyticsCategoryBreakdownCopyWith<$Res>  {
  factory $AnalyticsCategoryBreakdownCopyWith(AnalyticsCategoryBreakdown value, $Res Function(AnalyticsCategoryBreakdown) _then) = _$AnalyticsCategoryBreakdownCopyWithImpl;
@useResult
$Res call({
 String? categoryId, double amount, List<AnalyticsCategoryBreakdown> children
});




}
/// @nodoc
class _$AnalyticsCategoryBreakdownCopyWithImpl<$Res>
    implements $AnalyticsCategoryBreakdownCopyWith<$Res> {
  _$AnalyticsCategoryBreakdownCopyWithImpl(this._self, this._then);

  final AnalyticsCategoryBreakdown _self;
  final $Res Function(AnalyticsCategoryBreakdown) _then;

/// Create a copy of AnalyticsCategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = freezed,Object? amount = null,Object? children = null,}) {
  return _then(_self.copyWith(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<AnalyticsCategoryBreakdown>,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsCategoryBreakdown].
extension AnalyticsCategoryBreakdownPatterns on AnalyticsCategoryBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsCategoryBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsCategoryBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsCategoryBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsCategoryBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsCategoryBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsCategoryBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? categoryId,  double amount,  List<AnalyticsCategoryBreakdown> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsCategoryBreakdown() when $default != null:
return $default(_that.categoryId,_that.amount,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? categoryId,  double amount,  List<AnalyticsCategoryBreakdown> children)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsCategoryBreakdown():
return $default(_that.categoryId,_that.amount,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? categoryId,  double amount,  List<AnalyticsCategoryBreakdown> children)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsCategoryBreakdown() when $default != null:
return $default(_that.categoryId,_that.amount,_that.children);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsCategoryBreakdown extends AnalyticsCategoryBreakdown {
  const _AnalyticsCategoryBreakdown({this.categoryId, required this.amount, final  List<AnalyticsCategoryBreakdown> children = const <AnalyticsCategoryBreakdown>[]}): _children = children,super._();
  

@override final  String? categoryId;
@override final  double amount;
 final  List<AnalyticsCategoryBreakdown> _children;
@override@JsonKey() List<AnalyticsCategoryBreakdown> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of AnalyticsCategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsCategoryBreakdownCopyWith<_AnalyticsCategoryBreakdown> get copyWith => __$AnalyticsCategoryBreakdownCopyWithImpl<_AnalyticsCategoryBreakdown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsCategoryBreakdown&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,amount,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'AnalyticsCategoryBreakdown(categoryId: $categoryId, amount: $amount, children: $children)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsCategoryBreakdownCopyWith<$Res> implements $AnalyticsCategoryBreakdownCopyWith<$Res> {
  factory _$AnalyticsCategoryBreakdownCopyWith(_AnalyticsCategoryBreakdown value, $Res Function(_AnalyticsCategoryBreakdown) _then) = __$AnalyticsCategoryBreakdownCopyWithImpl;
@override @useResult
$Res call({
 String? categoryId, double amount, List<AnalyticsCategoryBreakdown> children
});




}
/// @nodoc
class __$AnalyticsCategoryBreakdownCopyWithImpl<$Res>
    implements _$AnalyticsCategoryBreakdownCopyWith<$Res> {
  __$AnalyticsCategoryBreakdownCopyWithImpl(this._self, this._then);

  final _AnalyticsCategoryBreakdown _self;
  final $Res Function(_AnalyticsCategoryBreakdown) _then;

/// Create a copy of AnalyticsCategoryBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = freezed,Object? amount = null,Object? children = null,}) {
  return _then(_AnalyticsCategoryBreakdown(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<AnalyticsCategoryBreakdown>,
  ));
}


}

// dart format on
