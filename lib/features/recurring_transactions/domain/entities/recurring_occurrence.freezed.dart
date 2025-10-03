// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_occurrence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringOccurrence {

 String get id; String get ruleId; DateTime get dueAt; RecurringOccurrenceStatus get status; DateTime get createdAt; DateTime? get updatedAt; String? get postedTxId;
/// Create a copy of RecurringOccurrence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringOccurrenceCopyWith<RecurringOccurrence> get copyWith => _$RecurringOccurrenceCopyWithImpl<RecurringOccurrence>(this as RecurringOccurrence, _$identity);

  /// Serializes this RecurringOccurrence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringOccurrence&&(identical(other.id, id) || other.id == id)&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.postedTxId, postedTxId) || other.postedTxId == postedTxId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ruleId,dueAt,status,createdAt,updatedAt,postedTxId);

@override
String toString() {
  return 'RecurringOccurrence(id: $id, ruleId: $ruleId, dueAt: $dueAt, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, postedTxId: $postedTxId)';
}


}

/// @nodoc
abstract mixin class $RecurringOccurrenceCopyWith<$Res>  {
  factory $RecurringOccurrenceCopyWith(RecurringOccurrence value, $Res Function(RecurringOccurrence) _then) = _$RecurringOccurrenceCopyWithImpl;
@useResult
$Res call({
 String id, String ruleId, DateTime dueAt, RecurringOccurrenceStatus status, DateTime createdAt, DateTime? updatedAt, String? postedTxId
});




}
/// @nodoc
class _$RecurringOccurrenceCopyWithImpl<$Res>
    implements $RecurringOccurrenceCopyWith<$Res> {
  _$RecurringOccurrenceCopyWithImpl(this._self, this._then);

  final RecurringOccurrence _self;
  final $Res Function(RecurringOccurrence) _then;

/// Create a copy of RecurringOccurrence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ruleId = null,Object? dueAt = null,Object? status = null,Object? createdAt = null,Object? updatedAt = freezed,Object? postedTxId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecurringOccurrenceStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,postedTxId: freezed == postedTxId ? _self.postedTxId : postedTxId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringOccurrence].
extension RecurringOccurrencePatterns on RecurringOccurrence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringOccurrence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringOccurrence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringOccurrence value)  $default,){
final _that = this;
switch (_that) {
case _RecurringOccurrence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringOccurrence value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringOccurrence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ruleId,  DateTime dueAt,  RecurringOccurrenceStatus status,  DateTime createdAt,  DateTime? updatedAt,  String? postedTxId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringOccurrence() when $default != null:
return $default(_that.id,_that.ruleId,_that.dueAt,_that.status,_that.createdAt,_that.updatedAt,_that.postedTxId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ruleId,  DateTime dueAt,  RecurringOccurrenceStatus status,  DateTime createdAt,  DateTime? updatedAt,  String? postedTxId)  $default,) {final _that = this;
switch (_that) {
case _RecurringOccurrence():
return $default(_that.id,_that.ruleId,_that.dueAt,_that.status,_that.createdAt,_that.updatedAt,_that.postedTxId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ruleId,  DateTime dueAt,  RecurringOccurrenceStatus status,  DateTime createdAt,  DateTime? updatedAt,  String? postedTxId)?  $default,) {final _that = this;
switch (_that) {
case _RecurringOccurrence() when $default != null:
return $default(_that.id,_that.ruleId,_that.dueAt,_that.status,_that.createdAt,_that.updatedAt,_that.postedTxId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringOccurrence extends RecurringOccurrence {
  const _RecurringOccurrence({required this.id, required this.ruleId, required this.dueAt, this.status = RecurringOccurrenceStatus.scheduled, required this.createdAt, this.updatedAt, this.postedTxId}): super._();
  factory _RecurringOccurrence.fromJson(Map<String, dynamic> json) => _$RecurringOccurrenceFromJson(json);

@override final  String id;
@override final  String ruleId;
@override final  DateTime dueAt;
@override@JsonKey() final  RecurringOccurrenceStatus status;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override final  String? postedTxId;

/// Create a copy of RecurringOccurrence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringOccurrenceCopyWith<_RecurringOccurrence> get copyWith => __$RecurringOccurrenceCopyWithImpl<_RecurringOccurrence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringOccurrenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringOccurrence&&(identical(other.id, id) || other.id == id)&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.postedTxId, postedTxId) || other.postedTxId == postedTxId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ruleId,dueAt,status,createdAt,updatedAt,postedTxId);

@override
String toString() {
  return 'RecurringOccurrence(id: $id, ruleId: $ruleId, dueAt: $dueAt, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, postedTxId: $postedTxId)';
}


}

/// @nodoc
abstract mixin class _$RecurringOccurrenceCopyWith<$Res> implements $RecurringOccurrenceCopyWith<$Res> {
  factory _$RecurringOccurrenceCopyWith(_RecurringOccurrence value, $Res Function(_RecurringOccurrence) _then) = __$RecurringOccurrenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String ruleId, DateTime dueAt, RecurringOccurrenceStatus status, DateTime createdAt, DateTime? updatedAt, String? postedTxId
});




}
/// @nodoc
class __$RecurringOccurrenceCopyWithImpl<$Res>
    implements _$RecurringOccurrenceCopyWith<$Res> {
  __$RecurringOccurrenceCopyWithImpl(this._self, this._then);

  final _RecurringOccurrence _self;
  final $Res Function(_RecurringOccurrence) _then;

/// Create a copy of RecurringOccurrence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ruleId = null,Object? dueAt = null,Object? status = null,Object? createdAt = null,Object? updatedAt = freezed,Object? postedTxId = freezed,}) {
  return _then(_RecurringOccurrence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecurringOccurrenceStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,postedTxId: freezed == postedTxId ? _self.postedTxId : postedTxId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
