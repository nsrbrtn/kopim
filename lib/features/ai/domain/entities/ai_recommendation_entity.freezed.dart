// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_recommendation_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiRecommendationEntity {

 String get id; String get queryId; String get title; String get description; AiRecommendationType get type; List<String> get tags; List<AiRecommendationActionEntity> get actions; AiRecommendationImpact? get impact; double? get estimatedSavings; double? get estimatedIncomeIncrease; DateTime get createdAt; DateTime? get validUntil;
/// Create a copy of AiRecommendationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiRecommendationEntityCopyWith<AiRecommendationEntity> get copyWith => _$AiRecommendationEntityCopyWithImpl<AiRecommendationEntity>(this as AiRecommendationEntity, _$identity);

  /// Serializes this AiRecommendationEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiRecommendationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.queryId, queryId) || other.queryId == queryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.actions, actions)&&(identical(other.impact, impact) || other.impact == impact)&&(identical(other.estimatedSavings, estimatedSavings) || other.estimatedSavings == estimatedSavings)&&(identical(other.estimatedIncomeIncrease, estimatedIncomeIncrease) || other.estimatedIncomeIncrease == estimatedIncomeIncrease)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,queryId,title,description,type,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(actions),impact,estimatedSavings,estimatedIncomeIncrease,createdAt,validUntil);

@override
String toString() {
  return 'AiRecommendationEntity(id: $id, queryId: $queryId, title: $title, description: $description, type: $type, tags: $tags, actions: $actions, impact: $impact, estimatedSavings: $estimatedSavings, estimatedIncomeIncrease: $estimatedIncomeIncrease, createdAt: $createdAt, validUntil: $validUntil)';
}


}

/// @nodoc
abstract mixin class $AiRecommendationEntityCopyWith<$Res>  {
  factory $AiRecommendationEntityCopyWith(AiRecommendationEntity value, $Res Function(AiRecommendationEntity) _then) = _$AiRecommendationEntityCopyWithImpl;
@useResult
$Res call({
 String id, String queryId, String title, String description, AiRecommendationType type, List<String> tags, List<AiRecommendationActionEntity> actions, AiRecommendationImpact? impact, double? estimatedSavings, double? estimatedIncomeIncrease, DateTime createdAt, DateTime? validUntil
});


$AiRecommendationImpactCopyWith<$Res>? get impact;

}
/// @nodoc
class _$AiRecommendationEntityCopyWithImpl<$Res>
    implements $AiRecommendationEntityCopyWith<$Res> {
  _$AiRecommendationEntityCopyWithImpl(this._self, this._then);

  final AiRecommendationEntity _self;
  final $Res Function(AiRecommendationEntity) _then;

/// Create a copy of AiRecommendationEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? queryId = null,Object? title = null,Object? description = null,Object? type = null,Object? tags = null,Object? actions = null,Object? impact = freezed,Object? estimatedSavings = freezed,Object? estimatedIncomeIncrease = freezed,Object? createdAt = null,Object? validUntil = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,queryId: null == queryId ? _self.queryId : queryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AiRecommendationType,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<AiRecommendationActionEntity>,impact: freezed == impact ? _self.impact : impact // ignore: cast_nullable_to_non_nullable
as AiRecommendationImpact?,estimatedSavings: freezed == estimatedSavings ? _self.estimatedSavings : estimatedSavings // ignore: cast_nullable_to_non_nullable
as double?,estimatedIncomeIncrease: freezed == estimatedIncomeIncrease ? _self.estimatedIncomeIncrease : estimatedIncomeIncrease // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of AiRecommendationEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiRecommendationImpactCopyWith<$Res>? get impact {
    if (_self.impact == null) {
    return null;
  }

  return $AiRecommendationImpactCopyWith<$Res>(_self.impact!, (value) {
    return _then(_self.copyWith(impact: value));
  });
}
}


