// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetInstance {

 String get id; String get budgetId; DateTime get periodStart; DateTime get periodEnd;@JsonKey(includeFromJson: false, includeToJson: false) BigInt? get amountMinor;@JsonKey(includeFromJson: false, includeToJson: false) BigInt? get spentMinor;@JsonKey(includeFromJson: false, includeToJson: false) int? get amountScale;@JsonKey(fromJson: BudgetInstanceStatusX.fromStorage, toJson: _statusToJson) BudgetInstanceStatus get status; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of BudgetInstance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetInstanceCopyWith<BudgetInstance> get copyWith => _$BudgetInstanceCopyWithImpl<BudgetInstance>(this as BudgetInstance, _$identity);

  /// Serializes this BudgetInstance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.spentMinor, spentMinor) || other.spentMinor == spentMinor)&&(identical(other.amountScale, amountScale) || other.amountScale == amountScale)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,budgetId,periodStart,periodEnd,amountMinor,spentMinor,amountScale,status,createdAt,updatedAt);

@override
String toString() {
  return 'BudgetInstance(id: $id, budgetId: $budgetId, periodStart: $periodStart, periodEnd: $periodEnd, amountMinor: $amountMinor, spentMinor: $spentMinor, amountScale: $amountScale, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BudgetInstanceCopyWith<$Res>  {
  factory $BudgetInstanceCopyWith(BudgetInstance value, $Res Function(BudgetInstance) _then) = _$BudgetInstanceCopyWithImpl;
@useResult
$Res call({
 String id, String budgetId, DateTime periodStart, DateTime periodEnd,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? amountMinor,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? spentMinor,@JsonKey(includeFromJson: false, includeToJson: false) int? amountScale,@JsonKey(fromJson: BudgetInstanceStatusX.fromStorage, toJson: _statusToJson) BudgetInstanceStatus status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$BudgetInstanceCopyWithImpl<$Res>
    implements $BudgetInstanceCopyWith<$Res> {
  _$BudgetInstanceCopyWithImpl(this._self, this._then);

  final BudgetInstance _self;
  final $Res Function(BudgetInstance) _then;

/// Create a copy of BudgetInstance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? budgetId = null,Object? periodStart = null,Object? periodEnd = null,Object? amountMinor = freezed,Object? spentMinor = freezed,Object? amountScale = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,budgetId: null == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,spentMinor: freezed == spentMinor ? _self.spentMinor : spentMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,amountScale: freezed == amountScale ? _self.amountScale : amountScale // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetInstanceStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetInstance].
extension BudgetInstancePatterns on BudgetInstance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetInstance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetInstance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetInstance value)  $default,){
final _that = this;
switch (_that) {
case _BudgetInstance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetInstance value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetInstance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String budgetId,  DateTime periodStart,  DateTime periodEnd, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? amountMinor, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? spentMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? amountScale, @JsonKey(fromJson: BudgetInstanceStatusX.fromStorage, toJson: _statusToJson)  BudgetInstanceStatus status,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetInstance() when $default != null:
return $default(_that.id,_that.budgetId,_that.periodStart,_that.periodEnd,_that.amountMinor,_that.spentMinor,_that.amountScale,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String budgetId,  DateTime periodStart,  DateTime periodEnd, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? amountMinor, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? spentMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? amountScale, @JsonKey(fromJson: BudgetInstanceStatusX.fromStorage, toJson: _statusToJson)  BudgetInstanceStatus status,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BudgetInstance():
return $default(_that.id,_that.budgetId,_that.periodStart,_that.periodEnd,_that.amountMinor,_that.spentMinor,_that.amountScale,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String budgetId,  DateTime periodStart,  DateTime periodEnd, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? amountMinor, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? spentMinor, @JsonKey(includeFromJson: false, includeToJson: false)  int? amountScale, @JsonKey(fromJson: BudgetInstanceStatusX.fromStorage, toJson: _statusToJson)  BudgetInstanceStatus status,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BudgetInstance() when $default != null:
return $default(_that.id,_that.budgetId,_that.periodStart,_that.periodEnd,_that.amountMinor,_that.spentMinor,_that.amountScale,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetInstance extends BudgetInstance {
  const _BudgetInstance({required this.id, required this.budgetId, required this.periodStart, required this.periodEnd, @JsonKey(includeFromJson: false, includeToJson: false) this.amountMinor, @JsonKey(includeFromJson: false, includeToJson: false) this.spentMinor, @JsonKey(includeFromJson: false, includeToJson: false) this.amountScale, @JsonKey(fromJson: BudgetInstanceStatusX.fromStorage, toJson: _statusToJson) required this.status, required this.createdAt, required this.updatedAt}): super._();
  factory _BudgetInstance.fromJson(Map<String, dynamic> json) => _$BudgetInstanceFromJson(json);

@override final  String id;
@override final  String budgetId;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  BigInt? amountMinor;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  BigInt? spentMinor;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  int? amountScale;
@override@JsonKey(fromJson: BudgetInstanceStatusX.fromStorage, toJson: _statusToJson) final  BudgetInstanceStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of BudgetInstance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetInstanceCopyWith<_BudgetInstance> get copyWith => __$BudgetInstanceCopyWithImpl<_BudgetInstance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetInstanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.spentMinor, spentMinor) || other.spentMinor == spentMinor)&&(identical(other.amountScale, amountScale) || other.amountScale == amountScale)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,budgetId,periodStart,periodEnd,amountMinor,spentMinor,amountScale,status,createdAt,updatedAt);

@override
String toString() {
  return 'BudgetInstance(id: $id, budgetId: $budgetId, periodStart: $periodStart, periodEnd: $periodEnd, amountMinor: $amountMinor, spentMinor: $spentMinor, amountScale: $amountScale, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BudgetInstanceCopyWith<$Res> implements $BudgetInstanceCopyWith<$Res> {
  factory _$BudgetInstanceCopyWith(_BudgetInstance value, $Res Function(_BudgetInstance) _then) = __$BudgetInstanceCopyWithImpl;
@override @useResult
$Res call({
 String id, String budgetId, DateTime periodStart, DateTime periodEnd,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? amountMinor,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? spentMinor,@JsonKey(includeFromJson: false, includeToJson: false) int? amountScale,@JsonKey(fromJson: BudgetInstanceStatusX.fromStorage, toJson: _statusToJson) BudgetInstanceStatus status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$BudgetInstanceCopyWithImpl<$Res>
    implements _$BudgetInstanceCopyWith<$Res> {
  __$BudgetInstanceCopyWithImpl(this._self, this._then);

  final _BudgetInstance _self;
  final $Res Function(_BudgetInstance) _then;

/// Create a copy of BudgetInstance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? budgetId = null,Object? periodStart = null,Object? periodEnd = null,Object? amountMinor = freezed,Object? spentMinor = freezed,Object? amountScale = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_BudgetInstance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,budgetId: null == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,spentMinor: freezed == spentMinor ? _self.spentMinor : spentMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,amountScale: freezed == amountScale ? _self.amountScale : amountScale // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetInstanceStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
