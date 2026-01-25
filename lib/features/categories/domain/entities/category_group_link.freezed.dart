// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_group_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryGroupLink {

 String get groupId; String get categoryId; DateTime get createdAt; DateTime get updatedAt; bool get isDeleted;
/// Create a copy of CategoryGroupLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryGroupLinkCopyWith<CategoryGroupLink> get copyWith => _$CategoryGroupLinkCopyWithImpl<CategoryGroupLink>(this as CategoryGroupLink, _$identity);

  /// Serializes this CategoryGroupLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryGroupLink&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,categoryId,createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'CategoryGroupLink(groupId: $groupId, categoryId: $categoryId, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $CategoryGroupLinkCopyWith<$Res>  {
  factory $CategoryGroupLinkCopyWith(CategoryGroupLink value, $Res Function(CategoryGroupLink) _then) = _$CategoryGroupLinkCopyWithImpl;
@useResult
$Res call({
 String groupId, String categoryId, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class _$CategoryGroupLinkCopyWithImpl<$Res>
    implements $CategoryGroupLinkCopyWith<$Res> {
  _$CategoryGroupLinkCopyWithImpl(this._self, this._then);

  final CategoryGroupLink _self;
  final $Res Function(CategoryGroupLink) _then;

/// Create a copy of CategoryGroupLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? categoryId = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryGroupLink].
extension CategoryGroupLinkPatterns on CategoryGroupLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryGroupLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryGroupLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryGroupLink value)  $default,){
final _that = this;
switch (_that) {
case _CategoryGroupLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryGroupLink value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryGroupLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String groupId,  String categoryId,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryGroupLink() when $default != null:
return $default(_that.groupId,_that.categoryId,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String groupId,  String categoryId,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _CategoryGroupLink():
return $default(_that.groupId,_that.categoryId,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String groupId,  String categoryId,  DateTime createdAt,  DateTime updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _CategoryGroupLink() when $default != null:
return $default(_that.groupId,_that.categoryId,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryGroupLink extends CategoryGroupLink {
  const _CategoryGroupLink({required this.groupId, required this.categoryId, required this.createdAt, required this.updatedAt, this.isDeleted = false}): super._();
  factory _CategoryGroupLink.fromJson(Map<String, dynamic> json) => _$CategoryGroupLinkFromJson(json);

@override final  String groupId;
@override final  String categoryId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of CategoryGroupLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryGroupLinkCopyWith<_CategoryGroupLink> get copyWith => __$CategoryGroupLinkCopyWithImpl<_CategoryGroupLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryGroupLinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryGroupLink&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,categoryId,createdAt,updatedAt,isDeleted);

@override
String toString() {
  return 'CategoryGroupLink(groupId: $groupId, categoryId: $categoryId, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$CategoryGroupLinkCopyWith<$Res> implements $CategoryGroupLinkCopyWith<$Res> {
  factory _$CategoryGroupLinkCopyWith(_CategoryGroupLink value, $Res Function(_CategoryGroupLink) _then) = __$CategoryGroupLinkCopyWithImpl;
@override @useResult
$Res call({
 String groupId, String categoryId, DateTime createdAt, DateTime updatedAt, bool isDeleted
});




}
/// @nodoc
class __$CategoryGroupLinkCopyWithImpl<$Res>
    implements _$CategoryGroupLinkCopyWith<$Res> {
  __$CategoryGroupLinkCopyWithImpl(this._self, this._then);

  final _CategoryGroupLink _self;
  final $Res Function(_CategoryGroupLink) _then;

/// Create a copy of CategoryGroupLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? categoryId = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_CategoryGroupLink(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
