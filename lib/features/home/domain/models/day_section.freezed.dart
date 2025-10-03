// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DaySection {

 DateTime get date; List<TransactionEntity> get transactions;
/// Create a copy of DaySection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaySectionCopyWith<DaySection> get copyWith => _$DaySectionCopyWithImpl<DaySection>(this as DaySection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DaySection&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.transactions, transactions));
}


@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(transactions));

@override
String toString() {
  return 'DaySection(date: $date, transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class $DaySectionCopyWith<$Res>  {
  factory $DaySectionCopyWith(DaySection value, $Res Function(DaySection) _then) = _$DaySectionCopyWithImpl;
@useResult
$Res call({
 DateTime date, List<TransactionEntity> transactions
});




}
/// @nodoc
class _$DaySectionCopyWithImpl<$Res>
    implements $DaySectionCopyWith<$Res> {
  _$DaySectionCopyWithImpl(this._self, this._then);

  final DaySection _self;
  final $Res Function(DaySection) _then;

/// Create a copy of DaySection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? transactions = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntity>,
  ));
}

}


/// Adds pattern-matching-related methods to [DaySection].
extension DaySectionPatterns on DaySection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaySection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaySection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaySection value)  $default,){
final _that = this;
switch (_that) {
case _DaySection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaySection value)?  $default,){
final _that = this;
switch (_that) {
case _DaySection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  List<TransactionEntity> transactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DaySection() when $default != null:
return $default(_that.date,_that.transactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  List<TransactionEntity> transactions)  $default,) {final _that = this;
switch (_that) {
case _DaySection():
return $default(_that.date,_that.transactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  List<TransactionEntity> transactions)?  $default,) {final _that = this;
switch (_that) {
case _DaySection() when $default != null:
return $default(_that.date,_that.transactions);case _:
  return null;

}
}

}

/// @nodoc


class _DaySection implements DaySection {
  const _DaySection({required this.date, required final  List<TransactionEntity> transactions}): _transactions = transactions;
  

@override final  DateTime date;
 final  List<TransactionEntity> _transactions;
@override List<TransactionEntity> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}


/// Create a copy of DaySection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaySectionCopyWith<_DaySection> get copyWith => __$DaySectionCopyWithImpl<_DaySection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DaySection&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._transactions, _transactions));
}


@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(_transactions));

@override
String toString() {
  return 'DaySection(date: $date, transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class _$DaySectionCopyWith<$Res> implements $DaySectionCopyWith<$Res> {
  factory _$DaySectionCopyWith(_DaySection value, $Res Function(_DaySection) _then) = __$DaySectionCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, List<TransactionEntity> transactions
});




}
/// @nodoc
class __$DaySectionCopyWithImpl<$Res>
    implements _$DaySectionCopyWith<$Res> {
  __$DaySectionCopyWithImpl(this._self, this._then);

  final _DaySection _self;
  final $Res Function(_DaySection) _then;

/// Create a copy of DaySection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? transactions = null,}) {
  return _then(_DaySection(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntity>,
  ));
}


}

// dart format on
