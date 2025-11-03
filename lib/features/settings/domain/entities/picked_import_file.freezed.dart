// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'picked_import_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PickedImportFile {

 String get fileName; Uint8List get bytes;
/// Create a copy of PickedImportFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PickedImportFileCopyWith<PickedImportFile> get copyWith => _$PickedImportFileCopyWithImpl<PickedImportFile>(this as PickedImportFile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PickedImportFile&&(identical(other.fileName, fileName) || other.fileName == fileName)&&const DeepCollectionEquality().equals(other.bytes, bytes));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,const DeepCollectionEquality().hash(bytes));

@override
String toString() {
  return 'PickedImportFile(fileName: $fileName, bytes: $bytes)';
}


}

/// @nodoc
abstract mixin class $PickedImportFileCopyWith<$Res>  {
  factory $PickedImportFileCopyWith(PickedImportFile value, $Res Function(PickedImportFile) _then) = _$PickedImportFileCopyWithImpl;
@useResult
$Res call({
 String fileName, Uint8List bytes
});




}
/// @nodoc
class _$PickedImportFileCopyWithImpl<$Res>
    implements $PickedImportFileCopyWith<$Res> {
  _$PickedImportFileCopyWithImpl(this._self, this._then);

  final PickedImportFile _self;
  final $Res Function(PickedImportFile) _then;

/// Create a copy of PickedImportFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileName = null,Object? bytes = null,}) {
  return _then(_self.copyWith(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}

}


/// Adds pattern-matching-related methods to [PickedImportFile].
extension PickedImportFilePatterns on PickedImportFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PickedImportFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PickedImportFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PickedImportFile value)  $default,){
final _that = this;
switch (_that) {
case _PickedImportFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PickedImportFile value)?  $default,){
final _that = this;
switch (_that) {
case _PickedImportFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fileName,  Uint8List bytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PickedImportFile() when $default != null:
return $default(_that.fileName,_that.bytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fileName,  Uint8List bytes)  $default,) {final _that = this;
switch (_that) {
case _PickedImportFile():
return $default(_that.fileName,_that.bytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fileName,  Uint8List bytes)?  $default,) {final _that = this;
switch (_that) {
case _PickedImportFile() when $default != null:
return $default(_that.fileName,_that.bytes);case _:
  return null;

}
}

}

/// @nodoc


class _PickedImportFile implements PickedImportFile {
  const _PickedImportFile({required this.fileName, required this.bytes});
  

@override final  String fileName;
@override final  Uint8List bytes;

/// Create a copy of PickedImportFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PickedImportFileCopyWith<_PickedImportFile> get copyWith => __$PickedImportFileCopyWithImpl<_PickedImportFile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PickedImportFile&&(identical(other.fileName, fileName) || other.fileName == fileName)&&const DeepCollectionEquality().equals(other.bytes, bytes));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,const DeepCollectionEquality().hash(bytes));

@override
String toString() {
  return 'PickedImportFile(fileName: $fileName, bytes: $bytes)';
}


}

/// @nodoc
abstract mixin class _$PickedImportFileCopyWith<$Res> implements $PickedImportFileCopyWith<$Res> {
  factory _$PickedImportFileCopyWith(_PickedImportFile value, $Res Function(_PickedImportFile) _then) = __$PickedImportFileCopyWithImpl;
@override @useResult
$Res call({
 String fileName, Uint8List bytes
});




}
/// @nodoc
class __$PickedImportFileCopyWithImpl<$Res>
    implements _$PickedImportFileCopyWith<$Res> {
  __$PickedImportFileCopyWithImpl(this._self, this._then);

  final _PickedImportFile _self;
  final $Res Function(_PickedImportFile) _then;

/// Create a copy of PickedImportFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileName = null,Object? bytes = null,}) {
  return _then(_PickedImportFile(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}


}

// dart format on