/// Adds pattern-matching-related methods to [AiRecommendationEntity].
extension AiRecommendationEntityPatterns on AiRecommendationEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiRecommendationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiRecommendationEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiRecommendationEntity value)  $default,){
final _that = this;
switch (_that) {
case _AiRecommendationEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiRecommendationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AiRecommendationEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String queryId,  String title,  String description,  AiRecommendationType type,  List<String> tags,  List<AiRecommendationActionEntity> actions,  AiRecommendationImpact? impact,  double? estimatedSavings,  double? estimatedIncomeIncrease,  DateTime createdAt,  DateTime? validUntil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiRecommendationEntity() when $default != null:
return $default(_that.id,_that.queryId,_that.title,_that.description,_that.type,_that.tags,_that.actions,_that.impact,_that.estimatedSavings,_that.estimatedIncomeIncrease,_that.createdAt,_that.validUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String queryId,  String title,  String description,  AiRecommendationType type,  List<String> tags,  List<AiRecommendationActionEntity> actions,  AiRecommendationImpact? impact,  double? estimatedSavings,  double? estimatedIncomeIncrease,  DateTime createdAt,  DateTime? validUntil)  $default,) {final _that = this;
switch (_that) {
case _AiRecommendationEntity():
return $default(_that.id,_that.queryId,_that.title,_that.description,_that.type,_that.tags,_that.actions,_that.impact,_that.estimatedSavings,_that.estimatedIncomeIncrease,_that.createdAt,_that.validUntil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String queryId,  String title,  String description,  AiRecommendationType type,  List<String> tags,  List<AiRecommendationActionEntity> actions,  AiRecommendationImpact? impact,  double? estimatedSavings,  double? estimatedIncomeIncrease,  DateTime createdAt,  DateTime? validUntil)?  $default,) {final _that = this;
switch (_that) {
case _AiRecommendationEntity() when $default != null:
return $default(_that.id,_that.queryId,_that.title,_that.description,_that.type,_that.tags,_that.actions,_that.impact,_that.estimatedSavings,_that.estimatedIncomeIncrease,_that.createdAt,_that.validUntil);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiRecommendationEntity extends AiRecommendationEntity {
  const _AiRecommendationEntity({required this.id, required this.queryId, required this.title, required this.description, this.type = AiRecommendationType.insight, final  List<String> tags = const <String>[], final  List<AiRecommendationActionEntity> actions = const <AiRecommendationActionEntity>[], this.impact, this.estimatedSavings, this.estimatedIncomeIncrease, required this.createdAt, this.validUntil}): _tags = tags,_actions = actions,super._();
  factory _AiRecommendationEntity.fromJson(Map<String, dynamic> json) => _$AiRecommendationEntityFromJson(json);

@override final  String id;
@override final  String queryId;
@override final  String title;
@override final  String description;
@override@JsonKey() final  AiRecommendationType type;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<AiRecommendationActionEntity> _actions;
@override@JsonKey() List<AiRecommendationActionEntity> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

@override final  AiRecommendationImpact? impact;
@override final  double? estimatedSavings;
@override final  double? estimatedIncomeIncrease;
@override final  DateTime createdAt;
@override final  DateTime? validUntil;

/// Create a copy of AiRecommendationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiRecommendationEntityCopyWith<_AiRecommendationEntity> get copyWith => __$AiRecommendationEntityCopyWithImpl<_AiRecommendationEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiRecommendationEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiRecommendationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.queryId, queryId) || other.queryId == queryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.impact, impact) || other.impact == impact)&&(identical(other.estimatedSavings, estimatedSavings) || other.estimatedSavings == estimatedSavings)&&(identical(other.estimatedIncomeIncrease, estimatedIncomeIncrease) || other.estimatedIncomeIncrease == estimatedIncomeIncrease)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,queryId,title,description,type,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_actions),impact,estimatedSavings,estimatedIncomeIncrease,createdAt,validUntil);

@override
String toString() {
  return 'AiRecommendationEntity(id: $id, queryId: $queryId, title: $title, description: $description, type: $type, tags: $tags, actions: $actions, impact: $impact, estimatedSavings: $estimatedSavings, estimatedIncomeIncrease: $estimatedIncomeIncrease, createdAt: $createdAt, validUntil: $validUntil)';
}


}

/// @nodoc
abstract mixin class _$AiRecommendationEntityCopyWith<$Res> implements $AiRecommendationEntityCopyWith<$Res> {
  factory _$AiRecommendationEntityCopyWith(_AiRecommendationEntity value, $Res Function(_AiRecommendationEntity) _then) = __$AiRecommendationEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String queryId, String title, String description, AiRecommendationType type, List<String> tags, List<AiRecommendationActionEntity> actions, AiRecommendationImpact? impact, double? estimatedSavings, double? estimatedIncomeIncrease, DateTime createdAt, DateTime? validUntil
});


@override $AiRecommendationImpactCopyWith<$Res>? get impact;

}
/// @nodoc
class __$AiRecommendationEntityCopyWithImpl<$Res>
    implements _$AiRecommendationEntityCopyWith<$Res> {
  __$AiRecommendationEntityCopyWithImpl(this._self, this._then);

  final _AiRecommendationEntity _self;
  final $Res Function(_AiRecommendationEntity) _then;

/// Create a copy of AiRecommendationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? queryId = null,Object? title = null,Object? description = null,Object? type = null,Object? tags = null,Object? actions = null,Object? impact = freezed,Object? estimatedSavings = freezed,Object? estimatedIncomeIncrease = freezed,Object? createdAt = null,Object? validUntil = freezed,}) {
  return _then(_AiRecommendationEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,queryId: null == queryId ? _self.queryId : queryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AiRecommendationType,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<AiRecommendationActionEntity>,impact: freezed == impact ? _self.impact : impact // ignore: cast_nullable_to_non_nullable
as AiRecommendationImpact?,estimatedSavings: freezed == estimatedSavings ? _self.estimatedSavings : estimatedSavings // ignore: cast_nullable_to_non_nullable
as double?,estimatedIncomeIncrease: freezed == estimatedIncomeIncrease ? _self.estimatedIncomeIncrease : estimatedIncomeIncrease // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of AiRecommendationEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiRecommendationImpactCopyWith<$Res>? get impact {
    if (_self.impact == null) {
    return null;
  }

  return $AiRecommendationImpactCopyWith<$Res>(_self.impact!, (value) {
    return _then(_self.copyWith(impact: value));
  });
}
}


/// @nodoc
mixin _$AiRecommendationActionEntity {

 String get actionId; String get label; Map<String, dynamic> get payload; String? get deepLink;
/// Create a copy of AiRecommendationActionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiRecommendationActionEntityCopyWith<AiRecommendationActionEntity> get copyWith => _$AiRecommendationActionEntityCopyWithImpl<AiRecommendationActionEntity>(this as AiRecommendationActionEntity, _$identity);

  /// Serializes this AiRecommendationActionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiRecommendationActionEntity&&(identical(other.actionId, actionId) || other.actionId == actionId)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,actionId,label,const DeepCollectionEquality().hash(payload),deepLink);

@override
String toString() {
  return 'AiRecommendationActionEntity(actionId: $actionId, label: $label, payload: $payload, deepLink: $deepLink)';
}


}

/// @nodoc
abstract mixin class $AiRecommendationActionEntityCopyWith<$Res>  {
  factory $AiRecommendationActionEntityCopyWith(AiRecommendationActionEntity value, $Res Function(AiRecommendationActionEntity) _then) = _$AiRecommendationActionEntityCopyWithImpl;
@useResult
$Res call({
 String actionId, String label, Map<String, dynamic> payload, String? deepLink
});




}
/// @nodoc
class _$AiRecommendationActionEntityCopyWithImpl<$Res>
    implements $AiRecommendationActionEntityCopyWith<$Res> {
  _$AiRecommendationActionEntityCopyWithImpl(this._self, this._then);

  final AiRecommendationActionEntity _self;
  final $Res Function(AiRecommendationActionEntity) _then;

/// Create a copy of AiRecommendationActionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actionId = null,Object? label = null,Object? payload = null,Object? deepLink = freezed,}) {
  return _then(_self.copyWith(
actionId: null == actionId ? _self.actionId : actionId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiRecommendationActionEntity].
extension AiRecommendationActionEntityPatterns on AiRecommendationActionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiRecommendationActionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiRecommendationActionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiRecommendationActionEntity value)  $default,){
final _that = this;
switch (_that) {
case _AiRecommendationActionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiRecommendationActionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AiRecommendationActionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String actionId,  String label,  Map<String, dynamic> payload,  String? deepLink)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiRecommendationActionEntity() when $default != null:
return $default(_that.actionId,_that.label,_that.payload,_that.deepLink);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String actionId,  String label,  Map<String, dynamic> payload,  String? deepLink)  $default,) {final _that = this;
switch (_that) {
case _AiRecommendationActionEntity():
return $default(_that.actionId,_that.label,_that.payload,_that.deepLink);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String actionId,  String label,  Map<String, dynamic> payload,  String? deepLink)?  $default,) {final _that = this;
switch (_that) {
case _AiRecommendationActionEntity() when $default != null:
return $default(_that.actionId,_that.label,_that.payload,_that.deepLink);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiRecommendationActionEntity extends AiRecommendationActionEntity {
  const _AiRecommendationActionEntity({required this.actionId, required this.label, final  Map<String, dynamic> payload = const <String, dynamic>{}, this.deepLink}): _payload = payload,super._();
  factory _AiRecommendationActionEntity.fromJson(Map<String, dynamic> json) => _$AiRecommendationActionEntityFromJson(json);

@override final  String actionId;
@override final  String label;
 final  Map<String, dynamic> _payload;
@override@JsonKey() Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  String? deepLink;

/// Create a copy of AiRecommendationActionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiRecommendationActionEntityCopyWith<_AiRecommendationActionEntity> get copyWith => __$AiRecommendationActionEntityCopyWithImpl<_AiRecommendationActionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiRecommendationActionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiRecommendationActionEntity&&(identical(other.actionId, actionId) || other.actionId == actionId)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,actionId,label,const DeepCollectionEquality().hash(_payload),deepLink);

@override
String toString() {
  return 'AiRecommendationActionEntity(actionId: $actionId, label: $label, payload: $payload, deepLink: $deepLink)';
}


}

/// @nodoc
abstract mixin class _$AiRecommendationActionEntityCopyWith<$Res> implements $AiRecommendationActionEntityCopyWith<$Res> {
  factory _$AiRecommendationActionEntityCopyWith(_AiRecommendationActionEntity value, $Res Function(_AiRecommendationActionEntity) _then) = __$AiRecommendationActionEntityCopyWithImpl;
@override @useResult
$Res call({
 String actionId, String label, Map<String, dynamic> payload, String? deepLink
});




}
/// @nodoc
class __$AiRecommendationActionEntityCopyWithImpl<$Res>
    implements _$AiRecommendationActionEntityCopyWith<$Res> {
  __$AiRecommendationActionEntityCopyWithImpl(this._self, this._then);

  final _AiRecommendationActionEntity _self;
  final $Res Function(_AiRecommendationActionEntity) _then;

/// Create a copy of AiRecommendationActionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actionId = null,Object? label = null,Object? payload = null,Object? deepLink = freezed,}) {
  return _then(_AiRecommendationActionEntity(
actionId: null == actionId ? _self.actionId : actionId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AiRecommendationImpact {

 double? get projectedSavings; double? get projectedIncome; double? get riskScore; String? get narrative;
/// Create a copy of AiRecommendationImpact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiRecommendationImpactCopyWith<AiRecommendationImpact> get copyWith => _$AiRecommendationImpactCopyWithImpl<AiRecommendationImpact>(this as AiRecommendationImpact, _$identity);

  /// Serializes this AiRecommendationImpact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiRecommendationImpact&&(identical(other.projectedSavings, projectedSavings) || other.projectedSavings == projectedSavings)&&(identical(other.projectedIncome, projectedIncome) || other.projectedIncome == projectedIncome)&&(identical(other.riskScore, riskScore) || other.riskScore == riskScore)&&(identical(other.narrative, narrative) || other.narrative == narrative));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,projectedSavings,projectedIncome,riskScore,narrative);

@override
String toString() {
  return 'AiRecommendationImpact(projectedSavings: $projectedSavings, projectedIncome: $projectedIncome, riskScore: $riskScore, narrative: $narrative)';
}


}

/// @nodoc
abstract mixin class $AiRecommendationImpactCopyWith<$Res>  {
  factory $AiRecommendationImpactCopyWith(AiRecommendationImpact value, $Res Function(AiRecommendationImpact) _then) = _$AiRecommendationImpactCopyWithImpl;
@useResult
$Res call({
 double? projectedSavings, double? projectedIncome, double? riskScore, String? narrative
});




}
/// @nodoc
class _$AiRecommendationImpactCopyWithImpl<$Res>
    implements $AiRecommendationImpactCopyWith<$Res> {
  _$AiRecommendationImpactCopyWithImpl(this._self, this._then);

  final AiRecommendationImpact _self;
  final $Res Function(AiRecommendationImpact) _then;

/// Create a copy of AiRecommendationImpact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? projectedSavings = freezed,Object? projectedIncome = freezed,Object? riskScore = freezed,Object? narrative = freezed,}) {
  return _then(_self.copyWith(
projectedSavings: freezed == projectedSavings ? _self.projectedSavings : projectedSavings // ignore: cast_nullable_to_non_nullable
as double?,projectedIncome: freezed == projectedIncome ? _self.projectedIncome : projectedIncome // ignore: cast_nullable_to_non_nullable
as double?,riskScore: freezed == riskScore ? _self.riskScore : riskScore // ignore: cast_nullable_to_non_nullable
as double?,narrative: freezed == narrative ? _self.narrative : narrative // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiRecommendationImpact].
extension AiRecommendationImpactPatterns on AiRecommendationImpact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiRecommendationImpact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiRecommendationImpact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiRecommendationImpact value)  $default,){
final _that = this;
switch (_that) {
case _AiRecommendationImpact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiRecommendationImpact value)?  $default,){
final _that = this;
switch (_that) {
case _AiRecommendationImpact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? projectedSavings,  double? projectedIncome,  double? riskScore,  String? narrative)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiRecommendationImpact() when $default != null:
return $default(_that.projectedSavings,_that.projectedIncome,_that.riskScore,_that.narrative);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? projectedSavings,  double? projectedIncome,  double? riskScore,  String? narrative)  $default,) {final _that = this;
switch (_that) {
case _AiRecommendationImpact():
return $default(_that.projectedSavings,_that.projectedIncome,_that.riskScore,_that.narrative);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? projectedSavings,  double? projectedIncome,  double? riskScore,  String? narrative)?  $default,) {final _that = this;
switch (_that) {
case _AiRecommendationImpact() when $default != null:
return $default(_that.projectedSavings,_that.projectedIncome,_that.riskScore,_that.narrative);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiRecommendationImpact extends AiRecommendationImpact {
  const _AiRecommendationImpact({this.projectedSavings, this.projectedIncome, this.riskScore, this.narrative}): super._();
  factory _AiRecommendationImpact.fromJson(Map<String, dynamic> json) => _$AiRecommendationImpactFromJson(json);

@override final  double? projectedSavings;
@override final  double? projectedIncome;
@override final  double? riskScore;
@override final  String? narrative;

/// Create a copy of AiRecommendationImpact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiRecommendationImpactCopyWith<_AiRecommendationImpact> get copyWith => __$AiRecommendationImpactCopyWithImpl<_AiRecommendationImpact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiRecommendationImpactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiRecommendationImpact&&(identical(other.projectedSavings, projectedSavings) || other.projectedSavings == projectedSavings)&&(identical(other.projectedIncome, projectedIncome) || other.projectedIncome == projectedIncome)&&(identical(other.riskScore, riskScore) || other.riskScore == riskScore)&&(identical(other.narrative, narrative) || other.narrative == narrative));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,projectedSavings,projectedIncome,riskScore,narrative);

@override
String toString() {
  return 'AiRecommendationImpact(projectedSavings: $projectedSavings, projectedIncome: $projectedIncome, riskScore: $riskScore, narrative: $narrative)';
}


}

/// @nodoc
abstract mixin class _$AiRecommendationImpactCopyWith<$Res> implements $AiRecommendationImpactCopyWith<$Res> {
  factory _$AiRecommendationImpactCopyWith(_AiRecommendationImpact value, $Res Function(_AiRecommendationImpact) _then) = __$AiRecommendationImpactCopyWithImpl;
@override @useResult
$Res call({
 double? projectedSavings, double? projectedIncome, double? riskScore, String? narrative
});




}
/// @nodoc
class __$AiRecommendationImpactCopyWithImpl<$Res>
    implements _$AiRecommendationImpactCopyWith<$Res> {
  __$AiRecommendationImpactCopyWithImpl(this._self, this._then);

  final _AiRecommendationImpact _self;
  final $Res Function(_AiRecommendationImpact) _then;

/// Create a copy of AiRecommendationImpact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? projectedSavings = freezed,Object? projectedIncome = freezed,Object? riskScore = freezed,Object? narrative = freezed,}) {
  return _then(_AiRecommendationImpact(
projectedSavings: freezed == projectedSavings ? _self.projectedSavings : projectedSavings // ignore: cast_nullable_to_non_nullable
as double?,projectedIncome: freezed == projectedIncome ? _self.projectedIncome : projectedIncome // ignore: cast_nullable_to_non_nullable
as double?,riskScore: freezed == riskScore ? _self.riskScore : riskScore // ignore: cast_nullable_to_non_nullable
as double?,narrative: freezed == narrative ? _self.narrative : narrative // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
