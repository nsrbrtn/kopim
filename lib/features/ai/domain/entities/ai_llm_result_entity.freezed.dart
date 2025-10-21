// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_llm_result_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiLlmResultEntity {

 String get id; String get queryId; String get content; List<String> get citedSources; double get confidence; Map<String, dynamic> get metadata; DateTime get createdAt; String? get model; int? get promptTokens; int? get completionTokens; int? get totalTokens;
/// Create a copy of AiLlmResultEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiLlmResultEntityCopyWith<AiLlmResultEntity> get copyWith => _$AiLlmResultEntityCopyWithImpl<AiLlmResultEntity>(this as AiLlmResultEntity, _$identity);

  /// Serializes this AiLlmResultEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiLlmResultEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.queryId, queryId) || other.queryId == queryId)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.citedSources, citedSources)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.model, model) || other.model == model)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,queryId,content,const DeepCollectionEquality().hash(citedSources),confidence,const DeepCollectionEquality().hash(metadata),createdAt,model,promptTokens,completionTokens,totalTokens);

@override
String toString() {
  return 'AiLlmResultEntity(id: $id, queryId: $queryId, content: $content, citedSources: $citedSources, confidence: $confidence, metadata: $metadata, createdAt: $createdAt, model: $model, promptTokens: $promptTokens, completionTokens: $completionTokens, totalTokens: $totalTokens)';
}


}

