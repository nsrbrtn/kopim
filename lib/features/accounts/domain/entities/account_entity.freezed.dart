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

 String get id; String get name; double get balance;@JsonKey(includeFromJson: false, includeToJson: false) BigInt? get balanceMinor; double get openingBalance;@JsonKey(includeFromJson: false, includeToJson: false) BigInt? get openingBalanceMinor; String get currency;@JsonKey(includeFromJson: false, includeToJson: false) int? get currencyScale; String get type; DateTime get createdAt; DateTime get updatedAt; String? get color; String? get gradientId; String? get iconName; String? get iconStyle; bool get isDeleted; bool get isPrimary; bool get isHidden;
/// Create a copy of AccountEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountEntityCopyWith<AccountEntity> get copyWith => _$AccountEntityCopyWithImpl<AccountEntity>(this as AccountEntity, _$identity);

  /// Serializes this AccountEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.balanceMinor, balanceMinor) || other.balanceMinor == balanceMinor)&&(identical(other.openingBalance, openingBalance) || other.openingBalance == openingBalance)&&(identical(other.openingBalanceMinor, openingBalanceMinor) || other.openingBalanceMinor == openingBalanceMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.currencyScale, currencyScale) || other.currencyScale == currencyScale)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.color, color) || other.color == color)&&(identical(other.gradientId, gradientId) || other.gradientId == gradientId)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.iconStyle, iconStyle) || other.iconStyle == iconStyle)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,balance,balanceMinor,openingBalance,openingBalanceMinor,currency,currencyScale,type,createdAt,updatedAt,color,gradientId,iconName,iconStyle,isDeleted,isPrimary,isHidden);

@override
String toString() {
  return 'AccountEntity(id: $id, name: $name, balance: $balance, balanceMinor: $balanceMinor, openingBalance: $openingBalance, openingBalanceMinor: $openingBalanceMinor, currency: $currency, currencyScale: $currencyScale, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, color: $color, gradientId: $gradientId, iconName: $iconName, iconStyle: $iconStyle, isDeleted: $isDeleted, isPrimary: $isPrimary, isHidden: $isHidden)';
}


}

/// @nodoc
abstract mixin class $AccountEntityCopyWith<$Res>  {
  factory $AccountEntityCopyWith(AccountEntity value, $Res Function(AccountEntity) _then) = _$AccountEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, double balance,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? balanceMinor, double openingBalance,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? openingBalanceMinor, String currency,@JsonKey(includeFromJson: false, includeToJson: false) int? currencyScale, String type, DateTime createdAt, DateTime updatedAt, String? color, String? gradientId, String? iconName, String? iconStyle, bool isDeleted, bool isPrimary, bool isHidden
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? balanceMinor = freezed,Object? openingBalance = null,Object? openingBalanceMinor = freezed,Object? currency = null,Object? currencyScale = freezed,Object? type = null,Object? createdAt = null,Object? updatedAt = null,Object? color = freezed,Object? gradientId = freezed,Object? iconName = freezed,Object? iconStyle = freezed,Object? isDeleted = null,Object? isPrimary = null,Object? isHidden = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,balanceMinor: freezed == balanceMinor ? _self.balanceMinor : balanceMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,openingBalance: null == openingBalance ? _self.openingBalance : openingBalance // ignore: cast_nullable_to_non_nullable
as double,openingBalanceMinor: freezed == openingBalanceMinor ? _self.openingBalanceMinor : openingBalanceMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,currencyScale: freezed == currencyScale ? _self.currencyScale : currencyScale // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,gradientId: freezed == gradientId ? _self.gradientId : gradientId // ignore: cast_nullable_to_non_nullable
as String?,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,iconStyle: freezed == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double balance, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? balanceMinor,  double openingBalance, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? openingBalanceMinor,  String currency, @JsonKey(includeFromJson: false, includeToJson: false)  int? currencyScale,  String type,  DateTime createdAt,  DateTime updatedAt,  String? color,  String? gradientId,  String? iconName,  String? iconStyle,  bool isDeleted,  bool isPrimary,  bool isHidden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountEntity() when $default != null:
return $default(_that.id,_that.name,_that.balance,_that.balanceMinor,_that.openingBalance,_that.openingBalanceMinor,_that.currency,_that.currencyScale,_that.type,_that.createdAt,_that.updatedAt,_that.color,_that.gradientId,_that.iconName,_that.iconStyle,_that.isDeleted,_that.isPrimary,_that.isHidden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double balance, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? balanceMinor,  double openingBalance, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? openingBalanceMinor,  String currency, @JsonKey(includeFromJson: false, includeToJson: false)  int? currencyScale,  String type,  DateTime createdAt,  DateTime updatedAt,  String? color,  String? gradientId,  String? iconName,  String? iconStyle,  bool isDeleted,  bool isPrimary,  bool isHidden)  $default,) {final _that = this;
switch (_that) {
case _AccountEntity():
return $default(_that.id,_that.name,_that.balance,_that.balanceMinor,_that.openingBalance,_that.openingBalanceMinor,_that.currency,_that.currencyScale,_that.type,_that.createdAt,_that.updatedAt,_that.color,_that.gradientId,_that.iconName,_that.iconStyle,_that.isDeleted,_that.isPrimary,_that.isHidden);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double balance, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? balanceMinor,  double openingBalance, @JsonKey(includeFromJson: false, includeToJson: false)  BigInt? openingBalanceMinor,  String currency, @JsonKey(includeFromJson: false, includeToJson: false)  int? currencyScale,  String type,  DateTime createdAt,  DateTime updatedAt,  String? color,  String? gradientId,  String? iconName,  String? iconStyle,  bool isDeleted,  bool isPrimary,  bool isHidden)?  $default,) {final _that = this;
switch (_that) {
case _AccountEntity() when $default != null:
return $default(_that.id,_that.name,_that.balance,_that.balanceMinor,_that.openingBalance,_that.openingBalanceMinor,_that.currency,_that.currencyScale,_that.type,_that.createdAt,_that.updatedAt,_that.color,_that.gradientId,_that.iconName,_that.iconStyle,_that.isDeleted,_that.isPrimary,_that.isHidden);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountEntity extends AccountEntity {
  const _AccountEntity({required this.id, required this.name, required this.balance, @JsonKey(includeFromJson: false, includeToJson: false) this.balanceMinor, this.openingBalance = 0, @JsonKey(includeFromJson: false, includeToJson: false) this.openingBalanceMinor, required this.currency, @JsonKey(includeFromJson: false, includeToJson: false) this.currencyScale, required this.type, required this.createdAt, required this.updatedAt, this.color, this.gradientId, this.iconName, this.iconStyle, this.isDeleted = false, this.isPrimary = false, this.isHidden = false}): super._();
  factory _AccountEntity.fromJson(Map<String, dynamic> json) => _$AccountEntityFromJson(json);

@override final  String id;
@override final  String name;
@override final  double balance;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  BigInt? balanceMinor;
@override@JsonKey() final  double openingBalance;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  BigInt? openingBalanceMinor;
@override final  String currency;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  int? currencyScale;
@override final  String type;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? color;
@override final  String? gradientId;
@override final  String? iconName;
@override final  String? iconStyle;
@override@JsonKey() final  bool isDeleted;
@override@JsonKey() final  bool isPrimary;
@override@JsonKey() final  bool isHidden;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.balanceMinor, balanceMinor) || other.balanceMinor == balanceMinor)&&(identical(other.openingBalance, openingBalance) || other.openingBalance == openingBalance)&&(identical(other.openingBalanceMinor, openingBalanceMinor) || other.openingBalanceMinor == openingBalanceMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.currencyScale, currencyScale) || other.currencyScale == currencyScale)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.color, color) || other.color == color)&&(identical(other.gradientId, gradientId) || other.gradientId == gradientId)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.iconStyle, iconStyle) || other.iconStyle == iconStyle)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,balance,balanceMinor,openingBalance,openingBalanceMinor,currency,currencyScale,type,createdAt,updatedAt,color,gradientId,iconName,iconStyle,isDeleted,isPrimary,isHidden);

