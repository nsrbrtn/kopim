// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringJob {

 int get id; String get type; String get payload; DateTime get runAt; int get attempts; String? get lastError; DateTime get createdAt;
/// Create a copy of RecurringJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringJobCopyWith<RecurringJob> get copyWith => _$RecurringJobCopyWithImpl<RecurringJob>(this as RecurringJob, _$identity);

  /// Serializes this RecurringJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringJob&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.runAt, runAt) || other.runAt == runAt)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,payload,runAt,attempts,lastError,createdAt);

@override
String toString() {
  return 'RecurringJob(id: $id, type: $type, payload: $payload, runAt: $runAt, attempts: $attempts, lastError: $lastError, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RecurringJobCopyWith<$Res>  {
  factory $RecurringJobCopyWith(RecurringJob value, $Res Function(RecurringJob) _then) = _$RecurringJobCopyWithImpl;
@useResult
$Res call({
 int id, String type, String payload, DateTime runAt, int attempts, String? lastError, DateTime createdAt
});




}
/// @nodoc
class _$RecurringJobCopyWithImpl<$Res>
    implements $RecurringJobCopyWith<$Res> {
  _$RecurringJobCopyWithImpl(this._self, this._then);

  final RecurringJob _self;
  final $Res Function(RecurringJob) _then;

/// Create a copy of RecurringJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? payload = null,Object? runAt = null,Object? attempts = null,Object? lastError = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,runAt: null == runAt ? _self.runAt : runAt // ignore: cast_nullable_to_non_nullable
as DateTime,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringJob].
extension RecurringJobPatterns on RecurringJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringJob value)  $default,){
final _that = this;
switch (_that) {
case _RecurringJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringJob value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String type,  String payload,  DateTime runAt,  int attempts,  String? lastError,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringJob() when $default != null:
return $default(_that.id,_that.type,_that.payload,_that.runAt,_that.attempts,_that.lastError,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String type,  String payload,  DateTime runAt,  int attempts,  String? lastError,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _RecurringJob():
return $default(_that.id,_that.type,_that.payload,_that.runAt,_that.attempts,_that.lastError,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String type,  String payload,  DateTime runAt,  int attempts,  String? lastError,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RecurringJob() when $default != null:
return $default(_that.id,_that.type,_that.payload,_that.runAt,_that.attempts,_that.lastError,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringJob extends RecurringJob {
  const _RecurringJob({required this.id, required this.type, required this.payload, required this.runAt, required this.attempts, this.lastError, required this.createdAt}): super._();
  factory _RecurringJob.fromJson(Map<String, dynamic> json) => _$RecurringJobFromJson(json);

@override final  int id;
@override final  String type;
@override final  String payload;
@override final  DateTime runAt;
@override final  int attempts;
@override final  String? lastError;
@override final  DateTime createdAt;

/// Create a copy of RecurringJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringJobCopyWith<_RecurringJob> get copyWith => __$RecurringJobCopyWithImpl<_RecurringJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringJobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringJob&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.runAt, runAt) || other.runAt == runAt)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,payload,runAt,attempts,lastError,createdAt);

@override
String toString() {
  return 'RecurringJob(id: $id, type: $type, payload: $payload, runAt: $runAt, attempts: $attempts, lastError: $lastError, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RecurringJobCopyWith<$Res> implements $RecurringJobCopyWith<$Res> {
  factory _$RecurringJobCopyWith(_RecurringJob value, $Res Function(_RecurringJob) _then) = __$RecurringJobCopyWithImpl;
@override @useResult
$Res call({
 int id, String type, String payload, DateTime runAt, int attempts, String? lastError, DateTime createdAt
});




}
/// @nodoc
class __$RecurringJobCopyWithImpl<$Res>
    implements _$RecurringJobCopyWith<$Res> {
  __$RecurringJobCopyWithImpl(this._self, this._then);

  final _RecurringJob _self;
  final $Res Function(_RecurringJob) _then;

/// Create a copy of RecurringJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? payload = null,Object? runAt = null,Object? attempts = null,Object? lastError = freezed,Object? createdAt = null,}) {
  return _then(_RecurringJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,runAt: null == runAt ? _self.runAt : runAt // ignore: cast_nullable_to_non_nullable
as DateTime,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
