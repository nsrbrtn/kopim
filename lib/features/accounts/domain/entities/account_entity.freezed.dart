// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountEntity {

 String get id; String get name; double get balance; String get currency; String get type; DateTime get createdAt; DateTime get updatedAt; String? get color; bool get isDeleted; bool get isPrimary;
/// Create a copy of AccountEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountEntityCopyWith<AccountEntity> get copyWith => _$AccountEntityCopyWithImpl<AccountEntity>(this as AccountEntity, _$identity);

  /// Serializes this AccountEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.color, color) || other.color == color)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,balance,currency,type,createdAt,updatedAt,color,isDeleted,isPrimary);

@override
String toString() {
  return 'AccountEntity(id: $id, name: $name, balance: $balance, currency: $currency, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, color: $color, isDeleted: $isDeleted, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class $AccountEntityCopyWith<$Res>  {
  factory $AccountEntityCopyWith(AccountEntity value, $Res Function(AccountEntity) _then) = _$AccountEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, double balance, String currency, String type, DateTime createdAt, DateTime updatedAt, String? color, bool isDeleted, bool isPrimary
});




}
/// @nodoc
class _$AccountEntityCopyWithImpl<$Res>
    implements $AccountEntityCopyWith<$Res> {
  _$AccountEntityCopyWithImpl(this._self, this._then);

  final AccountEntity _self;
  final $Res Function(AccountEntity) _then;

/// Create a copy of AccountEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? currency = null,Object? type = null,Object? createdAt = null,Object? updatedAt = null,Object? color = freezed,Object? isDeleted = null,Object? isPrimary = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountEntity].
extension AccountEntityPatterns on AccountEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountEntity value)  $default,){
final _that = this;
switch (_that) {
case _AccountEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AccountEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double balance,  String currency,  String type,  DateTime createdAt,  DateTime updatedAt,  String? color,  bool isDeleted,  bool isPrimary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountEntity() when $default != null:
return $default(_that.id,_that.name,_that.balance,_that.currency,_that.type,_that.createdAt,_that.updatedAt,_that.color,_that.isDeleted,_that.isPrimary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double balance,  String currency,  String type,  DateTime createdAt,  DateTime updatedAt,  String? color,  bool isDeleted,  bool isPrimary)  $default,) {final _that = this;
switch (_that) {
case _AccountEntity():
return $default(_that.id,_that.name,_that.balance,_that.currency,_that.type,_that.createdAt,_that.updatedAt,_that.color,_that.isDeleted,_that.isPrimary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double balance,  String currency,  String type,  DateTime createdAt,  DateTime updatedAt,  String? color,  bool isDeleted,  bool isPrimary)?  $default,) {final _that = this;
switch (_that) {
case _AccountEntity() when $default != null:
return $default(_that.id,_that.name,_that.balance,_that.currency,_that.type,_that.createdAt,_that.updatedAt,_that.color,_that.isDeleted,_that.isPrimary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountEntity extends AccountEntity {
  const _AccountEntity({required this.id, required this.name, required this.balance, required this.currency, required this.type, required this.createdAt, required this.updatedAt, this.color, this.isDeleted = false, this.isPrimary = false}): super._();
  factory _AccountEntity.fromJson(Map<String, dynamic> json) => _$AccountEntityFromJson(json);

@override final  String id;
@override final  String name;
@override final  double balance;
@override final  String currency;
@override final  String type;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? color;
@override@JsonKey() final  bool isDeleted;
@override@JsonKey() final  bool isPrimary;

/// Create a copy of AccountEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountEntityCopyWith<_AccountEntity> get copyWith => __$AccountEntityCopyWithImpl<_AccountEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.color, color) || other.color == color)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,balance,currency,type,createdAt,updatedAt,color,isDeleted,isPrimary);

@override
String toString() {
  return 'AccountEntity(id: $id, name: $name, balance: $balance, currency: $currency, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, color: $color, isDeleted: $isDeleted, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class _$AccountEntityCopyWith<$Res> implements $AccountEntityCopyWith<$Res> {
  factory _$AccountEntityCopyWith(_AccountEntity value, $Res Function(_AccountEntity) _then) = __$AccountEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double balance, String currency, String type, DateTime createdAt, DateTime updatedAt, String? color, bool isDeleted, bool isPrimary
});




}
/// @nodoc
class __$AccountEntityCopyWithImpl<$Res>
    implements _$AccountEntityCopyWith<$Res> {
  __$AccountEntityCopyWithImpl(this._self, this._then);

  final _AccountEntity _self;
  final $Res Function(_AccountEntity) _then;

/// Create a copy of AccountEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? currency = null,Object? type = null,Object? createdAt = null,Object? updatedAt = null,Object? color = freezed,Object? isDeleted = null,Object? isPrimary = null,}) {
  return _then(_AccountEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
