// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_card_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreditCardEntity {

 String get id; String get accountId;@JsonKey(includeFromJson: false, includeToJson: false) BigInt? get creditLimitMinor;@JsonKey(includeFromJson: false, includeToJson: false) int? get creditLimitScale; int get statementDay; int get paymentDueDays; double get interestRateAnnual; DateTime get createdAt; DateTime get updatedAt; bool get isDeleted;
/// Create a copy of CreditCardEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditCardEntityCopyWith<CreditCardEntity> get copyWith => _$CreditCardEntityCopyWithImpl<CreditCardEntity>(this as CreditCardEntity, _$identity);

  /// Serializes this CreditCardEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditCardEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.creditLimitMinor, creditLimitMinor) || other.creditLimitMinor == creditLimitMinor)&&(identical(other.creditLimitScale, creditLimitScale) || other.creditLimitScale == creditLimitScale)&&(identical(other.statementDay, statementDay) || other.statementDay == statementDay)&&(identical(other.paymentDueDays, paymentDueDays) || other.paymentDueDays == paymentDueDays)&&(identical(other.interestRateAnnual, interestRateAnnual) || other.interestRateAnnual == interestRateAnnual)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,creditLimitMinor,creditLimitScale,statementDay,paymentDueDays,interestRateAnnual,createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'CreditCardEntity(id: $id, accountId: $accountId, creditLimitMinor: $creditLimitMinor, creditLimitScale: $creditLimitScale, statementDay: $statementDay, paymentDueDays: $paymentDueDays, interestRateAnnual: $interestRateAnnual, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $CreditCardEntityCopyWith<$Res>  {
  factory $CreditCardEntityCopyWith(CreditCardEntity value, $Res Function(CreditCardEntity) _then) = _$CreditCardEntityCopyWithImpl;
