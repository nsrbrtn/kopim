// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedItem {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedItem);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedItem()';
}


}

/// @nodoc
class $FeedItemCopyWith<$Res>  {
$FeedItemCopyWith(FeedItem _, $Res Function(FeedItem) __);
}


/// Adds pattern-matching-related methods to [FeedItem].
extension FeedItemPatterns on FeedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TransactionFeedItem value)?  transaction,TResult Function( GroupedCreditPaymentFeedItem value)?  groupedCreditPayment,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TransactionFeedItem() when transaction != null:
return transaction(_that);case GroupedCreditPaymentFeedItem() when groupedCreditPayment != null:
return groupedCreditPayment(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TransactionFeedItem value)  transaction,required TResult Function( GroupedCreditPaymentFeedItem value)  groupedCreditPayment,}){
final _that = this;
switch (_that) {
case TransactionFeedItem():
return transaction(_that);case GroupedCreditPaymentFeedItem():
return groupedCreditPayment(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TransactionFeedItem value)?  transaction,TResult? Function( GroupedCreditPaymentFeedItem value)?  groupedCreditPayment,}){
final _that = this;
switch (_that) {
case TransactionFeedItem() when transaction != null:
return transaction(_that);case GroupedCreditPaymentFeedItem() when groupedCreditPayment != null:
return groupedCreditPayment(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( TransactionEntity transaction)?  transaction,TResult Function( String groupId,  String creditId,  List<TransactionEntity> transactions,  Money totalOutflow,  DateTime date,  String? note)?  groupedCreditPayment,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TransactionFeedItem() when transaction != null:
return transaction(_that.transaction);case GroupedCreditPaymentFeedItem() when groupedCreditPayment != null:
return groupedCreditPayment(_that.groupId,_that.creditId,_that.transactions,_that.totalOutflow,_that.date,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( TransactionEntity transaction)  transaction,required TResult Function( String groupId,  String creditId,  List<TransactionEntity> transactions,  Money totalOutflow,  DateTime date,  String? note)  groupedCreditPayment,}) {final _that = this;
switch (_that) {
case TransactionFeedItem():
return transaction(_that.transaction);case GroupedCreditPaymentFeedItem():
return groupedCreditPayment(_that.groupId,_that.creditId,_that.transactions,_that.totalOutflow,_that.date,_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( TransactionEntity transaction)?  transaction,TResult? Function( String groupId,  String creditId,  List<TransactionEntity> transactions,  Money totalOutflow,  DateTime date,  String? note)?  groupedCreditPayment,}) {final _that = this;
switch (_that) {
case TransactionFeedItem() when transaction != null:
return transaction(_that.transaction);case GroupedCreditPaymentFeedItem() when groupedCreditPayment != null:
return groupedCreditPayment(_that.groupId,_that.creditId,_that.transactions,_that.totalOutflow,_that.date,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class TransactionFeedItem implements FeedItem {
  const TransactionFeedItem(this.transaction);
  

 final  TransactionEntity transaction;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionFeedItemCopyWith<TransactionFeedItem> get copyWith => _$TransactionFeedItemCopyWithImpl<TransactionFeedItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionFeedItem&&(identical(other.transaction, transaction) || other.transaction == transaction));
}


@override
int get hashCode => Object.hash(runtimeType,transaction);

@override
String toString() {
  return 'FeedItem.transaction(transaction: $transaction)';
}


}

/// @nodoc
abstract mixin class $TransactionFeedItemCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory $TransactionFeedItemCopyWith(TransactionFeedItem value, $Res Function(TransactionFeedItem) _then) = _$TransactionFeedItemCopyWithImpl;
@useResult
$Res call({
 TransactionEntity transaction
});


$TransactionEntityCopyWith<$Res> get transaction;

}
/// @nodoc
class _$TransactionFeedItemCopyWithImpl<$Res>
    implements $TransactionFeedItemCopyWith<$Res> {
  _$TransactionFeedItemCopyWithImpl(this._self, this._then);

  final TransactionFeedItem _self;
  final $Res Function(TransactionFeedItem) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? transaction = null,}) {
  return _then(TransactionFeedItem(
null == transaction ? _self.transaction : transaction // ignore: cast_nullable_to_non_nullable
as TransactionEntity,
  ));
}

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionEntityCopyWith<$Res> get transaction {
  
  return $TransactionEntityCopyWith<$Res>(_self.transaction, (value) {
    return _then(_self.copyWith(transaction: value));
  });
}
}

/// @nodoc


class GroupedCreditPaymentFeedItem implements FeedItem {
  const GroupedCreditPaymentFeedItem({required this.groupId, required this.creditId, required final  List<TransactionEntity> transactions, required this.totalOutflow, required this.date, this.note}): _transactions = transactions;
  

 final  String groupId;
 final  String creditId;
 final  List<TransactionEntity> _transactions;
 List<TransactionEntity> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}

 final  Money totalOutflow;
 final  DateTime date;
 final  String? note;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupedCreditPaymentFeedItemCopyWith<GroupedCreditPaymentFeedItem> get copyWith => _$GroupedCreditPaymentFeedItemCopyWithImpl<GroupedCreditPaymentFeedItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupedCreditPaymentFeedItem&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&const DeepCollectionEquality().equals(other._transactions, _transactions)&&(identical(other.totalOutflow, totalOutflow) || other.totalOutflow == totalOutflow)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,groupId,creditId,const DeepCollectionEquality().hash(_transactions),totalOutflow,date,note);

@override
String toString() {
  return 'FeedItem.groupedCreditPayment(groupId: $groupId, creditId: $creditId, transactions: $transactions, totalOutflow: $totalOutflow, date: $date, note: $note)';
}


}

/// @nodoc
abstract mixin class $GroupedCreditPaymentFeedItemCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory $GroupedCreditPaymentFeedItemCopyWith(GroupedCreditPaymentFeedItem value, $Res Function(GroupedCreditPaymentFeedItem) _then) = _$GroupedCreditPaymentFeedItemCopyWithImpl;
@useResult
$Res call({
 String groupId, String creditId, List<TransactionEntity> transactions, Money totalOutflow, DateTime date, String? note
});




}
/// @nodoc
class _$GroupedCreditPaymentFeedItemCopyWithImpl<$Res>
    implements $GroupedCreditPaymentFeedItemCopyWith<$Res> {
  _$GroupedCreditPaymentFeedItemCopyWithImpl(this._self, this._then);

  final GroupedCreditPaymentFeedItem _self;
  final $Res Function(GroupedCreditPaymentFeedItem) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? creditId = null,Object? transactions = null,Object? totalOutflow = null,Object? date = null,Object? note = freezed,}) {
  return _then(GroupedCreditPaymentFeedItem(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,creditId: null == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntity>,totalOutflow: null == totalOutflow ? _self.totalOutflow : totalOutflow // ignore: cast_nullable_to_non_nullable
as Money,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
