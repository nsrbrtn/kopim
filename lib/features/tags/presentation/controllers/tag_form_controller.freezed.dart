// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TagFormState implements DiagnosticableTreeMixin {

 String get id; String get name; String get color; DateTime get createdAt; DateTime get updatedAt; TagEntity? get initialTag; bool get isSaving; bool get isSuccess; String? get errorMessage; bool get showValidationError; bool get isNew;
/// Create a copy of TagFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagFormStateCopyWith<TagFormState> get copyWith => _$TagFormStateCopyWithImpl<TagFormState>(this as TagFormState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TagFormState'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('color', color))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('initialTag', initialTag))..add(DiagnosticsProperty('isSaving', isSaving))..add(DiagnosticsProperty('isSuccess', isSuccess))..add(DiagnosticsProperty('errorMessage', errorMessage))..add(DiagnosticsProperty('showValidationError', showValidationError))..add(DiagnosticsProperty('isNew', isNew));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagFormState&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.initialTag, initialTag) || other.initialTag == initialTag)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.showValidationError, showValidationError) || other.showValidationError == showValidationError)&&(identical(other.isNew, isNew) || other.isNew == isNew));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,color,createdAt,updatedAt,initialTag,isSaving,isSuccess,errorMessage,showValidationError,isNew);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TagFormState(id: $id, name: $name, color: $color, createdAt: $createdAt, updatedAt: $updatedAt, initialTag: $initialTag, isSaving: $isSaving, isSuccess: $isSuccess, errorMessage: $errorMessage, showValidationError: $showValidationError, isNew: $isNew)';
}


}

/// @nodoc
abstract mixin class $TagFormStateCopyWith<$Res>  {
  factory $TagFormStateCopyWith(TagFormState value, $Res Function(TagFormState) _then) = _$TagFormStateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String color, DateTime createdAt, DateTime updatedAt, TagEntity? initialTag, bool isSaving, bool isSuccess, String? errorMessage, bool showValidationError, bool isNew
});


$TagEntityCopyWith<$Res>? get initialTag;

}
/// @nodoc
class _$TagFormStateCopyWithImpl<$Res>
    implements $TagFormStateCopyWith<$Res> {
  _$TagFormStateCopyWithImpl(this._self, this._then);

  final TagFormState _self;
  final $Res Function(TagFormState) _then;

/// Create a copy of TagFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = null,Object? createdAt = null,Object? updatedAt = null,Object? initialTag = freezed,Object? isSaving = null,Object? isSuccess = null,Object? errorMessage = freezed,Object? showValidationError = null,Object? isNew = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,initialTag: freezed == initialTag ? _self.initialTag : initialTag // ignore: cast_nullable_to_non_nullable
as TagEntity?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,showValidationError: null == showValidationError ? _self.showValidationError : showValidationError // ignore: cast_nullable_to_non_nullable
as bool,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TagFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TagEntityCopyWith<$Res>? get initialTag {
    if (_self.initialTag == null) {
    return null;
  }

  return $TagEntityCopyWith<$Res>(_self.initialTag!, (value) {
    return _then(_self.copyWith(initialTag: value));
  });
}
}


/// Adds pattern-matching-related methods to [TagFormState].
extension TagFormStatePatterns on TagFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagFormState value)  $default,){
final _that = this;
switch (_that) {
case _TagFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagFormState value)?  $default,){
final _that = this;
switch (_that) {
case _TagFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String color,  DateTime createdAt,  DateTime updatedAt,  TagEntity? initialTag,  bool isSaving,  bool isSuccess,  String? errorMessage,  bool showValidationError,  bool isNew)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagFormState() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.createdAt,_that.updatedAt,_that.initialTag,_that.isSaving,_that.isSuccess,_that.errorMessage,_that.showValidationError,_that.isNew);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String color,  DateTime createdAt,  DateTime updatedAt,  TagEntity? initialTag,  bool isSaving,  bool isSuccess,  String? errorMessage,  bool showValidationError,  bool isNew)  $default,) {final _that = this;
switch (_that) {
case _TagFormState():
return $default(_that.id,_that.name,_that.color,_that.createdAt,_that.updatedAt,_that.initialTag,_that.isSaving,_that.isSuccess,_that.errorMessage,_that.showValidationError,_that.isNew);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String color,  DateTime createdAt,  DateTime updatedAt,  TagEntity? initialTag,  bool isSaving,  bool isSuccess,  String? errorMessage,  bool showValidationError,  bool isNew)?  $default,) {final _that = this;
switch (_that) {
case _TagFormState() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.createdAt,_that.updatedAt,_that.initialTag,_that.isSaving,_that.isSuccess,_that.errorMessage,_that.showValidationError,_that.isNew);case _:
  return null;

}
}

}

