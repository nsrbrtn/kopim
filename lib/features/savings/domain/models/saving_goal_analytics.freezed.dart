// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saving_goal_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingGoalAnalytics {

 String get goalId; double get totalAmount; DateTime? get lastContributionAt; List<SavingGoalCategoryBreakdown> get categoryBreakdown; int get transactionCount;
/// Create a copy of SavingGoalAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingGoalAnalyticsCopyWith<SavingGoalAnalytics> get copyWith => _$SavingGoalAnalyticsCopyWithImpl<SavingGoalAnalytics>(this as SavingGoalAnalytics, _$identity);

  /// Serializes this SavingGoalAnalytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingGoalAnalytics&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.lastContributionAt, lastContributionAt) || other.lastContributionAt == lastContributionAt)&&const DeepCollectionEquality().equals(other.categoryBreakdown, categoryBreakdown)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,goalId,totalAmount,lastContributionAt,const DeepCollectionEquality().hash(categoryBreakdown),transactionCount);

@override
String toString() {
  return 'SavingGoalAnalytics(goalId: $goalId, totalAmount: $totalAmount, lastContributionAt: $lastContributionAt, categoryBreakdown: $categoryBreakdown, transactionCount: $transactionCount)';
}


}

/// @nodoc
abstract mixin class $SavingGoalAnalyticsCopyWith<$Res>  {
  factory $SavingGoalAnalyticsCopyWith(SavingGoalAnalytics value, $Res Function(SavingGoalAnalytics) _then) = _$SavingGoalAnalyticsCopyWithImpl;
@useResult
$Res call({
 String goalId, double totalAmount, DateTime? lastContributionAt, List<SavingGoalCategoryBreakdown> categoryBreakdown, int transactionCount
});




}
/// @nodoc
class _$SavingGoalAnalyticsCopyWithImpl<$Res>
    implements $SavingGoalAnalyticsCopyWith<$Res> {
  _$SavingGoalAnalyticsCopyWithImpl(this._self, this._then);

  final SavingGoalAnalytics _self;
  final $Res Function(SavingGoalAnalytics) _then;

/// Create a copy of SavingGoalAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? goalId = null,Object? totalAmount = null,Object? lastContributionAt = freezed,Object? categoryBreakdown = null,Object? transactionCount = null,}) {
  return _then(_self.copyWith(
goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,lastContributionAt: freezed == lastContributionAt ? _self.lastContributionAt : lastContributionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,categoryBreakdown: null == categoryBreakdown ? _self.categoryBreakdown : categoryBreakdown // ignore: cast_nullable_to_non_nullable
as List<SavingGoalCategoryBreakdown>,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingGoalAnalytics].
extension SavingGoalAnalyticsPatterns on SavingGoalAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingGoalAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingGoalAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingGoalAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _SavingGoalAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingGoalAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _SavingGoalAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String goalId,  double totalAmount,  DateTime? lastContributionAt,  List<SavingGoalCategoryBreakdown> categoryBreakdown,  int transactionCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingGoalAnalytics() when $default != null:
return $default(_that.goalId,_that.totalAmount,_that.lastContributionAt,_that.categoryBreakdown,_that.transactionCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String goalId,  double totalAmount,  DateTime? lastContributionAt,  List<SavingGoalCategoryBreakdown> categoryBreakdown,  int transactionCount)  $default,) {final _that = this;
switch (_that) {
case _SavingGoalAnalytics():
return $default(_that.goalId,_that.totalAmount,_that.lastContributionAt,_that.categoryBreakdown,_that.transactionCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String goalId,  double totalAmount,  DateTime? lastContributionAt,  List<SavingGoalCategoryBreakdown> categoryBreakdown,  int transactionCount)?  $default,) {final _that = this;
switch (_that) {
case _SavingGoalAnalytics() when $default != null:
return $default(_that.goalId,_that.totalAmount,_that.lastContributionAt,_that.categoryBreakdown,_that.transactionCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingGoalAnalytics extends SavingGoalAnalytics {
  const _SavingGoalAnalytics({required this.goalId, this.totalAmount = 0.0, this.lastContributionAt, final  List<SavingGoalCategoryBreakdown> categoryBreakdown = const <SavingGoalCategoryBreakdown>[], this.transactionCount = 0}): _categoryBreakdown = categoryBreakdown,super._();
  factory _SavingGoalAnalytics.fromJson(Map<String, dynamic> json) => _$SavingGoalAnalyticsFromJson(json);

@override final  String goalId;
@override@JsonKey() final  double totalAmount;
@override final  DateTime? lastContributionAt;
 final  List<SavingGoalCategoryBreakdown> _categoryBreakdown;
@override@JsonKey() List<SavingGoalCategoryBreakdown> get categoryBreakdown {
  if (_categoryBreakdown is EqualUnmodifiableListView) return _categoryBreakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryBreakdown);
}

@override@JsonKey() final  int transactionCount;

/// Create a copy of SavingGoalAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingGoalAnalyticsCopyWith<_SavingGoalAnalytics> get copyWith => __$SavingGoalAnalyticsCopyWithImpl<_SavingGoalAnalytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingGoalAnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingGoalAnalytics&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.lastContributionAt, lastContributionAt) || other.lastContributionAt == lastContributionAt)&&const DeepCollectionEquality().equals(other._categoryBreakdown, _categoryBreakdown)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,goalId,totalAmount,lastContributionAt,const DeepCollectionEquality().hash(_categoryBreakdown),transactionCount);

@override
String toString() {
  return 'SavingGoalAnalytics(goalId: $goalId, totalAmount: $totalAmount, lastContributionAt: $lastContributionAt, categoryBreakdown: $categoryBreakdown, transactionCount: $transactionCount)';
}


}

/// @nodoc
abstract mixin class _$SavingGoalAnalyticsCopyWith<$Res> implements $SavingGoalAnalyticsCopyWith<$Res> {
  factory _$SavingGoalAnalyticsCopyWith(_SavingGoalAnalytics value, $Res Function(_SavingGoalAnalytics) _then) = __$SavingGoalAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 String goalId, double totalAmount, DateTime? lastContributionAt, List<SavingGoalCategoryBreakdown> categoryBreakdown, int transactionCount
});




}
/// @nodoc
class __$SavingGoalAnalyticsCopyWithImpl<$Res>
    implements _$SavingGoalAnalyticsCopyWith<$Res> {
  __$SavingGoalAnalyticsCopyWithImpl(this._self, this._then);

  final _SavingGoalAnalytics _self;
  final $Res Function(_SavingGoalAnalytics) _then;

/// Create a copy of SavingGoalAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? goalId = null,Object? totalAmount = null,Object? lastContributionAt = freezed,Object? categoryBreakdown = null,Object? transactionCount = null,}) {
  return _then(_SavingGoalAnalytics(
goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,lastContributionAt: freezed == lastContributionAt ? _self.lastContributionAt : lastContributionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,categoryBreakdown: null == categoryBreakdown ? _self._categoryBreakdown : categoryBreakdown // ignore: cast_nullable_to_non_nullable
as List<SavingGoalCategoryBreakdown>,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
