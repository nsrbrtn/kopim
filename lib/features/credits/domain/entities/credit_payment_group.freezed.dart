// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_payment_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreditPaymentGroupEntity {

 String get id; String get creditId; String get sourceAccountId; String? get scheduleItemId; DateTime get paidAt; Money get totalOutflow; Money get principalPaid; Money get interestPaid; Money get feesPaid; String? get note; String? get idempotencyKey;
/// Create a copy of CreditPaymentGroupEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditPaymentGroupEntityCopyWith<CreditPaymentGroupEntity> get copyWith => _$CreditPaymentGroupEntityCopyWithImpl<CreditPaymentGroupEntity>(this as CreditPaymentGroupEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditPaymentGroupEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.sourceAccountId, sourceAccountId) || other.sourceAccountId == sourceAccountId)&&(identical(other.scheduleItemId, scheduleItemId) || other.scheduleItemId == scheduleItemId)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.totalOutflow, totalOutflow) || other.totalOutflow == totalOutflow)&&(identical(other.principalPaid, principalPaid) || other.principalPaid == principalPaid)&&(identical(other.interestPaid, interestPaid) || other.interestPaid == interestPaid)&&(identical(other.feesPaid, feesPaid) || other.feesPaid == feesPaid)&&(identical(other.note, note) || other.note == note)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,id,creditId,sourceAccountId,scheduleItemId,paidAt,totalOutflow,principalPaid,interestPaid,feesPaid,note,idempotencyKey);

