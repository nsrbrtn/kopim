// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recalc_upcoming_payment_uc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecalcUpcomingPaymentRequest {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecalcUpcomingPaymentRequest);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RecalcUpcomingPaymentRequest()';
}


}

/// @nodoc
class $RecalcUpcomingPaymentRequestCopyWith<$Res>  {
$RecalcUpcomingPaymentRequestCopyWith(RecalcUpcomingPaymentRequest _, $Res Function(RecalcUpcomingPaymentRequest) __);
}


/// Adds pattern-matching-related methods to [RecalcUpcomingPaymentRequest].
extension RecalcUpcomingPaymentRequestPatterns on RecalcUpcomingPaymentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ById value)?  byId,TResult Function( _Entity value)?  entity,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ById() when byId != null:
return byId(_that);case _Entity() when entity != null:
return entity(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ById value)  byId,required TResult Function( _Entity value)  entity,}){
final _that = this;
switch (_that) {
case _ById():
return byId(_that);case _Entity():
return entity(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ById value)?  byId,TResult? Function( _Entity value)?  entity,}){
final _that = this;
switch (_that) {
case _ById() when byId != null:
return byId(_that);case _Entity() when entity != null:
return entity(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id)?  byId,TResult Function( UpcomingPayment payment)?  entity,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ById() when byId != null:
return byId(_that.id);case _Entity() when entity != null:
return entity(_that.payment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id)  byId,required TResult Function( UpcomingPayment payment)  entity,}) {final _that = this;
switch (_that) {
case _ById():
return byId(_that.id);case _Entity():
return entity(_that.payment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id)?  byId,TResult? Function( UpcomingPayment payment)?  entity,}) {final _that = this;
switch (_that) {
case _ById() when byId != null:
return byId(_that.id);case _Entity() when entity != null:
return entity(_that.payment);case _:
  return null;

}
}

}

/// @nodoc


class _ById implements RecalcUpcomingPaymentRequest {
  const _ById(this.id);
  

 final  String id;

/// Create a copy of RecalcUpcomingPaymentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ByIdCopyWith<_ById> get copyWith => __$ByIdCopyWithImpl<_ById>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ById&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'RecalcUpcomingPaymentRequest.byId(id: $id)';
}


}

/// @nodoc
abstract mixin class _$ByIdCopyWith<$Res> implements $RecalcUpcomingPaymentRequestCopyWith<$Res> {
  factory _$ByIdCopyWith(_ById value, $Res Function(_ById) _then) = __$ByIdCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$ByIdCopyWithImpl<$Res>
    implements _$ByIdCopyWith<$Res> {
  __$ByIdCopyWithImpl(this._self, this._then);

  final _ById _self;
  final $Res Function(_ById) _then;

/// Create a copy of RecalcUpcomingPaymentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_ById(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Entity implements RecalcUpcomingPaymentRequest {
  const _Entity(this.payment);
  

 final  UpcomingPayment payment;

/// Create a copy of RecalcUpcomingPaymentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntityCopyWith<_Entity> get copyWith => __$EntityCopyWithImpl<_Entity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Entity&&(identical(other.payment, payment) || other.payment == payment));
}


@override
int get hashCode => Object.hash(runtimeType,payment);

@override
String toString() {
  return 'RecalcUpcomingPaymentRequest.entity(payment: $payment)';
}


}

/// @nodoc
abstract mixin class _$EntityCopyWith<$Res> implements $RecalcUpcomingPaymentRequestCopyWith<$Res> {
  factory _$EntityCopyWith(_Entity value, $Res Function(_Entity) _then) = __$EntityCopyWithImpl;
@useResult
$Res call({
 UpcomingPayment payment
});


$UpcomingPaymentCopyWith<$Res> get payment;

}
/// @nodoc
class __$EntityCopyWithImpl<$Res>
    implements _$EntityCopyWith<$Res> {
  __$EntityCopyWithImpl(this._self, this._then);

  final _Entity _self;
  final $Res Function(_Entity) _then;

/// Create a copy of RecalcUpcomingPaymentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? payment = null,}) {
  return _then(_Entity(
null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as UpcomingPayment,
  ));
}

/// Create a copy of RecalcUpcomingPaymentRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpcomingPaymentCopyWith<$Res> get payment {
  
  return $UpcomingPaymentCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}

// dart format on
