// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_grouping.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionListSection implements DiagnosticableTreeMixin {

 String get title; List<TransactionEntity> get transactions;
/// Create a copy of TransactionListSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionListSectionCopyWith<TransactionListSection> get copyWith => _$TransactionListSectionCopyWithImpl<TransactionListSection>(this as TransactionListSection, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TransactionListSection'))
    ..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('transactions', transactions));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionListSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.transactions, transactions));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(transactions));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TransactionListSection(title: $title, transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class $TransactionListSectionCopyWith<$Res>  {
  factory $TransactionListSectionCopyWith(TransactionListSection value, $Res Function(TransactionListSection) _then) = _$TransactionListSectionCopyWithImpl;
@useResult
$Res call({
 String title, List<TransactionEntity> transactions
});




}
/// @nodoc
class _$TransactionListSectionCopyWithImpl<$Res>
    implements $TransactionListSectionCopyWith<$Res> {
  _$TransactionListSectionCopyWithImpl(this._self, this._then);

  final TransactionListSection _self;
  final $Res Function(TransactionListSection) _then;

/// Create a copy of TransactionListSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? transactions = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntity>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionListSection].
extension TransactionListSectionPatterns on TransactionListSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionListSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionListSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionListSection value)  $default,){
final _that = this;
switch (_that) {
case _TransactionListSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionListSection value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionListSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<TransactionEntity> transactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionListSection() when $default != null:
return $default(_that.title,_that.transactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<TransactionEntity> transactions)  $default,) {final _that = this;
switch (_that) {
case _TransactionListSection():
return $default(_that.title,_that.transactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<TransactionEntity> transactions)?  $default,) {final _that = this;
switch (_that) {
case _TransactionListSection() when $default != null:
return $default(_that.title,_that.transactions);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionListSection with DiagnosticableTreeMixin implements TransactionListSection {
  const _TransactionListSection({required this.title, required final  List<TransactionEntity> transactions}): _transactions = transactions;
  

@override final  String title;
 final  List<TransactionEntity> _transactions;
@override List<TransactionEntity> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}


/// Create a copy of TransactionListSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionListSectionCopyWith<_TransactionListSection> get copyWith => __$TransactionListSectionCopyWithImpl<_TransactionListSection>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TransactionListSection'))
    ..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('transactions', transactions));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionListSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._transactions, _transactions));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_transactions));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TransactionListSection(title: $title, transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class _$TransactionListSectionCopyWith<$Res> implements $TransactionListSectionCopyWith<$Res> {
  factory _$TransactionListSectionCopyWith(_TransactionListSection value, $Res Function(_TransactionListSection) _then) = __$TransactionListSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, List<TransactionEntity> transactions
});




}
/// @nodoc
class __$TransactionListSectionCopyWithImpl<$Res>
    implements _$TransactionListSectionCopyWith<$Res> {
  __$TransactionListSectionCopyWithImpl(this._self, this._then);

  final _TransactionListSection _self;
  final $Res Function(_TransactionListSection) _then;

/// Create a copy of TransactionListSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? transactions = null,}) {
  return _then(_TransactionListSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntity>,
  ));
}


}

// dart format on
