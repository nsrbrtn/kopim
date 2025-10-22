// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantMessage {

 String get id; AssistantMessageAuthor get author; String get content; DateTime get createdAt; bool get isStreaming; AssistantMessageDeliveryStatus get deliveryStatus; Set<AssistantFilter> get contextFilters;
/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantMessageCopyWith<AssistantMessage> get copyWith => _$AssistantMessageCopyWithImpl<AssistantMessage>(this as AssistantMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&(identical(other.deliveryStatus, deliveryStatus) || other.deliveryStatus == deliveryStatus)&&const DeepCollectionEquality().equals(other.contextFilters, contextFilters));
}


@override
int get hashCode => Object.hash(runtimeType,id,author,content,createdAt,isStreaming,deliveryStatus,const DeepCollectionEquality().hash(contextFilters));

@override
String toString() {
  return 'AssistantMessage(id: $id, author: $author, content: $content, createdAt: $createdAt, isStreaming: $isStreaming, deliveryStatus: $deliveryStatus, contextFilters: $contextFilters)';
}


}

/// @nodoc
abstract mixin class $AssistantMessageCopyWith<$Res>  {
  factory $AssistantMessageCopyWith(AssistantMessage value, $Res Function(AssistantMessage) _then) = _$AssistantMessageCopyWithImpl;
@useResult
$Res call({
 String id, AssistantMessageAuthor author, String content, DateTime createdAt, bool isStreaming, AssistantMessageDeliveryStatus deliveryStatus, Set<AssistantFilter> contextFilters
});




}
/// @nodoc
class _$AssistantMessageCopyWithImpl<$Res>
    implements $AssistantMessageCopyWith<$Res> {
  _$AssistantMessageCopyWithImpl(this._self, this._then);

  final AssistantMessage _self;
  final $Res Function(AssistantMessage) _then;

/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? author = null,Object? content = null,Object? createdAt = null,Object? isStreaming = null,Object? deliveryStatus = null,Object? contextFilters = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as AssistantMessageAuthor,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,deliveryStatus: null == deliveryStatus ? _self.deliveryStatus : deliveryStatus // ignore: cast_nullable_to_non_nullable
as AssistantMessageDeliveryStatus,contextFilters: null == contextFilters ? _self.contextFilters : contextFilters // ignore: cast_nullable_to_non_nullable
as Set<AssistantFilter>,
  ));
}

}


/// Adds pattern-matching-related methods to [AssistantMessage].
extension AssistantMessagePatterns on AssistantMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantMessage value)  $default,){
final _that = this;
switch (_that) {
case _AssistantMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantMessage value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AssistantMessageAuthor author,  String content,  DateTime createdAt,  bool isStreaming,  AssistantMessageDeliveryStatus deliveryStatus,  Set<AssistantFilter> contextFilters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
return $default(_that.id,_that.author,_that.content,_that.createdAt,_that.isStreaming,_that.deliveryStatus,_that.contextFilters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AssistantMessageAuthor author,  String content,  DateTime createdAt,  bool isStreaming,  AssistantMessageDeliveryStatus deliveryStatus,  Set<AssistantFilter> contextFilters)  $default,) {final _that = this;
switch (_that) {
case _AssistantMessage():
return $default(_that.id,_that.author,_that.content,_that.createdAt,_that.isStreaming,_that.deliveryStatus,_that.contextFilters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AssistantMessageAuthor author,  String content,  DateTime createdAt,  bool isStreaming,  AssistantMessageDeliveryStatus deliveryStatus,  Set<AssistantFilter> contextFilters)?  $default,) {final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
return $default(_that.id,_that.author,_that.content,_that.createdAt,_that.isStreaming,_that.deliveryStatus,_that.contextFilters);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantMessage implements AssistantMessage {
  const _AssistantMessage({required this.id, required this.author, required this.content, required this.createdAt, this.isStreaming = false, this.deliveryStatus = AssistantMessageDeliveryStatus.delivered, final  Set<AssistantFilter> contextFilters = const <AssistantFilter>{}}): _contextFilters = contextFilters;
  

@override final  String id;
@override final  AssistantMessageAuthor author;
@override final  String content;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isStreaming;
@override@JsonKey() final  AssistantMessageDeliveryStatus deliveryStatus;
 final  Set<AssistantFilter> _contextFilters;
@override@JsonKey() Set<AssistantFilter> get contextFilters {
  if (_contextFilters is EqualUnmodifiableSetView) return _contextFilters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_contextFilters);
}


/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantMessageCopyWith<_AssistantMessage> get copyWith => __$AssistantMessageCopyWithImpl<_AssistantMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&(identical(other.deliveryStatus, deliveryStatus) || other.deliveryStatus == deliveryStatus)&&const DeepCollectionEquality().equals(other._contextFilters, _contextFilters));
}


@override
int get hashCode => Object.hash(runtimeType,id,author,content,createdAt,isStreaming,deliveryStatus,const DeepCollectionEquality().hash(_contextFilters));

@override
String toString() {
  return 'AssistantMessage(id: $id, author: $author, content: $content, createdAt: $createdAt, isStreaming: $isStreaming, deliveryStatus: $deliveryStatus, contextFilters: $contextFilters)';
}


}

/// @nodoc
abstract mixin class _$AssistantMessageCopyWith<$Res> implements $AssistantMessageCopyWith<$Res> {
  factory _$AssistantMessageCopyWith(_AssistantMessage value, $Res Function(_AssistantMessage) _then) = __$AssistantMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, AssistantMessageAuthor author, String content, DateTime createdAt, bool isStreaming, AssistantMessageDeliveryStatus deliveryStatus, Set<AssistantFilter> contextFilters
});




}
/// @nodoc
class __$AssistantMessageCopyWithImpl<$Res>
    implements _$AssistantMessageCopyWith<$Res> {
  __$AssistantMessageCopyWithImpl(this._self, this._then);

  final _AssistantMessage _self;
  final $Res Function(_AssistantMessage) _then;

/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? author = null,Object? content = null,Object? createdAt = null,Object? isStreaming = null,Object? deliveryStatus = null,Object? contextFilters = null,}) {
  return _then(_AssistantMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as AssistantMessageAuthor,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,deliveryStatus: null == deliveryStatus ? _self.deliveryStatus : deliveryStatus // ignore: cast_nullable_to_non_nullable
as AssistantMessageDeliveryStatus,contextFilters: null == contextFilters ? _self._contextFilters : contextFilters // ignore: cast_nullable_to_non_nullable
as Set<AssistantFilter>,
  ));
}


}

// dart format on
