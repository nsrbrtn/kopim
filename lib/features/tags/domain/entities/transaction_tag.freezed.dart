// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionTagEntity {

 String get transactionId; String get tagId; DateTime get createdAt; DateTime get updatedAt; bool get isDeleted;
/// Create a copy of TransactionTagEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionTagEntityCopyWith<TransactionTagEntity> get copyWith => _$TransactionTagEntityCopyWithImpl<TransactionTagEntity>(this as TransactionTagEntity, _$identity);

  /// Serializes this TransactionTagEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionTagEntity&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.tagId, tagId) || other.tagId == tagId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactionId,tagId,createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'TransactionTagEntity(transactionId: $transactionId, tagId: $tagId, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $TransactionTagEntityCopyWith<$Res>  {
  factory $TransactionTagEntityCopyWith(TransactionTagEntity value, $Res Function(TransactionTagEntity) _then) = _$TransactionTagEntityCopyWithImpl;
@useResult
$Res call({
 String transactionId, String tagId, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class _$TransactionTagEntityCopyWithImpl<$Res>
    implements $TransactionTagEntityCopyWith<$Res> {
  _$TransactionTagEntityCopyWithImpl(this._self, this._then);

  final TransactionTagEntity _self;
  final $Res Function(TransactionTagEntity) _then;

/// Create a copy of TransactionTagEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionId = null,Object? tagId = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,tagId: null == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionTagEntity].
extension TransactionTagEntityPatterns on TransactionTagEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionTagEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionTagEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionTagEntity value)  $default,){
final _that = this;
switch (_that) {
case _TransactionTagEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionTagEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionTagEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String transactionId,  String tagId,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionTagEntity() when $default != null:
return $default(_that.transactionId,_that.tagId,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String transactionId,  String tagId,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _TransactionTagEntity():
return $default(_that.transactionId,_that.tagId,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String transactionId,  String tagId,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _TransactionTagEntity() when $default != null:
return $default(_that.transactionId,_that.tagId,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionTagEntity extends TransactionTagEntity {
  const _TransactionTagEntity({required this.transactionId, required this.tagId, required this.createdAt, required this.updatedAt, this.isDeleted = false}): super._();
  factory _TransactionTagEntity.fromJson(Map<String, dynamic> json) => _$TransactionTagEntityFromJson(json);

@override final  String transactionId;
@override final  String tagId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of TransactionTagEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionTagEntityCopyWith<_TransactionTagEntity> get copyWith => __$TransactionTagEntityCopyWithImpl<_TransactionTagEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionTagEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionTagEntity&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.tagId, tagId) || other.tagId == tagId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactionId,tagId,createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'TransactionTagEntity(transactionId: $transactionId, tagId: $tagId, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$TransactionTagEntityCopyWith<$Res> implements $TransactionTagEntityCopyWith<$Res> {
  factory _$TransactionTagEntityCopyWith(_TransactionTagEntity value, $Res Function(_TransactionTagEntity) _then) = __$TransactionTagEntityCopyWithImpl;
@override @useResult
$Res call({
 String transactionId, String tagId, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class __$TransactionTagEntityCopyWithImpl<$Res>
    implements _$TransactionTagEntityCopyWith<$Res> {
  __$TransactionTagEntityCopyWithImpl(this._self, this._then);

  final _TransactionTagEntity _self;
  final $Res Function(_TransactionTagEntity) _then;

/// Create a copy of TransactionTagEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionId = null,Object? tagId = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_TransactionTagEntity(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,tagId: null == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