@useResult
$Res call({
 String id, String accountId,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? creditLimitMinor,@JsonKey(includeFromJson: false, includeToJson: false) int? creditLimitScale, int statementDay, int paymentDueDays, double interestRateAnnual, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class _$CreditCardEntityCopyWithImpl<$Res>
    implements $CreditCardEntityCopyWith<$Res> {
  _$CreditCardEntityCopyWithImpl(this._self, this._then);

  final CreditCardEntity _self;
  final $Res Function(CreditCardEntity) _then;

/// Create a copy of CreditCardEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? creditLimitMinor = freezed,Object? creditLimitScale = freezed,Object? statementDay = null,Object? paymentDueDays = null,Object? interestRateAnnual = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,creditLimitMinor: freezed == creditLimitMinor ? _self.creditLimitMinor : creditLimitMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,creditLimitScale: freezed == creditLimitScale ? _self.creditLimitScale : creditLimitScale // ignore: cast_nullable_to_non_nullable
as int?,statementDay: null == statementDay ? _self.statementDay : statementDay // ignore: cast_nullable_to_non_nullable
as int,paymentDueDays: null == paymentDueDays ? _self.paymentDueDays : paymentDueDays // ignore: cast_nullable_to_non_nullable
as int,interestRateAnnual: null == interestRateAnnual ? _self.interestRateAnnual : interestRateAnnual // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditCardEntity].
extension CreditCardEntityPatterns on CreditCardEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditCardEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditCardEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditCardEntity value)  $default,){
final _that = this;
switch (_that) {
case _CreditCardEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditCardEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CreditCardEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? creditLimitMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? creditLimitScale,  int statementDay,  int paymentDueDays,  double interestRateAnnual,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditCardEntity() when $default != null:
return $default(_that.id,_that.accountId,_that.creditLimitMinor,_that.creditLimitScale,_that.statementDay,_that.paymentDueDays,_that.interestRateAnnual,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? creditLimitMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? creditLimitScale,  int statementDay,  int paymentDueDays,  double interestRateAnnual,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _CreditCardEntity():
return $default(_that.id,_that.accountId,_that.creditLimitMinor,_that.creditLimitScale,_that.statementDay,_that.paymentDueDays,_that.interestRateAnnual,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? creditLimitMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? creditLimitScale,  int statementDay,  int paymentDueDays,  double interestRateAnnual,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _CreditCardEntity() when $default != null:
return $default(_that.id,_that.accountId,_that.creditLimitMinor,_that.creditLimitScale,_that.statementDay,_that.paymentDueDays,_that.interestRateAnnual,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditCardEntity extends CreditCardEntity {
  const _CreditCardEntity({required this.id, required this.accountId, @JsonKey(includeFromJson: false, includeToJson: false) this.creditLimitMinor, @JsonKey(includeFromJson: false, includeToJson: false) this.creditLimitScale, required this.statementDay, required this.paymentDueDays, required this.interestRateAnnual, required this.createdAt, required this.updatedAt, this.isDeleted = false}): super._();
  factory _CreditCardEntity.fromJson(Map<String, dynamic> json) => _$CreditCardEntityFromJson(json);

@override final  String id;
@override final  String accountId;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  BigInt? creditLimitMinor;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  int? creditLimitScale;
@override final  int statementDay;
@override final  int paymentDueDays;
@override final  double interestRateAnnual;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of CreditCardEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditCardEntityCopyWith<_CreditCardEntity> get copyWith => __$CreditCardEntityCopyWithImpl<_CreditCardEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditCardEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditCardEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.creditLimitMinor, creditLimitMinor) || other.creditLimitMinor == creditLimitMinor)&&(identical(other.creditLimitScale, creditLimitScale) || other.creditLimitScale == creditLimitScale)&&(identical(other.statementDay, statementDay) || other.statementDay == statementDay)&&(identical(other.paymentDueDays, paymentDueDays) || other.paymentDueDays == paymentDueDays)&&(identical(other.interestRateAnnual, interestRateAnnual) || other.interestRateAnnual == interestRateAnnual)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,creditLimitMinor,creditLimitScale,statementDay,paymentDueDays,interestRateAnnual,createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'CreditCardEntity(id: $id, accountId: $accountId, creditLimitMinor: $creditLimitMinor, creditLimitScale: $creditLimitScale, statementDay: $statementDay, paymentDueDays: $paymentDueDays, interestRateAnnual: $interestRateAnnual, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$CreditCardEntityCopyWith<$Res> implements $CreditCardEntityCopyWith<$Res> {
  factory _$CreditCardEntityCopyWith(_CreditCardEntity value, $Res Function(_CreditCardEntity) _then) = __$CreditCardEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? creditLimitMinor,@JsonKey(includeFromJson: false, includeToJson: false) int? creditLimitScale, int statementDay, int paymentDueDays, double interestRateAnnual, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class __$CreditCardEntityCopyWithImpl<$Res>
    implements _$CreditCardEntityCopyWith<$Res> {
  __$CreditCardEntityCopyWithImpl(this._self, this._then);

  final _CreditCardEntity _self;
  final $Res Function(_CreditCardEntity) _then;

/// Create a copy of CreditCardEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? creditLimitMinor = freezed,Object? creditLimitScale = freezed,Object? statementDay = null,Object? paymentDueDays = null,Object? interestRateAnnual = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_CreditCardEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,creditLimitMinor: freezed == creditLimitMinor ? _self.creditLimitMinor : creditLimitMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,creditLimitScale: freezed == creditLimitScale ? _self.creditLimitScale : creditLimitScale // ignore: cast_nullable_to_non_nullable
as int?,statementDay: null == statementDay ? _self.statementDay : statementDay // ignore: cast_nullable_to_non_nullable
as int,paymentDueDays: null == paymentDueDays ? _self.paymentDueDays : paymentDueDays // ignore: cast_nullable_to_non_nullable
as int,interestRateAnnual: null == interestRateAnnual ? _self.interestRateAnnual : interestRateAnnual // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
