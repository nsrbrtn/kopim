// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upcoming_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpcomingItem {

 UpcomingItemType get type; String get id; String get title; MoneyAmount get amount; int get whenMs; String? get categoryId; String? get note;
/// Create a copy of UpcomingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpcomingItemCopyWith<UpcomingItem> get copyWith => _$UpcomingItemCopyWithImpl<UpcomingItem>(this as UpcomingItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpcomingItem&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.whenMs, whenMs) || other.whenMs == whenMs)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,type,id,title,amount,whenMs,categoryId,note);

@override
String toString() {
  return 'UpcomingItem(type: $type, id: $id, title: $title, amount: $amount, whenMs: $whenMs, categoryId: $categoryId, note: $note)';
}


}

/// @nodoc
abstract mixin class $UpcomingItemCopyWith<$Res>  {
  factory $UpcomingItemCopyWith(UpcomingItem value, $Res Function(UpcomingItem) _then) = _$UpcomingItemCopyWithImpl;
@useResult
$Res call({
 UpcomingItemType type, String id, String title, MoneyAmount amount, int whenMs, String? categoryId, String? note
});




}
/// @nodoc
class _$UpcomingItemCopyWithImpl<$Res>
    implements $UpcomingItemCopyWith<$Res> {
  _$UpcomingItemCopyWithImpl(this._self, this._then);

  final UpcomingItem _self;
  final $Res Function(UpcomingItem) _then;

/// Create a copy of UpcomingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? id = null,Object? title = null,Object? amount = null,Object? whenMs = null,Object? categoryId = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UpcomingItemType,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyAmount,whenMs: null == whenMs ? _self.whenMs : whenMs // ignore: cast_nullable_to_non_nullable
as int,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpcomingItem].
extension UpcomingItemPatterns on UpcomingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpcomingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpcomingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpcomingItem value)  $default,){
final _that = this;
switch (_that) {
case _UpcomingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpcomingItem value)?  $default,){
final _that = this;
switch (_that) {
case _UpcomingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UpcomingItemType type,  String id,  String title,  MoneyAmount amount,  int whenMs,  String? categoryId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpcomingItem() when $default != null:
return $default(_that.type,_that.id,_that.title,_that.amount,_that.whenMs,_that.categoryId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UpcomingItemType type,  String id,  String title,  MoneyAmount amount,  int whenMs,  String? categoryId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _UpcomingItem():
return $default(_that.type,_that.id,_that.title,_that.amount,_that.whenMs,_that.categoryId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UpcomingItemType type,  String id,  String title,  MoneyAmount amount,  int whenMs,  String? categoryId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _UpcomingItem() when $default != null:
return $default(_that.type,_that.id,_that.title,_that.amount,_that.whenMs,_that.categoryId,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _UpcomingItem implements UpcomingItem {
  const _UpcomingItem({required this.type, required this.id, required this.title, required this.amount, required this.whenMs, this.categoryId, this.note});
  

@override final  UpcomingItemType type;
@override final  String id;
@override final  String title;
@override final  MoneyAmount amount;
@override final  int whenMs;
@override final  String? categoryId;
@override final  String? note;

/// Create a copy of UpcomingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpcomingItemCopyWith<_UpcomingItem> get copyWith => __$UpcomingItemCopyWithImpl<_UpcomingItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpcomingItem&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.whenMs, whenMs) || other.whenMs == whenMs)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,type,id,title,amount,whenMs,categoryId,note);

@override
String toString() {
  return 'UpcomingItem(type: $type, id: $id, title: $title, amount: $amount, whenMs: $whenMs, categoryId: $categoryId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$UpcomingItemCopyWith<$Res> implements $UpcomingItemCopyWith<$Res> {
  factory _$UpcomingItemCopyWith(_UpcomingItem value, $Res Function(_UpcomingItem) _then) = __$UpcomingItemCopyWithImpl;
@override @useResult
$Res call({
 UpcomingItemType type, String id, String title, MoneyAmount amount, int whenMs, String? categoryId, String? note
});




}
/// @nodoc
class __$UpcomingItemCopyWithImpl<$Res>
    implements _$UpcomingItemCopyWith<$Res> {
  __$UpcomingItemCopyWithImpl(this._self, this._then);

  final _UpcomingItem _self;
  final $Res Function(_UpcomingItem) _then;

/// Create a copy of UpcomingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? id = null,Object? title = null,Object? amount = null,Object? whenMs = null,Object? categoryId = freezed,Object? note = freezed,}) {
  return _then(_UpcomingItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UpcomingItemType,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyAmount,whenMs: null == whenMs ? _self.whenMs : whenMs // ignore: cast_nullable_to_non_nullable
as int,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
