// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_bundle_integrity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExportBundleIntegrity {

 String get format; String get contentHash; Map<String, String> get sectionHashes; Map<String, int> get entityCounts;
/// Create a copy of ExportBundleIntegrity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportBundleIntegrityCopyWith<ExportBundleIntegrity> get copyWith => _$ExportBundleIntegrityCopyWithImpl<ExportBundleIntegrity>(this as ExportBundleIntegrity, _$identity);

  /// Serializes this ExportBundleIntegrity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportBundleIntegrity&&(identical(other.format, format) || other.format == format)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&const DeepCollectionEquality().equals(other.sectionHashes, sectionHashes)&&const DeepCollectionEquality().equals(other.entityCounts, entityCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,contentHash,const DeepCollectionEquality().hash(sectionHashes),const DeepCollectionEquality().hash(entityCounts));

@override
String toString() {
  return 'ExportBundleIntegrity(format: $format, contentHash: $contentHash, sectionHashes: $sectionHashes, entityCounts: $entityCounts)';
}


}

/// @nodoc
abstract mixin class $ExportBundleIntegrityCopyWith<$Res>  {
  factory $ExportBundleIntegrityCopyWith(ExportBundleIntegrity value, $Res Function(ExportBundleIntegrity) _then) = _$ExportBundleIntegrityCopyWithImpl;
@useResult
$Res call({
 String format, String contentHash, Map<String, String> sectionHashes, Map<String, int> entityCounts
});




}
/// @nodoc
class _$ExportBundleIntegrityCopyWithImpl<$Res>
    implements $ExportBundleIntegrityCopyWith<$Res> {
  _$ExportBundleIntegrityCopyWithImpl(this._self, this._then);

  final ExportBundleIntegrity _self;
  final $Res Function(ExportBundleIntegrity) _then;

/// Create a copy of ExportBundleIntegrity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = null,Object? contentHash = null,Object? sectionHashes = null,Object? entityCounts = null,}) {
  return _then(_self.copyWith(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,contentHash: null == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String,sectionHashes: null == sectionHashes ? _self.sectionHashes : sectionHashes // ignore: cast_nullable_to_non_nullable
as Map<String, String>,entityCounts: null == entityCounts ? _self.entityCounts : entityCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportBundleIntegrity].
extension ExportBundleIntegrityPatterns on ExportBundleIntegrity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportBundleIntegrity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportBundleIntegrity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportBundleIntegrity value)  $default,){
final _that = this;
switch (_that) {
case _ExportBundleIntegrity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportBundleIntegrity value)?  $default,){
final _that = this;
switch (_that) {
case _ExportBundleIntegrity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String format,  String contentHash,  Map<String, String> sectionHashes,  Map<String, int> entityCounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportBundleIntegrity() when $default != null:
return $default(_that.format,_that.contentHash,_that.sectionHashes,_that.entityCounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String format,  String contentHash,  Map<String, String> sectionHashes,  Map<String, int> entityCounts)  $default,) {final _that = this;
switch (_that) {
case _ExportBundleIntegrity():
return $default(_that.format,_that.contentHash,_that.sectionHashes,_that.entityCounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String format,  String contentHash,  Map<String, String> sectionHashes,  Map<String, int> entityCounts)?  $default,) {final _that = this;
switch (_that) {
case _ExportBundleIntegrity() when $default != null:
return $default(_that.format,_that.contentHash,_that.sectionHashes,_that.entityCounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportBundleIntegrity extends ExportBundleIntegrity {
  const _ExportBundleIntegrity({required this.format, required this.contentHash, final  Map<String, String> sectionHashes = const <String, String>{}, final  Map<String, int> entityCounts = const <String, int>{}}): _sectionHashes = sectionHashes,_entityCounts = entityCounts,super._();
  factory _ExportBundleIntegrity.fromJson(Map<String, dynamic> json) => _$ExportBundleIntegrityFromJson(json);

@override final  String format;
@override final  String contentHash;
 final  Map<String, String> _sectionHashes;
@override@JsonKey() Map<String, String> get sectionHashes {
  if (_sectionHashes is EqualUnmodifiableMapView) return _sectionHashes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sectionHashes);
}

 final  Map<String, int> _entityCounts;
@override@JsonKey() Map<String, int> get entityCounts {
  if (_entityCounts is EqualUnmodifiableMapView) return _entityCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entityCounts);
}


/// Create a copy of ExportBundleIntegrity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportBundleIntegrityCopyWith<_ExportBundleIntegrity> get copyWith => __$ExportBundleIntegrityCopyWithImpl<_ExportBundleIntegrity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportBundleIntegrityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportBundleIntegrity&&(identical(other.format, format) || other.format == format)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&const DeepCollectionEquality().equals(other._sectionHashes, _sectionHashes)&&const DeepCollectionEquality().equals(other._entityCounts, _entityCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,contentHash,const DeepCollectionEquality().hash(_sectionHashes),const DeepCollectionEquality().hash(_entityCounts));

@override
String toString() {
  return 'ExportBundleIntegrity(format: $format, contentHash: $contentHash, sectionHashes: $sectionHashes, entityCounts: $entityCounts)';
}


}

/// @nodoc
abstract mixin class _$ExportBundleIntegrityCopyWith<$Res> implements $ExportBundleIntegrityCopyWith<$Res> {
  factory _$ExportBundleIntegrityCopyWith(_ExportBundleIntegrity value, $Res Function(_ExportBundleIntegrity) _then) = __$ExportBundleIntegrityCopyWithImpl;
@override @useResult
$Res call({
 String format, String contentHash, Map<String, String> sectionHashes, Map<String, int> entityCounts
});




}
/// @nodoc
class __$ExportBundleIntegrityCopyWithImpl<$Res>
    implements _$ExportBundleIntegrityCopyWith<$Res> {
  __$ExportBundleIntegrityCopyWithImpl(this._self, this._then);

  final _ExportBundleIntegrity _self;
  final $Res Function(_ExportBundleIntegrity) _then;

/// Create a copy of ExportBundleIntegrity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? contentHash = null,Object? sectionHashes = null,Object? entityCounts = null,}) {
  return _then(_ExportBundleIntegrity(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,contentHash: null == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String,sectionHashes: null == sectionHashes ? _self._sectionHashes : sectionHashes // ignore: cast_nullable_to_non_nullable
as Map<String, String>,entityCounts: null == entityCounts ? _self._entityCounts : entityCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
