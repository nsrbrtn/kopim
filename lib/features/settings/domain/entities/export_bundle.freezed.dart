// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_bundle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExportBundle {

/// Версия схемы экспортируемых данных.
 String get schemaVersion;/// Временная метка формирования бандла.
 DateTime get generatedAt;/// Набор локальных счетов.
 List<AccountEntity> get accounts;/// Набор локальных транзакций.
 List<TransactionEntity> get transactions;/// Набор локальных категорий.
 List<Category> get categories;
/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportBundleCopyWith<ExportBundle> get copyWith => _$ExportBundleCopyWithImpl<ExportBundle>(this as ExportBundle, _$identity);

  /// Serializes this ExportBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportBundle&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&const DeepCollectionEquality().equals(other.transactions, transactions)&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,generatedAt,const DeepCollectionEquality().hash(accounts),const DeepCollectionEquality().hash(transactions),const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'ExportBundle(schemaVersion: $schemaVersion, generatedAt: $generatedAt, accounts: $accounts, transactions: $transactions, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $ExportBundleCopyWith<$Res>  {
  factory $ExportBundleCopyWith(ExportBundle value, $Res Function(ExportBundle) _then) = _$ExportBundleCopyWithImpl;
@useResult
$Res call({
 String schemaVersion, DateTime generatedAt, List<AccountEntity> accounts, List<TransactionEntity> transactions, List<Category> categories
});




}
/// @nodoc
class _$ExportBundleCopyWithImpl<$Res>
    implements $ExportBundleCopyWith<$Res> {
  _$ExportBundleCopyWithImpl(this._self, this._then);

  final ExportBundle _self;
  final $Res Function(ExportBundle) _then;

/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? generatedAt = null,Object? accounts = null,Object? transactions = null,Object? categories = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountEntity>,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntity>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportBundle].
extension ExportBundlePatterns on ExportBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportBundle value)  $default,){
final _that = this;
switch (_that) {
case _ExportBundle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportBundle value)?  $default,){
final _that = this;
switch (_that) {
case _ExportBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String schemaVersion,  DateTime generatedAt,  List<AccountEntity> accounts,  List<TransactionEntity> transactions,  List<Category> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportBundle() when $default != null:
return $default(_that.schemaVersion,_that.generatedAt,_that.accounts,_that.transactions,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String schemaVersion,  DateTime generatedAt,  List<AccountEntity> accounts,  List<TransactionEntity> transactions,  List<Category> categories)  $default,) {final _that = this;
switch (_that) {
case _ExportBundle():
return $default(_that.schemaVersion,_that.generatedAt,_that.accounts,_that.transactions,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String schemaVersion,  DateTime generatedAt,  List<AccountEntity> accounts,  List<TransactionEntity> transactions,  List<Category> categories)?  $default,) {final _that = this;
switch (_that) {
case _ExportBundle() when $default != null:
return $default(_that.schemaVersion,_that.generatedAt,_that.accounts,_that.transactions,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportBundle extends ExportBundle {
  const _ExportBundle({required this.schemaVersion, required this.generatedAt, final  List<AccountEntity> accounts = const <AccountEntity>[], final  List<TransactionEntity> transactions = const <TransactionEntity>[], final  List<Category> categories = const <Category>[]}): _accounts = accounts,_transactions = transactions,_categories = categories,super._();
  factory _ExportBundle.fromJson(Map<String, dynamic> json) => _$ExportBundleFromJson(json);

/// Версия схемы экспортируемых данных.
@override final  String schemaVersion;
/// Временная метка формирования бандла.
@override final  DateTime generatedAt;
/// Набор локальных счетов.
 final  List<AccountEntity> _accounts;
/// Набор локальных счетов.
@override@JsonKey() List<AccountEntity> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

/// Набор локальных транзакций.
 final  List<TransactionEntity> _transactions;
/// Набор локальных транзакций.
@override@JsonKey() List<TransactionEntity> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}

/// Набор локальных категорий.
 final  List<Category> _categories;
/// Набор локальных категорий.
@override@JsonKey() List<Category> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportBundleCopyWith<_ExportBundle> get copyWith => __$ExportBundleCopyWithImpl<_ExportBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportBundleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportBundle&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&const DeepCollectionEquality().equals(other._transactions, _transactions)&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,generatedAt,const DeepCollectionEquality().hash(_accounts),const DeepCollectionEquality().hash(_transactions),const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'ExportBundle(schemaVersion: $schemaVersion, generatedAt: $generatedAt, accounts: $accounts, transactions: $transactions, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$ExportBundleCopyWith<$Res> implements $ExportBundleCopyWith<$Res> {
  factory _$ExportBundleCopyWith(_ExportBundle value, $Res Function(_ExportBundle) _then) = __$ExportBundleCopyWithImpl;
@override @useResult
$Res call({
 String schemaVersion, DateTime generatedAt, List<AccountEntity> accounts, List<TransactionEntity> transactions, List<Category> categories
});




}
/// @nodoc
class __$ExportBundleCopyWithImpl<$Res>
    implements _$ExportBundleCopyWith<$Res> {
  __$ExportBundleCopyWithImpl(this._self, this._then);

  final _ExportBundle _self;
  final $Res Function(_ExportBundle) _then;

/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? generatedAt = null,Object? accounts = null,Object? transactions = null,Object? categories = null,}) {
  return _then(_ExportBundle(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountEntity>,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntity>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,
  ));
}


}

// dart format on
