// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_payment_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreditPaymentScheduleEntity {

 String get id; String get creditId; String get periodKey; DateTime get dueDate; CreditPaymentStatus get status; Money get principalAmount; Money get interestAmount; Money get totalAmount; Money get principalPaid; Money get interestPaid; DateTime? get paidAt;
/// Create a copy of CreditPaymentScheduleEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditPaymentScheduleEntityCopyWith<CreditPaymentScheduleEntity> get copyWith => _$CreditPaymentScheduleEntityCopyWithImpl<CreditPaymentScheduleEntity>(this as CreditPaymentScheduleEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditPaymentScheduleEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.periodKey, periodKey) || other.periodKey == periodKey)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.principalAmount, principalAmount) || other.principalAmount == principalAmount)&&(identical(other.interestAmount, interestAmount) || other.interestAmount == interestAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.principalPaid, principalPaid) || other.principalPaid == principalPaid)&&(identical(other.interestPaid, interestPaid) || other.interestPaid == interestPaid)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,creditId,periodKey,dueDate,status,principalAmount,interestAmount,totalAmount,principalPaid,interestPaid,paidAt);

@override
String toString() {
  return 'CreditPaymentScheduleEntity(id: $id, creditId: $creditId, periodKey: $periodKey, dueDate: $dueDate, status: $status, principalAmount: $principalAmount, interestAmount: $interestAmount, totalAmount: $totalAmount, principalPaid: $principalPaid, interestPaid: $interestPaid, paidAt: $paidAt)';
}


}