/// @nodoc
abstract mixin class $AiLlmResultEntityCopyWith<$Res>  {
  factory $AiLlmResultEntityCopyWith(AiLlmResultEntity value, $Res Function(AiLlmResultEntity) _then) = _$AiLlmResultEntityCopyWithImpl;
@useResult
$Res call({
 String id, String queryId, String content, List<String> citedSources, double confidence, Map<String, dynamic> metadata, DateTime createdAt, String? model, int? promptTokens, int? completionTokens, int? totalTokens
});




}
/// @nodoc
class _$AiLlmResultEntityCopyWithImpl<$Res>
    implements $AiLlmResultEntityCopyWith<$Res> {
  _$AiLlmResultEntityCopyWithImpl(this._self, this._then);

  final AiLlmResultEntity _self;
  final $Res Function(AiLlmResultEntity) _then;

/// Create a copy of AiLlmResultEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? queryId = null,Object? content = null,Object? citedSources = null,Object? confidence = null,Object? metadata = null,Object? createdAt = null,Object? model = freezed,Object? promptTokens = freezed,Object? completionTokens = freezed,Object? totalTokens = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,queryId: null == queryId ? _self.queryId : queryId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,citedSources: null == citedSources ? _self.citedSources : citedSources // ignore: cast_nullable_to_non_nullable
as List<String>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,promptTokens: freezed == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int?,completionTokens: freezed == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int?,totalTokens: freezed == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiLlmResultEntity].
extension AiLlmResultEntityPatterns on AiLlmResultEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiLlmResultEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiLlmResultEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiLlmResultEntity value)  $default,){
final _that = this;
switch (_that) {
case _AiLlmResultEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiLlmResultEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AiLlmResultEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String queryId,  String content,  List<String> citedSources,  double confidence,  Map<String, dynamic> metadata,  DateTime createdAt,  String? model,  int? promptTokens,  int? completionTokens,  int? totalTokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiLlmResultEntity() when $default != null:
return $default(_that.id,_that.queryId,_that.content,_that.citedSources,_that.confidence,_that.metadata,_that.createdAt,_that.model,_that.promptTokens,_that.completionTokens,_that.totalTokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String queryId,  String content,  List<String> citedSources,  double confidence,  Map<String, dynamic> metadata,  DateTime createdAt,  String? model,  int? promptTokens,  int? completionTokens,  int? totalTokens)  $default,) {final _that = this;
switch (_that) {
case _AiLlmResultEntity():
return $default(_that.id,_that.queryId,_that.content,_that.citedSources,_that.confidence,_that.metadata,_that.createdAt,_that.model,_that.promptTokens,_that.completionTokens,_that.totalTokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String queryId,  String content,  List<String> citedSources,  double confidence,  Map<String, dynamic> metadata,  DateTime createdAt,  String? model,  int? promptTokens,  int? completionTokens,  int? totalTokens)?  $default,) {final _that = this;
switch (_that) {
case _AiLlmResultEntity() when $default != null:
return $default(_that.id,_that.queryId,_that.content,_that.citedSources,_that.confidence,_that.metadata,_that.createdAt,_that.model,_that.promptTokens,_that.completionTokens,_that.totalTokens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiLlmResultEntity extends AiLlmResultEntity {
  const _AiLlmResultEntity({required this.id, required this.queryId, required this.content, final  List<String> citedSources = const <String>[], this.confidence = 0.0, final  Map<String, dynamic> metadata = const <String, dynamic>{}, required this.createdAt, this.model, this.promptTokens, this.completionTokens, this.totalTokens}): _citedSources = citedSources,_metadata = metadata,super._();
  factory _AiLlmResultEntity.fromJson(Map<String, dynamic> json) => _$AiLlmResultEntityFromJson(json);

@override final  String id;
@override final  String queryId;
@override final  String content;
 final  List<String> _citedSources;
@override@JsonKey() List<String> get citedSources {
  if (_citedSources is EqualUnmodifiableListView) return _citedSources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_citedSources);
}

@override@JsonKey() final  double confidence;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

@override final  DateTime createdAt;
@override final  String? model;
@override final  int? promptTokens;
@override final  int? completionTokens;
@override final  int? totalTokens;

/// Create a copy of AiLlmResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiLlmResultEntityCopyWith<_AiLlmResultEntity> get copyWith => __$AiLlmResultEntityCopyWithImpl<_AiLlmResultEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiLlmResultEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiLlmResultEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.queryId, queryId) || other.queryId == queryId)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._citedSources, _citedSources)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.model, model) || other.model == model)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,queryId,content,const DeepCollectionEquality().hash(_citedSources),confidence,const DeepCollectionEquality().hash(_metadata),createdAt,model,promptTokens,completionTokens,totalTokens);

@override
String toString() {
  return 'AiLlmResultEntity(id: $id, queryId: $queryId, content: $content, citedSources: $citedSources, confidence: $confidence, metadata: $metadata, createdAt: $createdAt, model: $model, promptTokens: $promptTokens, completionTokens: $completionTokens, totalTokens: $totalTokens)';
}


}

/// @nodoc
abstract mixin class _$AiLlmResultEntityCopyWith<$Res> implements $AiLlmResultEntityCopyWith<$Res> {
  factory _$AiLlmResultEntityCopyWith(_AiLlmResultEntity value, $Res Function(_AiLlmResultEntity) _then) = __$AiLlmResultEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String queryId, String content, List<String> citedSources, double confidence, Map<String, dynamic> metadata, DateTime createdAt, String? model, int? promptTokens, int? completionTokens, int? totalTokens
});




}
/// @nodoc
class __$AiLlmResultEntityCopyWithImpl<$Res>
    implements _$AiLlmResultEntityCopyWith<$Res> {
  __$AiLlmResultEntityCopyWithImpl(this._self, this._then);

  final _AiLlmResultEntity _self;
  final $Res Function(_AiLlmResultEntity) _then;

/// Create a copy of AiLlmResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? queryId = null,Object? content = null,Object? citedSources = null,Object? confidence = null,Object? metadata = null,Object? createdAt = null,Object? model = freezed,Object? promptTokens = freezed,Object? completionTokens = freezed,Object? totalTokens = freezed,}) {
  return _then(_AiLlmResultEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,queryId: null == queryId ? _self.queryId : queryId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,citedSources: null == citedSources ? _self._citedSources : citedSources // ignore: cast_nullable_to_non_nullable
as List<String>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,promptTokens: freezed == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int?,completionTokens: freezed == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int?,totalTokens: freezed == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
