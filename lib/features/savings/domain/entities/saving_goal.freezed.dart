// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saving_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingGoal {

 String get id; String get userId; String get name; int get targetAmount; int get currentAmount; String? get note; DateTime get createdAt; DateTime get updatedAt; DateTime? get archivedAt;
/// Create a copy of SavingGoal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingGoalCopyWith<SavingGoal> get copyWith => _$SavingGoalCopyWithImpl<SavingGoal>(this as SavingGoal, _$identity);

  /// Serializes this SavingGoal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,targetAmount,currentAmount,note,createdAt,updatedAt,archivedAt);

@override
String toString() {
  return 'SavingGoal(id: $id, userId: $userId, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class $SavingGoalCopyWith<$Res>  {
  factory $SavingGoalCopyWith(SavingGoal value, $Res Function(SavingGoal) _then) = _$SavingGoalCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, int targetAmount, int currentAmount, String? note, DateTime createdAt, DateTime updatedAt, DateTime? archivedAt
});




}
/// @nodoc
class _$SavingGoalCopyWithImpl<$Res>
    implements $SavingGoalCopyWith<$Res> {
  _$SavingGoalCopyWithImpl(this._self, this._then);

  final SavingGoal _self;
  final $Res Function(SavingGoal) _then;

/// Create a copy of SavingGoal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? targetAmount = null,Object? currentAmount = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,Object? archivedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingGoal].
extension SavingGoalPatterns on SavingGoal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingGoal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingGoal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingGoal value)  $default,){
final _that = this;
switch (_that) {
case _SavingGoal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingGoal value)?  $default,){
final _that = this;
switch (_that) {
case _SavingGoal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  int targetAmount,  int currentAmount,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? archivedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingGoal() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.targetAmount,_that.currentAmount,_that.note,_that.createdAt,_that.updatedAt,_that.archivedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  int targetAmount,  int currentAmount,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? archivedAt)  $default,) {final _that = this;
switch (_that) {
case _SavingGoal():
return $default(_that.id,_that.userId,_that.name,_that.targetAmount,_that.currentAmount,_that.note,_that.createdAt,_that.updatedAt,_that.archivedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  int targetAmount,  int currentAmount,  String? note,  DateTime createdAt,  DateTime updatedAt,  DateTime? archivedAt)?  $default,) {final _that = this;
switch (_that) {
case _SavingGoal() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.targetAmount,_that.currentAmount,_that.note,_that.createdAt,_that.updatedAt,_that.archivedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingGoal extends SavingGoal {
  const _SavingGoal({required this.id, required this.userId, required this.name, required this.targetAmount, required this.currentAmount, this.note, required this.createdAt, required this.updatedAt, this.archivedAt}): super._();
  factory _SavingGoal.fromJson(Map<String, dynamic> json) => _$SavingGoalFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  int targetAmount;
@override final  int currentAmount;
@override final  String? note;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? archivedAt;

/// Create a copy of SavingGoal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingGoalCopyWith<_SavingGoal> get copyWith => __$SavingGoalCopyWithImpl<_SavingGoal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingGoalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,targetAmount,currentAmount,note,createdAt,updatedAt,archivedAt);

@override
String toString() {
  return 'SavingGoal(id: $id, userId: $userId, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class _$SavingGoalCopyWith<$Res> implements $SavingGoalCopyWith<$Res> {
  factory _$SavingGoalCopyWith(_SavingGoal value, $Res Function(_SavingGoal) _then) = __$SavingGoalCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, int targetAmount, int currentAmount, String? note, DateTime createdAt, DateTime updatedAt, DateTime? archivedAt
});




}
/// @nodoc
class __$SavingGoalCopyWithImpl<$Res>
    implements _$SavingGoalCopyWith<$Res> {
  __$SavingGoalCopyWithImpl(this._self, this._then);

  final _SavingGoal _self;
  final $Res Function(_SavingGoal) _then;

/// Create a copy of SavingGoal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? targetAmount = null,Object? currentAmount = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,Object? archivedAt = freezed,}) {
  return _then(_SavingGoal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
