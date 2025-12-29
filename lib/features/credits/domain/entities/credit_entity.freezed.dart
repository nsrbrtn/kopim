// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreditEntity {

 String get id; String get accountId; String? get categoryId; double get totalAmount; double get interestRate; int get termMonths; DateTime get startDate; DateTime get createdAt; DateTime get updatedAt; bool get isDeleted;
/// Create a copy of CreditEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditEntityCopyWith<CreditEntity> get copyWith => _$CreditEntityCopyWithImpl<CreditEntity>(this as CreditEntity, _$identity);

  /// Serializes this CreditEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.interestRate, interestRate) || other.interestRate == interestRate)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,categoryId,totalAmount,interestRate,termMonths,startDate,createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'CreditEntity(id: $id, accountId: $accountId, categoryId: $categoryId, totalAmount: $totalAmount, interestRate: $interestRate, termMonths: $termMonths, startDate: $startDate, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $CreditEntityCopyWith<$Res>  {
  factory $CreditEntityCopyWith(CreditEntity value, $Res Function(CreditEntity) _then) = _$CreditEntityCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String? categoryId, double totalAmount, double interestRate, int termMonths, DateTime startDate, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class _$CreditEntityCopyWithImpl<$Res>
    implements $CreditEntityCopyWith<$Res> {
  _$CreditEntityCopyWithImpl(this._self, this._then);

  final CreditEntity _self;
  final $Res Function(CreditEntity) _then;

/// Create a copy of CreditEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? categoryId = freezed,Object? totalAmount = null,Object? interestRate = null,Object? termMonths = null,Object? startDate = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,interestRate: null == interestRate ? _self.interestRate : interestRate // ignore: cast_nullable_to_non_nullable
as double,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditEntity].
extension CreditEntityPatterns on CreditEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditEntity value)  $default,){
final _that = this;
switch (_that) {
case _CreditEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CreditEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String? categoryId,  double totalAmount,  double interestRate,  int termMonths,  DateTime startDate,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditEntity() when $default != null:
return $default(_that.id,_that.accountId,_that.categoryId,_that.totalAmount,_that.interestRate,_that.termMonths,_that.startDate,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String? categoryId,  double totalAmount,  double interestRate,  int termMonths,  DateTime startDate,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _CreditEntity():
return $default(_that.id,_that.accountId,_that.categoryId,_that.totalAmount,_that.interestRate,_that.termMonths,_that.startDate,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String? categoryId,  double totalAmount,  double interestRate,  int termMonths,  DateTime startDate,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _CreditEntity() when $default != null:
return $default(_that.id,_that.accountId,_that.categoryId,_that.totalAmount,_that.interestRate,_that.termMonths,_that.startDate,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditEntity implements CreditEntity {
  const _CreditEntity({required this.id, required this.accountId, this.categoryId, required this.totalAmount, required this.interestRate, required this.termMonths, required this.startDate, required this.createdAt, required this.updatedAt, this.isDeleted = false});
  factory _CreditEntity.fromJson(Map<String, dynamic> json) => _$CreditEntityFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  String? categoryId;
@override final  double totalAmount;
@override final  double interestRate;
@override final  int termMonths;
@override final  DateTime startDate;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of CreditEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditEntityCopyWith<_CreditEntity> get copyWith => __$CreditEntityCopyWithImpl<_CreditEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.interestRate, interestRate) || other.interestRate == interestRate)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,categoryId,totalAmount,interestRate,termMonths,startDate,createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'CreditEntity(id: $id, accountId: $accountId, categoryId: $categoryId, totalAmount: $totalAmount, interestRate: $interestRate, termMonths: $termMonths, startDate: $startDate, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$CreditEntityCopyWith<$Res> implements $CreditEntityCopyWith<$Res> {
  factory _$CreditEntityCopyWith(_CreditEntity value, $Res Function(_CreditEntity) _then) = __$CreditEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String? categoryId, double totalAmount, double interestRate, int termMonths, DateTime startDate, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class __$CreditEntityCopyWithImpl<$Res>
    implements _$CreditEntityCopyWith<$Res> {
  __$CreditEntityCopyWithImpl(this._self, this._then);

  final _CreditEntity _self;
  final $Res Function(_CreditEntity) _then;

/// Create a copy of CreditEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? categoryId = freezed,Object? totalAmount = null,Object? interestRate = null,Object? termMonths = null,Object? startDate = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_CreditEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,interestRate: null == interestRate ? _self.interestRate : interestRate // ignore: cast_nullable_to_non_nullable
as double,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