@override
String toString() {
  return 'CreditPaymentGroupEntity(id: $id, creditId: $creditId, sourceAccountId: $sourceAccountId, scheduleItemId: $scheduleItemId, paidAt: $paidAt, totalOutflow: $totalOutflow, principalPaid: $principalPaid, interestPaid: $interestPaid, feesPaid: $feesPaid, note: $note, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class $CreditPaymentGroupEntityCopyWith<$Res>  {
  factory $CreditPaymentGroupEntityCopyWith(CreditPaymentGroupEntity value, $Res Function(CreditPaymentGroupEntity) _then) = _$CreditPaymentGroupEntityCopyWithImpl;
@useResult
$Res call({
 String id, String creditId, String sourceAccountId, String? scheduleItemId, DateTime paidAt, Money totalOutflow, Money principalPaid, Money interestPaid, Money feesPaid, String? note, String? idempotencyKey
});




}
/// @nodoc
class _$CreditPaymentGroupEntityCopyWithImpl<$Res>
    implements $CreditPaymentGroupEntityCopyWith<$Res> {
  _$CreditPaymentGroupEntityCopyWithImpl(this._self, this._then);

  final CreditPaymentGroupEntity _self;
  final $Res Function(CreditPaymentGroupEntity) _then;

/// Create a copy of CreditPaymentGroupEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creditId = null,Object? sourceAccountId = null,Object? scheduleItemId = freezed,Object? paidAt = null,Object? totalOutflow = null,Object? principalPaid = null,Object? interestPaid = null,Object? feesPaid = null,Object? note = freezed,Object? idempotencyKey = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creditId: null == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String,sourceAccountId: null == sourceAccountId ? _self.sourceAccountId : sourceAccountId // ignore: cast_nullable_to_non_nullable
as String,scheduleItemId: freezed == scheduleItemId ? _self.scheduleItemId : scheduleItemId // ignore: cast_nullable_to_non_nullable
as String?,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalOutflow: null == totalOutflow ? _self.totalOutflow : totalOutflow // ignore: cast_nullable_to_non_nullable
as Money,principalPaid: null == principalPaid ? _self.principalPaid : principalPaid // ignore: cast_nullable_to_non_nullable
as Money,interestPaid: null == interestPaid ? _self.interestPaid : interestPaid // ignore: cast_nullable_to_non_nullable
as Money,feesPaid: null == feesPaid ? _self.feesPaid : feesPaid // ignore: cast_nullable_to_non_nullable
as Money,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditPaymentGroupEntity].
extension CreditPaymentGroupEntityPatterns on CreditPaymentGroupEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditPaymentGroupEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditPaymentGroupEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditPaymentGroupEntity value)  $default,){
final _that = this;
switch (_that) {
case _CreditPaymentGroupEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditPaymentGroupEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CreditPaymentGroupEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creditId,  String sourceAccountId,  String? scheduleItemId,  DateTime paidAt,  Money totalOutflow,  Money principalPaid,  Money interestPaid,  Money feesPaid,  String? note,  String? idempotencyKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditPaymentGroupEntity() when $default != null:
return $default(_that.id,_that.creditId,_that.sourceAccountId,_that.scheduleItemId,_that.paidAt,_that.totalOutflow,_that.principalPaid,_that.interestPaid,_that.feesPaid,_that.note,_that.idempotencyKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creditId,  String sourceAccountId,  String? scheduleItemId,  DateTime paidAt,  Money totalOutflow,  Money principalPaid,  Money interestPaid,  Money feesPaid,  String? note,  String? idempotencyKey)  $default,) {final _that = this;
switch (_that) {
case _CreditPaymentGroupEntity():
return $default(_that.id,_that.creditId,_that.sourceAccountId,_that.scheduleItemId,_that.paidAt,_that.totalOutflow,_that.principalPaid,_that.interestPaid,_that.feesPaid,_that.note,_that.idempotencyKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creditId,  String sourceAccountId,  String? scheduleItemId,  DateTime paidAt,  Money totalOutflow,  Money principalPaid,  Money interestPaid,  Money feesPaid,  String? note,  String? idempotencyKey)?  $default,) {final _that = this;
switch (_that) {
case _CreditPaymentGroupEntity() when $default != null:
return $default(_that.id,_that.creditId,_that.sourceAccountId,_that.scheduleItemId,_that.paidAt,_that.totalOutflow,_that.principalPaid,_that.interestPaid,_that.feesPaid,_that.note,_that.idempotencyKey);case _:
  return null;

}
}

}

/// @nodoc


class _CreditPaymentGroupEntity implements CreditPaymentGroupEntity {
  const _CreditPaymentGroupEntity({required this.id, required this.creditId, required this.sourceAccountId, this.scheduleItemId, required this.paidAt, required this.totalOutflow, required this.principalPaid, required this.interestPaid, required this.feesPaid, this.note, this.idempotencyKey});
  

@override final  String id;
@override final  String creditId;
@override final  String sourceAccountId;
@override final  String? scheduleItemId;
@override final  DateTime paidAt;
@override final  Money totalOutflow;
@override final  Money principalPaid;
@override final  Money interestPaid;
@override final  Money feesPaid;
@override final  String? note;
@override final  String? idempotencyKey;

/// Create a copy of CreditPaymentGroupEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditPaymentGroupEntityCopyWith<_CreditPaymentGroupEntity> get copyWith => __$CreditPaymentGroupEntityCopyWithImpl<_CreditPaymentGroupEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditPaymentGroupEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.sourceAccountId, sourceAccountId) || other.sourceAccountId == sourceAccountId)&&(identical(other.scheduleItemId, scheduleItemId) || other.scheduleItemId == scheduleItemId)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.totalOutflow, totalOutflow) || other.totalOutflow == totalOutflow)&&(identical(other.principalPaid, principalPaid) || other.principalPaid == principalPaid)&&(identical(other.interestPaid, interestPaid) || other.interestPaid == interestPaid)&&(identical(other.feesPaid, feesPaid) || other.feesPaid == feesPaid)&&(identical(other.note, note) || other.note == note)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,id,creditId,sourceAccountId,scheduleItemId,paidAt,totalOutflow,principalPaid,interestPaid,feesPaid,note,idempotencyKey);

@override
String toString() {
  return 'CreditPaymentGroupEntity(id: $id, creditId: $creditId, sourceAccountId: $sourceAccountId, scheduleItemId: $scheduleItemId, paidAt: $paidAt, totalOutflow: $totalOutflow, principalPaid: $principalPaid, interestPaid: $interestPaid, feesPaid: $feesPaid, note: $note, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class _$CreditPaymentGroupEntityCopyWith<$Res> implements $CreditPaymentGroupEntityCopyWith<$Res> {
  factory _$CreditPaymentGroupEntityCopyWith(_CreditPaymentGroupEntity value, $Res Function(_CreditPaymentGroupEntity) _then) = __$CreditPaymentGroupEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String creditId, String sourceAccountId, String? scheduleItemId, DateTime paidAt, Money totalOutflow, Money principalPaid, Money interestPaid, Money feesPaid, String? note, String? idempotencyKey
});




}
/// @nodoc
class __$CreditPaymentGroupEntityCopyWithImpl<$Res>
    implements _$CreditPaymentGroupEntityCopyWith<$Res> {
  __$CreditPaymentGroupEntityCopyWithImpl(this._self, this._then);

  final _CreditPaymentGroupEntity _self;
  final $Res Function(_CreditPaymentGroupEntity) _then;

/// Create a copy of CreditPaymentGroupEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creditId = null,Object? sourceAccountId = null,Object? scheduleItemId = freezed,Object? paidAt = null,Object? totalOutflow = null,Object? principalPaid = null,Object? interestPaid = null,Object? feesPaid = null,Object? note = freezed,Object? idempotencyKey = freezed,}) {
  return _then(_CreditPaymentGroupEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creditId: null == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String,sourceAccountId: null == sourceAccountId ? _self.sourceAccountId : sourceAccountId // ignore: cast_nullable_to_non_nullable
as String,scheduleItemId: freezed == scheduleItemId ? _self.scheduleItemId : scheduleItemId // ignore: cast_nullable_to_non_nullable
as String?,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalOutflow: null == totalOutflow ? _self.totalOutflow : totalOutflow // ignore: cast_nullable_to_non_nullable
as Money,principalPaid: null == principalPaid ? _self.principalPaid : principalPaid // ignore: cast_nullable_to_non_nullable
as Money,interestPaid: null == interestPaid ? _self.interestPaid : interestPaid // ignore: cast_nullable_to_non_nullable
as Money,feesPaid: null == feesPaid ? _self.feesPaid : feesPaid // ignore: cast_nullable_to_non_nullable
as Money,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