@override
String toString() {
  return 'AccountEntity(id: $id, name: $name, balance: $balance, balanceMinor: $balanceMinor, openingBalance: $openingBalance, openingBalanceMinor: $openingBalanceMinor, currency: $currency, currencyScale: $currencyScale, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, color: $color, gradientId: $gradientId, iconName: $iconName, iconStyle: $iconStyle, isDeleted: $isDeleted, isPrimary: $isPrimary, isHidden: $isHidden)';
}


}

/// @nodoc
abstract mixin class _$AccountEntityCopyWith<$Res> implements $AccountEntityCopyWith<$Res> {
  factory _$AccountEntityCopyWith(_AccountEntity value, $Res Function(_AccountEntity) _then) = __$AccountEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double balance,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? balanceMinor, double openingBalance,@JsonKey(includeFromJson: false, includeToJson: false) BigInt? openingBalanceMinor, String currency,@JsonKey(includeFromJson: false, includeToJson: false) int? currencyScale, String type, DateTime createdAt, DateTime updatedAt, String? color, String? gradientId, String? iconName, String? iconStyle, bool isDeleted, bool isPrimary, bool isHidden
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? balanceMinor = freezed,Object? openingBalance = null,Object? openingBalanceMinor = freezed,Object? currency = null,Object? currencyScale = freezed,Object? type = null,Object? createdAt = null,Object? updatedAt = null,Object? color = freezed,Object? gradientId = freezed,Object? iconName = freezed,Object? iconStyle = freezed,Object? isDeleted = null,Object? isPrimary = null,Object? isHidden = null,}) {
  return _then(_AccountEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,balanceMinor: freezed == balanceMinor ? _self.balanceMinor : balanceMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,openingBalance: null == openingBalance ? _self.openingBalance : openingBalance // ignore: cast_nullable_to_non_nullable
as double,openingBalanceMinor: freezed == openingBalanceMinor ? _self.openingBalanceMinor : openingBalanceMinor // ignore: cast_nullable_to_non_nullable
as BigInt?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,currencyScale: freezed == currencyScale ? _self.currencyScale : currencyScale // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,gradientId: freezed == gradientId ? _self.gradientId : gradientId // ignore: cast_nullable_to_non_nullable
as String?,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,iconStyle: freezed == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
