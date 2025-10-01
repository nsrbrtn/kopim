// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryFormState implements DiagnosticableTreeMixin {

 String get id; String get name; String get type; PhosphorIconDescriptor? get icon; String get color; String? get parentId; String? get initialParentId; List<Category> get availableParents; DateTime get createdAt; DateTime get updatedAt; Category? get initialCategory; bool get isSaving; bool get isSuccess; String? get errorMessage; bool get showValidationError; bool get isNew;
/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryFormStateCopyWith<CategoryFormState> get copyWith => _$CategoryFormStateCopyWithImpl<CategoryFormState>(this as CategoryFormState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CategoryFormState'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('icon', icon))..add(DiagnosticsProperty('color', color))..add(DiagnosticsProperty('parentId', parentId))..add(DiagnosticsProperty('initialParentId', initialParentId))..add(DiagnosticsProperty('availableParents', availableParents))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('initialCategory', initialCategory))..add(DiagnosticsProperty('isSaving', isSaving))..add(DiagnosticsProperty('isSuccess', isSuccess))..add(DiagnosticsProperty('errorMessage', errorMessage))..add(DiagnosticsProperty('showValidationError', showValidationError))..add(DiagnosticsProperty('isNew', isNew));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryFormState&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.initialParentId, initialParentId) || other.initialParentId == initialParentId)&&const DeepCollectionEquality().equals(other.availableParents, availableParents)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.initialCategory, initialCategory)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.showValidationError, showValidationError) || other.showValidationError == showValidationError)&&(identical(other.isNew, isNew) || other.isNew == isNew));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,icon,color,parentId,initialParentId,const DeepCollectionEquality().hash(availableParents),createdAt,updatedAt,const DeepCollectionEquality().hash(initialCategory),isSaving,isSuccess,errorMessage,showValidationError,isNew);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CategoryFormState(id: $id, name: $name, type: $type, icon: $icon, color: $color, parentId: $parentId, initialParentId: $initialParentId, availableParents: $availableParents, createdAt: $createdAt, updatedAt: $updatedAt, initialCategory: $initialCategory, isSaving: $isSaving, isSuccess: $isSuccess, errorMessage: $errorMessage, showValidationError: $showValidationError, isNew: $isNew)';
}


}

/// @nodoc
abstract mixin class $CategoryFormStateCopyWith<$Res>  {
  factory $CategoryFormStateCopyWith(CategoryFormState value, $Res Function(CategoryFormState) _then) = _$CategoryFormStateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, PhosphorIconDescriptor? icon, String color, String? parentId, String? initialParentId, List<Category> availableParents, DateTime createdAt, DateTime updatedAt, Category? initialCategory, bool isSaving, bool isSuccess, String? errorMessage, bool showValidationError, bool isNew
});