/// @nodoc


class _TagFormState extends TagFormState with DiagnosticableTreeMixin {
  const _TagFormState({required this.id, required this.name, required this.color, required this.createdAt, required this.updatedAt, this.initialTag, this.isSaving = false, this.isSuccess = false, this.errorMessage, this.showValidationError = false, this.isNew = false}): super._();
  

@override final  String id;
@override final  String name;
@override final  String color;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  TagEntity? initialTag;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool isSuccess;
@override final  String? errorMessage;
@override@JsonKey() final  bool showValidationError;
@override@JsonKey() final  bool isNew;

/// Create a copy of TagFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagFormStateCopyWith<_TagFormState> get copyWith => __$TagFormStateCopyWithImpl<_TagFormState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TagFormState'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('color', color))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('initialTag', initialTag))..add(DiagnosticsProperty('isSaving', isSaving))..add(DiagnosticsProperty('isSuccess', isSuccess))..add(DiagnosticsProperty('errorMessage', errorMessage))..add(DiagnosticsProperty('showValidationError', showValidationError))..add(DiagnosticsProperty('isNew', isNew));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagFormState&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.initialTag, initialTag) || other.initialTag == initialTag)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.showValidationError, showValidationError) || other.showValidationError == showValidationError)&&(identical(other.isNew, isNew) || other.isNew == isNew));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,color,createdAt,updatedAt,initialTag,isSaving,isSuccess,errorMessage,showValidationError,isNew);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TagFormState(id: $id, name: $name, color: $color, createdAt: $createdAt, updatedAt: $updatedAt, initialTag: $initialTag, isSaving: $isSaving, isSuccess: $isSuccess, errorMessage: $errorMessage, showValidationError: $showValidationError, isNew: $isNew)';
}


}

/// @nodoc
abstract mixin class _$TagFormStateCopyWith<$Res> implements $TagFormStateCopyWith<$Res> {
  factory _$TagFormStateCopyWith(_TagFormState value, $Res Function(_TagFormState) _then) = __$TagFormStateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String color, DateTime createdAt, DateTime updatedAt, TagEntity? initialTag, bool isSaving, bool isSuccess, String? errorMessage, bool showValidationError, bool isNew
});


@override $TagEntityCopyWith<$Res>? get initialTag;

}
/// @nodoc
class __$TagFormStateCopyWithImpl<$Res>
    implements _$TagFormStateCopyWith<$Res> {
  __$TagFormStateCopyWithImpl(this._self, this._then);

  final _TagFormState _self;
  final $Res Function(_TagFormState) _then;

/// Create a copy of TagFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = null,Object? createdAt = null,Object? updatedAt = null,Object? initialTag = freezed,Object? isSaving = null,Object? isSuccess = null,Object? errorMessage = freezed,Object? showValidationError = null,Object? isNew = null,}) {
  return _then(_TagFormState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,initialTag: freezed == initialTag ? _self.initialTag : initialTag // ignore: cast_nullable_to_non_nullable
as TagEntity?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,showValidationError: null == showValidationError ? _self.showValidationError : showValidationError // ignore: cast_nullable_to_non_nullable
as bool,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TagFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TagEntityCopyWith<$Res>? get initialTag {
    if (_self.initialTag == null) {
    return null;
  }

  return $TagEntityCopyWith<$Res>(_self.initialTag!, (value) {
    return _then(_self.copyWith(initialTag: value));
  });
}
}

// dart format on
