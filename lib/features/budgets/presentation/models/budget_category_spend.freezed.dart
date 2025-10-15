// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_category_spend.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetCategorySpend {

 Category get category; double get spent; double? get limit;
/// Create a copy of BudgetCategorySpend
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetCategorySpendCopyWith<BudgetCategorySpend> get copyWith => _$BudgetCategorySpendCopyWithImpl<BudgetCategorySpend>(this as BudgetCategorySpend, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetCategorySpend&&(identical(other.category, category) || other.category == category)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,category,spent,limit);

@override
String toString() {
  return 'BudgetCategorySpend(category: $category, spent: $spent, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $BudgetCategorySpendCopyWith<$Res>  {
  factory $BudgetCategorySpendCopyWith(BudgetCategorySpend value, $Res Function(BudgetCategorySpend) _then) = _$BudgetCategorySpendCopyWithImpl;
@useResult
$Res call({
 Category category, double spent, double? limit
});


$CategoryCopyWith<$Res> get category;

}
/// @nodoc
class _$BudgetCategorySpendCopyWithImpl<$Res>
    implements $BudgetCategorySpendCopyWith<$Res> {
  _$BudgetCategorySpendCopyWithImpl(this._self, this._then);

  final BudgetCategorySpend _self;
  final $Res Function(BudgetCategorySpend) _then;

/// Create a copy of BudgetCategorySpend
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? spent = null,Object? limit = freezed,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of BudgetCategorySpend
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetCategorySpend].
extension BudgetCategorySpendPatterns on BudgetCategorySpend {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetCategorySpend value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetCategorySpend() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetCategorySpend value)  $default,){
final _that = this;
switch (_that) {
case _BudgetCategorySpend():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetCategorySpend value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetCategorySpend() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Category category,  double spent,  double? limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetCategorySpend() when $default != null:
return $default(_that.category,_that.spent,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Category category,  double spent,  double? limit)  $default,) {final _that = this;
switch (_that) {
case _BudgetCategorySpend():
return $default(_that.category,_that.spent,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Category category,  double spent,  double? limit)?  $default,) {final _that = this;
switch (_that) {
case _BudgetCategorySpend() when $default != null:
return $default(_that.category,_that.spent,_that.limit);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetCategorySpend implements BudgetCategorySpend {
  const _BudgetCategorySpend({required this.category, required this.spent, this.limit});
  

@override final  Category category;
@override final  double spent;
@override final  double? limit;

/// Create a copy of BudgetCategorySpend
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetCategorySpendCopyWith<_BudgetCategorySpend> get copyWith => __$BudgetCategorySpendCopyWithImpl<_BudgetCategorySpend>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetCategorySpend&&(identical(other.category, category) || other.category == category)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,category,spent,limit);

@override
String toString() {
  return 'BudgetCategorySpend(category: $category, spent: $spent, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$BudgetCategorySpendCopyWith<$Res> implements $BudgetCategorySpendCopyWith<$Res> {
  factory _$BudgetCategorySpendCopyWith(_BudgetCategorySpend value, $Res Function(_BudgetCategorySpend) _then) = __$BudgetCategorySpendCopyWithImpl;
@override @useResult
$Res call({
 Category category, double spent, double? limit
});


@override $CategoryCopyWith<$Res> get category;

}
/// @nodoc
class __$BudgetCategorySpendCopyWithImpl<$Res>
    implements _$BudgetCategorySpendCopyWith<$Res> {
  __$BudgetCategorySpendCopyWithImpl(this._self, this._then);

  final _BudgetCategorySpend _self;
  final $Res Function(_BudgetCategorySpend) _then;

/// Create a copy of BudgetCategorySpend
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? spent = null,Object? limit = freezed,}) {
  return _then(_BudgetCategorySpend(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of BudgetCategorySpend
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

// dart format on