/// @nodoc
abstract mixin class $CreditPaymentScheduleEntityCopyWith<$Res>  {
  factory $CreditPaymentScheduleEntityCopyWith(CreditPaymentScheduleEntity value, $Res Function(CreditPaymentScheduleEntity) _then) = _$CreditPaymentScheduleEntityCopyWithImpl;
@useResult
$Res call({
 String id, String creditId, String periodKey, DateTime dueDate, CreditPaymentStatus status, Money principalAmount, Money interestAmount, Money totalAmount, Money principalPaid, Money interestPaid, DateTime? paidAt
});




}
/// @nodoc
class _$CreditPaymentScheduleEntityCopyWithImpl<$Res>
    implements $CreditPaymentScheduleEntityCopyWith<$Res> {
  _$CreditPaymentScheduleEntityCopyWithImpl(this._self, this._then);

  final CreditPaymentScheduleEntity _self;
  final $Res Function(CreditPaymentScheduleEntity) _then;

/// Create a copy of CreditPaymentScheduleEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creditId = null,Object? periodKey = null,Object? dueDate = null,Object? status = null,Object? principalAmount = null,Object? interestAmount = null,Object? totalAmount = null,Object? principalPaid = null,Object? interestPaid = null,Object? paidAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creditId: null == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String,periodKey: null == periodKey ? _self.periodKey : periodKey // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CreditPaymentStatus,principalAmount: null == principalAmount ? _self.principalAmount : principalAmount // ignore: cast_nullable_to_non_nullable
as Money,interestAmount: null == interestAmount ? _self.interestAmount : interestAmount // ignore: cast_nullable_to_non_nullable
as Money,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,principalPaid: null == principalPaid ? _self.principalPaid : principalPaid // ignore: cast_nullable_to_non_nullable
as Money,interestPaid: null == interestPaid ? _self.interestPaid : interestPaid // ignore: cast_nullable_to_non_nullable
as Money,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditPaymentScheduleEntity].
extension CreditPaymentScheduleEntityPatterns on CreditPaymentScheduleEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditPaymentScheduleEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditPaymentScheduleEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditPaymentScheduleEntity value)  $default,){
final _that = this;
switch (_that) {
case _CreditPaymentScheduleEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditPaymentScheduleEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CreditPaymentScheduleEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creditId,  String periodKey,  DateTime dueDate,  CreditPaymentStatus status,  Money principalAmount,  Money interestAmount,  Money totalAmount,  Money principalPaid,  Money interestPaid,  DateTime? paidAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditPaymentScheduleEntity() when $default != null:
return $default(_that.id,_that.creditId,_that.periodKey,_that.dueDate,_that.status,_that.principalAmount,_that.interestAmount,_that.totalAmount,_that.principalPaid,_that.interestPaid,_that.paidAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creditId,  String periodKey,  DateTime dueDate,  CreditPaymentStatus status,  Money principalAmount,  Money interestAmount,  Money totalAmount,  Money principalPaid,  Money interestPaid,  DateTime? paidAt)  $default,) {final _that = this;
switch (_that) {
case _CreditPaymentScheduleEntity():
return $default(_that.id,_that.creditId,_that.periodKey,_that.dueDate,_that.status,_that.principalAmount,_that.interestAmount,_that.totalAmount,_that.principalPaid,_that.interestPaid,_that.paidAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creditId,  String periodKey,  DateTime dueDate,  CreditPaymentStatus status,  Money principalAmount,  Money interestAmount,  Money totalAmount,  Money principalPaid,  Money interestPaid,  DateTime? paidAt)?  $default,) {final _that = this;
switch (_that) {
case _CreditPaymentScheduleEntity() when $default != null:
return $default(_that.id,_that.creditId,_that.periodKey,_that.dueDate,_that.status,_that.principalAmount,_that.interestAmount,_that.totalAmount,_that.principalPaid,_that.interestPaid,_that.paidAt);case _:
  return null;

}
}

}

/// @nodoc


class _CreditPaymentScheduleEntity implements CreditPaymentScheduleEntity {
  const _CreditPaymentScheduleEntity({required this.id, required this.creditId, required this.periodKey, required this.dueDate, required this.status, required this.principalAmount, required this.interestAmount, required this.totalAmount, required this.principalPaid, required this.interestPaid, this.paidAt});
  

@override final  String id;
@override final  String creditId;
@override final  String periodKey;
@override final  DateTime dueDate;
@override final  CreditPaymentStatus status;
@override final  Money principalAmount;
@override final  Money interestAmount;
@override final  Money totalAmount;
@override final  Money principalPaid;
@override final  Money interestPaid;
@override final  DateTime? paidAt;

/// Create a copy of CreditPaymentScheduleEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditPaymentScheduleEntityCopyWith<_CreditPaymentScheduleEntity> get copyWith => __$CreditPaymentScheduleEntityCopyWithImpl<_CreditPaymentScheduleEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditPaymentScheduleEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.periodKey, periodKey) || other.periodKey == periodKey)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.principalAmount, principalAmount) || other.principalAmount == principalAmount)&&(identical(other.interestAmount, interestAmount) || other.interestAmount == interestAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.principalPaid, principalPaid) || other.principalPaid == principalPaid)&&(identical(other.interestPaid, interestPaid) || other.interestPaid == interestPaid)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,creditId,periodKey,dueDate,status,principalAmount,interestAmount,totalAmount,principalPaid,interestPaid,paidAt);

@override
String toString() {
  return 'CreditPaymentScheduleEntity(id: $id, creditId: $creditId, periodKey: $periodKey, dueDate: $dueDate, status: $status, principalAmount: $principalAmount, interestAmount: $interestAmount, totalAmount: $totalAmount, principalPaid: $principalPaid, interestPaid: $interestPaid, paidAt: $paidAt)';
}


}

/// @nodoc
abstract mixin class _$CreditPaymentScheduleEntityCopyWith<$Res> implements $CreditPaymentScheduleEntityCopyWith<$Res> {
  factory _$CreditPaymentScheduleEntityCopyWith(_CreditPaymentScheduleEntity value, $Res Function(_CreditPaymentScheduleEntity) _then) = __$CreditPaymentScheduleEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String creditId, String periodKey, DateTime dueDate, CreditPaymentStatus status, Money principalAmount, Money interestAmount, Money totalAmount, Money principalPaid, Money interestPaid, DateTime? paidAt
});




}
/// @nodoc
class __$CreditPaymentScheduleEntityCopyWithImpl<$Res>
    implements _$CreditPaymentScheduleEntityCopyWith<$Res> {
  __$CreditPaymentScheduleEntityCopyWithImpl(this._self, this._then);

  final _CreditPaymentScheduleEntity _self;
  final $Res Function(_CreditPaymentScheduleEntity) _then;

/// Create a copy of CreditPaymentScheduleEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creditId = null,Object? periodKey = null,Object? dueDate = null,Object? status = null,Object? principalAmount = null,Object? interestAmount = null,Object? totalAmount = null,Object? principalPaid = null,Object? interestPaid = null,Object? paidAt = freezed,}) {
  return _then(_CreditPaymentScheduleEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creditId: null == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String,periodKey: null == periodKey ? _self.periodKey : periodKey // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CreditPaymentStatus,principalAmount: null == principalAmount ? _self.principalAmount : principalAmount // ignore: cast_nullable_to_non_nullable
as Money,interestAmount: null == interestAmount ? _self.interestAmount : interestAmount // ignore: cast_nullable_to_non_nullable
as Money,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,principalPaid: null == principalPaid ? _self.principalPaid : principalPaid // ignore: cast_nullable_to_non_nullable
as Money,interestPaid: null == interestPaid ? _self.interestPaid : interestPaid // ignore: cast_nullable_to_non_nullable
as Money,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
