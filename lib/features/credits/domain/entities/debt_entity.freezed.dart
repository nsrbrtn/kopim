// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debt_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DebtEntity {

 String get id; String get accountId; String get name; double get amount; DateTime get dueDate; String? get note; DateTime get createdAt; DateTime get updatedAt; bool get isDeleted;
/// Create a copy of DebtEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DebtEntityCopyWith<DebtEntity> get copyWith => _$DebtEntityCopyWithImpl<DebtEntity>(this as DebtEntity, _$identity);

  /// Serializes this DebtEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DebtEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,name,amount,dueDate,note,createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'DebtEntity(id: $id, accountId: $accountId, name: $name, amount: $amount, dueDate: $dueDate, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $DebtEntityCopyWith<$Res>  {
  factory $DebtEntityCopyWith(DebtEntity value, $Res Function(DebtEntity) _then) = _$DebtEntityCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String name, double amount, DateTime dueDate, String? note, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class _$DebtEntityCopyWithImpl<$Res>
    implements $DebtEntityCopyWith<$Res> {
  _$DebtEntityCopyWithImpl(this._self, this._then);

  final DebtEntity _self;
  final $Res Function(DebtEntity) _then;

/// Create a copy of DebtEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? name = null,Object? amount = null,Object? dueDate = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DebtEntity].
extension DebtEntityPatterns on DebtEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DebtEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DebtEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DebtEntity value)  $default,){
final _that = this;
switch (_that) {
case _DebtEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DebtEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DebtEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String name,  double amount,  DateTime dueDate,  String? note,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DebtEntity() when $default != null:
return $default(_that.id,_that.accountId,_that.name,_that.amount,_that.dueDate,_that.note,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String name,  double amount,  DateTime dueDate,  String? note,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _DebtEntity():
return $default(_that.id,_that.accountId,_that.name,_that.amount,_that.dueDate,_that.note,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String name,  double amount,  DateTime dueDate,  String? note,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _DebtEntity() when $default != null:
return $default(_that.id,_that.accountId,_that.name,_that.amount,_that.dueDate,_that.note,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DebtEntity implements DebtEntity {
  const _DebtEntity({required this.id, required this.accountId, this.name = '', required this.amount, required this.dueDate, this.note, required this.createdAt, required this.updatedAt, this.isDeleted = false});
  factory _DebtEntity.fromJson(Map<String, dynamic> json) => _$DebtEntityFromJson(json);

@override final  String id;
@override final  String accountId;
@override@JsonKey() final  String name;
@override final  double amount;
@override final  DateTime dueDate;
@override final  String? note;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of DebtEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DebtEntityCopyWith<_DebtEntity> get copyWith => __$DebtEntityCopyWithImpl<_DebtEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DebtEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DebtEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,name,amount,dueDate,note,createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'DebtEntity(id: $id, accountId: $accountId, name: $name, amount: $amount, dueDate: $dueDate, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$DebtEntityCopyWith<$Res> implements $DebtEntityCopyWith<$Res> {
  factory _$DebtEntityCopyWith(_DebtEntity value, $Res Function(_DebtEntity) _then) = __$DebtEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String name, double amount, DateTime dueDate, String? note, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class __$DebtEntityCopyWithImpl<$Res>
    implements _$DebtEntityCopyWith<$Res> {
  __$DebtEntityCopyWithImpl(this._self, this._then);

  final _DebtEntity _self;
  final $Res Function(_DebtEntity) _then;

/// Create a copy of DebtEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? name = null,Object? amount = null,Object? dueDate = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_DebtEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
