// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exported_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExportedFile {

 String get fileName; String get mimeType; Uint8List get bytes;
/// Create a copy of ExportedFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportedFileCopyWith<ExportedFile> get copyWith => _$ExportedFileCopyWithImpl<ExportedFile>(this as ExportedFile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportedFile&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&const DeepCollectionEquality().equals(other.bytes, bytes));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,mimeType,const DeepCollectionEquality().hash(bytes));

@override
String toString() {
  return 'ExportedFile(fileName: $fileName, mimeType: $mimeType, bytes: $bytes)';
}


}

/// @nodoc
abstract mixin class $ExportedFileCopyWith<$Res>  {
  factory $ExportedFileCopyWith(ExportedFile value, $Res Function(ExportedFile) _then) = _$ExportedFileCopyWithImpl;
@useResult
$Res call({
 String fileName, String mimeType, Uint8List bytes
});




}
/// @nodoc
class _$ExportedFileCopyWithImpl<$Res>
    implements $ExportedFileCopyWith<$Res> {
  _$ExportedFileCopyWithImpl(this._self, this._then);

  final ExportedFile _self;
  final $Res Function(ExportedFile) _then;

/// Create a copy of ExportedFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileName = null,Object? mimeType = null,Object? bytes = null,}) {
  return _then(_self.copyWith(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportedFile].
extension ExportedFilePatterns on ExportedFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportedFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportedFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportedFile value)  $default,){
final _that = this;
switch (_that) {
case _ExportedFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportedFile value)?  $default,){
final _that = this;
switch (_that) {
case _ExportedFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fileName,  String mimeType,  Uint8List bytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportedFile() when $default != null:
return $default(_that.fileName,_that.mimeType,_that.bytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fileName,  String mimeType,  Uint8List bytes)  $default,) {final _that = this;
switch (_that) {
case _ExportedFile():
return $default(_that.fileName,_that.mimeType,_that.bytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fileName,  String mimeType,  Uint8List bytes)?  $default,) {final _that = this;
switch (_that) {
case _ExportedFile() when $default != null:
return $default(_that.fileName,_that.mimeType,_that.bytes);case _:
  return null;

}
}

}

/// @nodoc


class _ExportedFile extends ExportedFile {
  const _ExportedFile({required this.fileName, required this.mimeType, required this.bytes}): super._();
  

@override final  String fileName;
@override final  String mimeType;
@override final  Uint8List bytes;

/// Create a copy of ExportedFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportedFileCopyWith<_ExportedFile> get copyWith => __$ExportedFileCopyWithImpl<_ExportedFile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportedFile&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&const DeepCollectionEquality().equals(other.bytes, bytes));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,mimeType,const DeepCollectionEquality().hash(bytes));

@override
String toString() {
  return 'ExportedFile(fileName: $fileName, mimeType: $mimeType, bytes: $bytes)';
}


}

/// @nodoc
abstract mixin class _$ExportedFileCopyWith<$Res> implements $ExportedFileCopyWith<$Res> {
  factory _$ExportedFileCopyWith(_ExportedFile value, $Res Function(_ExportedFile) _then) = __$ExportedFileCopyWithImpl;
@override @useResult
$Res call({
 String fileName, String mimeType, Uint8List bytes
});




}
/// @nodoc
class __$ExportedFileCopyWithImpl<$Res>
    implements _$ExportedFileCopyWith<$Res> {
  __$ExportedFileCopyWithImpl(this._self, this._then);

  final _ExportedFile _self;
  final $Res Function(_ExportedFile) _then;

/// Create a copy of ExportedFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileName = null,Object? mimeType = null,Object? bytes = null,}) {
  return _then(_ExportedFile(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}


}

// dart format on