$PhosphorIconDescriptorCopyWith<$Res>? get icon;

}
/// @nodoc
class _$CategoryFormStateCopyWithImpl<$Res>
    implements $CategoryFormStateCopyWith<$Res> {
  _$CategoryFormStateCopyWithImpl(this._self, this._then);

  final CategoryFormState _self;
  final $Res Function(CategoryFormState) _then;

/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? icon = freezed,Object? color = null,Object? parentId = freezed,Object? initialParentId = freezed,Object? availableParents = null,Object? createdAt = null,Object? updatedAt = null,Object? initialCategory = freezed,Object? isSaving = null,Object? isSuccess = null,Object? errorMessage = freezed,Object? showValidationError = null,Object? isNew = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as PhosphorIconDescriptor?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,initialParentId: freezed == initialParentId ? _self.initialParentId : initialParentId // ignore: cast_nullable_to_non_nullable
as String?,availableParents: null == availableParents ? _self.availableParents! : availableParents // ignore: cast_nullable_to_non_nullable
as List<Category>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,initialCategory: freezed == initialCategory ? _self.initialCategory! : initialCategory // ignore: cast_nullable_to_non_nullable
as Category?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,showValidationError: null == showValidationError ? _self.showValidationError : showValidationError // ignore: cast_nullable_to_non_nullable
as bool,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhosphorIconDescriptorCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $PhosphorIconDescriptorCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategoryFormState].
extension CategoryFormStatePatterns on CategoryFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryFormState value)  $default,){
final _that = this;
switch (_that) {
case _CategoryFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  PhosphorIconDescriptor? icon,  String color,  String? parentId,  String? initialParentId,  List<Category> availableParents,  DateTime createdAt,  DateTime updatedAt,  Category? initialCategory,  bool isSaving,  bool isSuccess,  String? errorMessage,  bool showValidationError,  bool isNew)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryFormState() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.parentId,_that.initialParentId,_that.availableParents,_that.createdAt,_that.updatedAt,_that.initialCategory,_that.isSaving,_that.isSuccess,_that.errorMessage,_that.showValidationError,_that.isNew);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  PhosphorIconDescriptor? icon,  String color,  String? parentId,  String? initialParentId,  List<Category> availableParents,  DateTime createdAt,  DateTime updatedAt,  Category? initialCategory,  bool isSaving,  bool isSuccess,  String? errorMessage,  bool showValidationError,  bool isNew)  $default,) {final _that = this;
switch (_that) {
case _CategoryFormState():
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.parentId,_that.initialParentId,_that.availableParents,_that.createdAt,_that.updatedAt,_that.initialCategory,_that.isSaving,_that.isSuccess,_that.errorMessage,_that.showValidationError,_that.isNew);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  PhosphorIconDescriptor? icon,  String color,  String? parentId,  String? initialParentId,  List<Category> availableParents,  DateTime createdAt,  DateTime updatedAt,  Category? initialCategory,  bool isSaving,  bool isSuccess,  String? errorMessage,  bool showValidationError,  bool isNew)?  $default,) {final _that = this;
switch (_that) {
case _CategoryFormState() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.parentId,_that.initialParentId,_that.availableParents,_that.createdAt,_that.updatedAt,_that.initialCategory,_that.isSaving,_that.isSuccess,_that.errorMessage,_that.showValidationError,_that.isNew);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryFormState extends CategoryFormState with DiagnosticableTreeMixin {
  const _CategoryFormState({required this.id, required this.name, required this.type, this.icon, this.color = '', this.parentId, this.initialParentId, final  List<Category> availableParents = const <Category>[], required this.createdAt, required this.updatedAt, this.initialCategory, this.isSaving = false, this.isSuccess = false, this.errorMessage, this.showValidationError = false, this.isNew = false}): _availableParents = availableParents,super._();
  

@override final  String id;
@override final  String name;
@override final  String type;
@override final  PhosphorIconDescriptor? icon;
@override@JsonKey() final  String color;
@override final  String? parentId;
@override final  String? initialParentId;
 final  List<Category> _availableParents;
@override@JsonKey() List<Category> get availableParents {
  if (_availableParents is EqualUnmodifiableListView) return _availableParents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableParents);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  Category? initialCategory;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool isSuccess;
@override final  String? errorMessage;
@override@JsonKey() final  bool showValidationError;
@override@JsonKey() final  bool isNew;

/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryFormStateCopyWith<_CategoryFormState> get copyWith => __$CategoryFormStateCopyWithImpl<_CategoryFormState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CategoryFormState'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('icon', icon))..add(DiagnosticsProperty('color', color))..add(DiagnosticsProperty('parentId', parentId))..add(DiagnosticsProperty('initialParentId', initialParentId))..add(DiagnosticsProperty('availableParents', availableParents))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('initialCategory', initialCategory))..add(DiagnosticsProperty('isSaving', isSaving))..add(DiagnosticsProperty('isSuccess', isSuccess))..add(DiagnosticsProperty('errorMessage', errorMessage))..add(DiagnosticsProperty('showValidationError', showValidationError))..add(DiagnosticsProperty('isNew', isNew));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryFormState&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.initialParentId, initialParentId) || other.initialParentId == initialParentId)&&const DeepCollectionEquality().equals(other._availableParents, _availableParents)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.initialCategory, initialCategory)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.showValidationError, showValidationError) || other.showValidationError == showValidationError)&&(identical(other.isNew, isNew) || other.isNew == isNew));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,icon,color,parentId,initialParentId,const DeepCollectionEquality().hash(_availableParents),createdAt,updatedAt,const DeepCollectionEquality().hash(initialCategory),isSaving,isSuccess,errorMessage,showValidationError,isNew);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CategoryFormState(id: $id, name: $name, type: $type, icon: $icon, color: $color, parentId: $parentId, initialParentId: $initialParentId, availableParents: $availableParents, createdAt: $createdAt, updatedAt: $updatedAt, initialCategory: $initialCategory, isSaving: $isSaving, isSuccess: $isSuccess, errorMessage: $errorMessage, showValidationError: $showValidationError, isNew: $isNew)';
}


}

/// @nodoc
abstract mixin class _$CategoryFormStateCopyWith<$Res> implements $CategoryFormStateCopyWith<$Res> {
  factory _$CategoryFormStateCopyWith(_CategoryFormState value, $Res Function(_CategoryFormState) _then) = __$CategoryFormStateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, PhosphorIconDescriptor? icon, String color, String? parentId, String? initialParentId, List<Category> availableParents, DateTime createdAt, DateTime updatedAt, Category? initialCategory, bool isSaving, bool isSuccess, String? errorMessage, bool showValidationError, bool isNew
});


@override $PhosphorIconDescriptorCopyWith<$Res>? get icon;

}
/// @nodoc
class __$CategoryFormStateCopyWithImpl<$Res>
    implements _$CategoryFormStateCopyWith<$Res> {
  __$CategoryFormStateCopyWithImpl(this._self, this._then);

  final _CategoryFormState _self;
  final $Res Function(_CategoryFormState) _then;

/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? icon = freezed,Object? color = null,Object? parentId = freezed,Object? initialParentId = freezed,Object? availableParents = null,Object? createdAt = null,Object? updatedAt = null,Object? initialCategory = freezed,Object? isSaving = null,Object? isSuccess = null,Object? errorMessage = freezed,Object? showValidationError = null,Object? isNew = null,}) {
  return _then(_CategoryFormState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as PhosphorIconDescriptor?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,initialParentId: freezed == initialParentId ? _self.initialParentId : initialParentId // ignore: cast_nullable_to_non_nullable
as String?,availableParents: null == availableParents ? _self._availableParents : availableParents // ignore: cast_nullable_to_non_nullable
as List<Category>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,initialCategory: freezed == initialCategory ? _self.initialCategory : initialCategory // ignore: cast_nullable_to_non_nullable
as Category?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,showValidationError: null == showValidationError ? _self.showValidationError : showValidationError // ignore: cast_nullable_to_non_nullable
as bool,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhosphorIconDescriptorCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $PhosphorIconDescriptorCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}
}

// dart format on
