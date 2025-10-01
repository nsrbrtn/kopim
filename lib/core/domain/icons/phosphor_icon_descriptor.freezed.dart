// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phosphor_icon_descriptor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhosphorIconDescriptor {

 String get name; PhosphorIconStyle get style;
/// Create a copy of PhosphorIconDescriptor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhosphorIconDescriptorCopyWith<PhosphorIconDescriptor> get copyWith => _$PhosphorIconDescriptorCopyWithImpl<PhosphorIconDescriptor>(this as PhosphorIconDescriptor, _$identity);

  /// Serializes this PhosphorIconDescriptor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhosphorIconDescriptor&&(identical(other.name, name) || other.name == name)&&(identical(other.style, style) || other.style == style));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,style);

@override
String toString() {
  return 'PhosphorIconDescriptor(name: $name, style: $style)';
}


}

/// @nodoc
abstract mixin class $PhosphorIconDescriptorCopyWith<$Res>  {
  factory $PhosphorIconDescriptorCopyWith(PhosphorIconDescriptor value, $Res Function(PhosphorIconDescriptor) _then) = _$PhosphorIconDescriptorCopyWithImpl;
@useResult
$Res call({
 String name, PhosphorIconStyle style
});




}
/// @nodoc
class _$PhosphorIconDescriptorCopyWithImpl<$Res>
    implements $PhosphorIconDescriptorCopyWith<$Res> {
  _$PhosphorIconDescriptorCopyWithImpl(this._self, this._then);

  final PhosphorIconDescriptor _self;
  final $Res Function(PhosphorIconDescriptor) _then;

/// Create a copy of PhosphorIconDescriptor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? style = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as PhosphorIconStyle,
  ));
}

}


/// Adds pattern-matching-related methods to [PhosphorIconDescriptor].
extension PhosphorIconDescriptorPatterns on PhosphorIconDescriptor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhosphorIconDescriptor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhosphorIconDescriptor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhosphorIconDescriptor value)  $default,){
final _that = this;
switch (_that) {
case _PhosphorIconDescriptor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhosphorIconDescriptor value)?  $default,){
final _that = this;
switch (_that) {
case _PhosphorIconDescriptor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  PhosphorIconStyle style)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhosphorIconDescriptor() when $default != null:
return $default(_that.name,_that.style);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  PhosphorIconStyle style)  $default,) {final _that = this;
switch (_that) {
case _PhosphorIconDescriptor():
return $default(_that.name,_that.style);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  PhosphorIconStyle style)?  $default,) {final _that = this;
switch (_that) {
case _PhosphorIconDescriptor() when $default != null:
return $default(_that.name,_that.style);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhosphorIconDescriptor extends PhosphorIconDescriptor {
  const _PhosphorIconDescriptor({required this.name, this.style = PhosphorIconStyle.regular}): super._();
  factory _PhosphorIconDescriptor.fromJson(Map<String, dynamic> json) => _$PhosphorIconDescriptorFromJson(json);

@override final  String name;
@override@JsonKey() final  PhosphorIconStyle style;

/// Create a copy of PhosphorIconDescriptor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhosphorIconDescriptorCopyWith<_PhosphorIconDescriptor> get copyWith => __$PhosphorIconDescriptorCopyWithImpl<_PhosphorIconDescriptor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhosphorIconDescriptorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhosphorIconDescriptor&&(identical(other.name, name) || other.name == name)&&(identical(other.style, style) || other.style == style));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,style);

@override
String toString() {
  return 'PhosphorIconDescriptor(name: $name, style: $style)';
}


}

/// @nodoc
abstract mixin class _$PhosphorIconDescriptorCopyWith<$Res> implements $PhosphorIconDescriptorCopyWith<$Res> {
  factory _$PhosphorIconDescriptorCopyWith(_PhosphorIconDescriptor value, $Res Function(_PhosphorIconDescriptor) _then) = __$PhosphorIconDescriptorCopyWithImpl;
@override @useResult
$Res call({
 String name, PhosphorIconStyle style
});




}
/// @nodoc
class __$PhosphorIconDescriptorCopyWithImpl<$Res>
    implements _$PhosphorIconDescriptorCopyWith<$Res> {
  __$PhosphorIconDescriptorCopyWithImpl(this._self, this._then);

  final _PhosphorIconDescriptor _self;
  final $Res Function(_PhosphorIconDescriptor) _then;

/// Create a copy of PhosphorIconDescriptor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? style = null,}) {
  return _then(_PhosphorIconDescriptor(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as PhosphorIconStyle,
  ));
}


}

// dart format on
