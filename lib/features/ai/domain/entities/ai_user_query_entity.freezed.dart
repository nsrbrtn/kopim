// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_user_query_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiUserQueryEntity {

 String get id; String get userId; String get content; List<String> get contextSignals; String? get locale; AiQueryIntent get intent; DateTime get createdAt;
/// Create a copy of AiUserQueryEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiUserQueryEntityCopyWith<AiUserQueryEntity> get copyWith => _$AiUserQueryEntityCopyWithImpl<AiUserQueryEntity>(this as AiUserQueryEntity, _$identity);

  /// Serializes this AiUserQueryEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiUserQueryEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.contextSignals, contextSignals)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,content,const DeepCollectionEquality().hash(contextSignals),locale,intent,createdAt);

@override
String toString() {
  return 'AiUserQueryEntity(id: $id, userId: $userId, content: $content, contextSignals: $contextSignals, locale: $locale, intent: $intent, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AiUserQueryEntityCopyWith<$Res>  {
  factory $AiUserQueryEntityCopyWith(AiUserQueryEntity value, $Res Function(AiUserQueryEntity) _then) = _$AiUserQueryEntityCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String content, List<String> contextSignals, String? locale, AiQueryIntent intent, DateTime createdAt
});




}
/// @nodoc
class _$AiUserQueryEntityCopyWithImpl<$Res>
    implements $AiUserQueryEntityCopyWith<$Res> {
  _$AiUserQueryEntityCopyWithImpl(this._self, this._then);

  final AiUserQueryEntity _self;
  final $Res Function(AiUserQueryEntity) _then;

/// Create a copy of AiUserQueryEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? content = null,Object? contextSignals = null,Object? locale = freezed,Object? intent = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,contextSignals: null == contextSignals ? _self.contextSignals : contextSignals // ignore: cast_nullable_to_non_nullable
as List<String>,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as AiQueryIntent,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AiUserQueryEntity].
extension AiUserQueryEntityPatterns on AiUserQueryEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiUserQueryEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiUserQueryEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiUserQueryEntity value)  $default,){
final _that = this;
switch (_that) {
case _AiUserQueryEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiUserQueryEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AiUserQueryEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String content,  List<String> contextSignals,  String? locale,  AiQueryIntent intent,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiUserQueryEntity() when $default != null:
return $default(_that.id,_that.userId,_that.content,_that.contextSignals,_that.locale,_that.intent,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String content,  List<String> contextSignals,  String? locale,  AiQueryIntent intent,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AiUserQueryEntity():
return $default(_that.id,_that.userId,_that.content,_that.contextSignals,_that.locale,_that.intent,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String content,  List<String> contextSignals,  String? locale,  AiQueryIntent intent,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AiUserQueryEntity() when $default != null:
return $default(_that.id,_that.userId,_that.content,_that.contextSignals,_that.locale,_that.intent,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiUserQueryEntity extends AiUserQueryEntity {
  const _AiUserQueryEntity({required this.id, required this.userId, required this.content, final  List<String> contextSignals = const <String>[], this.locale, this.intent = AiQueryIntent.unknown, required this.createdAt}): _contextSignals = contextSignals,super._();
  factory _AiUserQueryEntity.fromJson(Map<String, dynamic> json) => _$AiUserQueryEntityFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String content;
 final  List<String> _contextSignals;
@override@JsonKey() List<String> get contextSignals {
  if (_contextSignals is EqualUnmodifiableListView) return _contextSignals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contextSignals);
}

@override final  String? locale;
@override@JsonKey() final  AiQueryIntent intent;
@override final  DateTime createdAt;

/// Create a copy of AiUserQueryEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiUserQueryEntityCopyWith<_AiUserQueryEntity> get copyWith => __$AiUserQueryEntityCopyWithImpl<_AiUserQueryEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiUserQueryEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiUserQueryEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._contextSignals, _contextSignals)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,content,const DeepCollectionEquality().hash(_contextSignals),locale,intent,createdAt);

@override
String toString() {
  return 'AiUserQueryEntity(id: $id, userId: $userId, content: $content, contextSignals: $contextSignals, locale: $locale, intent: $intent, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AiUserQueryEntityCopyWith<$Res> implements $AiUserQueryEntityCopyWith<$Res> {
  factory _$AiUserQueryEntityCopyWith(_AiUserQueryEntity value, $Res Function(_AiUserQueryEntity) _then) = __$AiUserQueryEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String content, List<String> contextSignals, String? locale, AiQueryIntent intent, DateTime createdAt
});




}
/// @nodoc
class __$AiUserQueryEntityCopyWithImpl<$Res>
    implements _$AiUserQueryEntityCopyWith<$Res> {
  __$AiUserQueryEntityCopyWithImpl(this._self, this._then);

  final _AiUserQueryEntity _self;
  final $Res Function(_AiUserQueryEntity) _then;

/// Create a copy of AiUserQueryEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? content = null,Object? contextSignals = null,Object? locale = freezed,Object? intent = null,Object? createdAt = null,}) {
  return _then(_AiUserQueryEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,contextSignals: null == contextSignals ? _self._contextSignals : contextSignals // ignore: cast_nullable_to_non_nullable
as List<String>,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as AiQueryIntent,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
