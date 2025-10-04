// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Budget {

 String get id; String get title;@JsonKey(fromJson: BudgetPeriodX.fromStorage, toJson: _periodToJson) BudgetPeriod get period; DateTime get startDate; DateTime? get endDate; double get amount;@JsonKey(fromJson: BudgetScopeX.fromStorage, toJson: _scopeToJson) BudgetScope get scope; List<String> get categories; List<String> get accounts; DateTime get createdAt; DateTime get updatedAt; bool get isDeleted;
/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetCopyWith<Budget> get copyWith => _$BudgetCopyWithImpl<Budget>(this as Budget, _$identity);

  /// Serializes this Budget to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Budget&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.period, period) || other.period == period)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,period,startDate,endDate,amount,scope,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(accounts),createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'Budget(id: $id, title: $title, period: $period, startDate: $startDate, endDate: $endDate, amount: $amount, scope: $scope, categories: $categories, accounts: $accounts, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $BudgetCopyWith<$Res>  {
  factory $BudgetCopyWith(Budget value, $Res Function(Budget) _then) = _$BudgetCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(fromJson: BudgetPeriodX.fromStorage, toJson: _periodToJson) BudgetPeriod period, DateTime startDate, DateTime? endDate, double amount,@JsonKey(fromJson: BudgetScopeX.fromStorage, toJson: _scopeToJson) BudgetScope scope, List<String> categories, List<String> accounts, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class _$BudgetCopyWithImpl<$Res>
    implements $BudgetCopyWith<$Res> {
  _$BudgetCopyWithImpl(this._self, this._then);

  final Budget _self;
  final $Res Function(Budget) _then;

/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? period = null,Object? startDate = null,Object? endDate = freezed,Object? amount = null,Object? scope = null,Object? categories = null,Object? accounts = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as BudgetPeriod,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as BudgetScope,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Budget].
extension BudgetPatterns on Budget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Budget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Budget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Budget value)  $default,){
final _that = this;
switch (_that) {
case _Budget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Budget value)?  $default,){
final _that = this;
switch (_that) {
case _Budget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(fromJson: BudgetPeriodX.fromStorage, toJson: _periodToJson)  BudgetPeriod period,  DateTime startDate,  DateTime? endDate,  double amount, @JsonKey(fromJson: BudgetScopeX.fromStorage, toJson: _scopeToJson)  BudgetScope scope,  List<String> categories,  List<String> accounts,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Budget() when $default != null:
return $default(_that.id,_that.title,_that.period,_that.startDate,_that.endDate,_that.amount,_that.scope,_that.categories,_that.accounts,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(fromJson: BudgetPeriodX.fromStorage, toJson: _periodToJson)  BudgetPeriod period,  DateTime startDate,  DateTime? endDate,  double amount, @JsonKey(fromJson: BudgetScopeX.fromStorage, toJson: _scopeToJson)  BudgetScope scope,  List<String> categories,  List<String> accounts,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _Budget():
return $default(_that.id,_that.title,_that.period,_that.startDate,_that.endDate,_that.amount,_that.scope,_that.categories,_that.accounts,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(fromJson: BudgetPeriodX.fromStorage, toJson: _periodToJson)  BudgetPeriod period,  DateTime startDate,  DateTime? endDate,  double amount, @JsonKey(fromJson: BudgetScopeX.fromStorage, toJson: _scopeToJson)  BudgetScope scope,  List<String> categories,  List<String> accounts,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _Budget() when $default != null:
return $default(_that.id,_that.title,_that.period,_that.startDate,_that.endDate,_that.amount,_that.scope,_that.categories,_that.accounts,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Budget extends Budget {
  const _Budget({required this.id, required this.title, @JsonKey(fromJson: BudgetPeriodX.fromStorage, toJson: _periodToJson) required this.period, required this.startDate, this.endDate, required this.amount, @JsonKey(fromJson: BudgetScopeX.fromStorage, toJson: _scopeToJson) required this.scope, final  List<String> categories = const <String>[], final  List<String> accounts = const <String>[], required this.createdAt, required this.updatedAt, this.isDeleted = false}): _categories = categories,_accounts = accounts,super._();
  factory _Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey(fromJson: BudgetPeriodX.fromStorage, toJson: _periodToJson) final  BudgetPeriod period;
@override final  DateTime startDate;
@override final  DateTime? endDate;
@override final  double amount;
@override@JsonKey(fromJson: BudgetScopeX.fromStorage, toJson: _scopeToJson) final  BudgetScope scope;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<String> _accounts;
@override@JsonKey() List<String> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetCopyWith<_Budget> get copyWith => __$BudgetCopyWithImpl<_Budget>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Budget&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.period, period) || other.period == period)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,period,startDate,endDate,amount,scope,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_accounts),createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'Budget(id: $id, title: $title, period: $period, startDate: $startDate, endDate: $endDate, amount: $amount, scope: $scope, categories: $categories, accounts: $accounts, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$BudgetCopyWith<$Res> implements $BudgetCopyWith<$Res> {
  factory _$BudgetCopyWith(_Budget value, $Res Function(_Budget) _then) = __$BudgetCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(fromJson: BudgetPeriodX.fromStorage, toJson: _periodToJson) BudgetPeriod period, DateTime startDate, DateTime? endDate, double amount,@JsonKey(fromJson: BudgetScopeX.fromStorage, toJson: _scopeToJson) BudgetScope scope, List<String> categories, List<String> accounts, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class __$BudgetCopyWithImpl<$Res>
    implements _$BudgetCopyWith<$Res> {
  __$BudgetCopyWithImpl(this._self, this._then);

  final _Budget _self;
  final $Res Function(_Budget) _then;

/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? period = null,Object? startDate = null,Object? endDate = freezed,Object? amount = null,Object? scope = null,Object? categories = null,Object? accounts = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_Budget(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as BudgetPeriod,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as BudgetScope,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
