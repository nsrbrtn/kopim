// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_tree_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryTreeNode {

 Category get category; List<CategoryTreeNode> get children;
/// Create a copy of CategoryTreeNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryTreeNodeCopyWith<CategoryTreeNode> get copyWith => _$CategoryTreeNodeCopyWithImpl<CategoryTreeNode>(this as CategoryTreeNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryTreeNode&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'CategoryTreeNode(category: $category, children: $children)';
}


}

/// @nodoc
abstract mixin class $CategoryTreeNodeCopyWith<$Res>  {
  factory $CategoryTreeNodeCopyWith(CategoryTreeNode value, $Res Function(CategoryTreeNode) _then) = _$CategoryTreeNodeCopyWithImpl;
@useResult
$Res call({
 Category category, List<CategoryTreeNode> children
});


$CategoryCopyWith<$Res> get category;

}
/// @nodoc
class _$CategoryTreeNodeCopyWithImpl<$Res>
    implements $CategoryTreeNodeCopyWith<$Res> {
  _$CategoryTreeNodeCopyWithImpl(this._self, this._then);

  final CategoryTreeNode _self;
  final $Res Function(CategoryTreeNode) _then;

/// Create a copy of CategoryTreeNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? children = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<CategoryTreeNode>,
  ));
}
/// Create a copy of CategoryTreeNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategoryTreeNode].
extension CategoryTreeNodePatterns on CategoryTreeNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryTreeNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryTreeNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryTreeNode value)  $default,){
final _that = this;
switch (_that) {
case _CategoryTreeNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryTreeNode value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryTreeNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Category category,  List<CategoryTreeNode> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryTreeNode() when $default != null:
return $default(_that.category,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Category category,  List<CategoryTreeNode> children)  $default,) {final _that = this;
switch (_that) {
case _CategoryTreeNode():
return $default(_that.category,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Category category,  List<CategoryTreeNode> children)?  $default,) {final _that = this;
switch (_that) {
case _CategoryTreeNode() when $default != null:
return $default(_that.category,_that.children);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryTreeNode implements CategoryTreeNode {
  const _CategoryTreeNode({required this.category, final  List<CategoryTreeNode> children = const <CategoryTreeNode>[]}): _children = children;
  

@override final  Category category;
 final  List<CategoryTreeNode> _children;
@override@JsonKey() List<CategoryTreeNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of CategoryTreeNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryTreeNodeCopyWith<_CategoryTreeNode> get copyWith => __$CategoryTreeNodeCopyWithImpl<_CategoryTreeNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryTreeNode&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'CategoryTreeNode(category: $category, children: $children)';
}


}

/// @nodoc
abstract mixin class _$CategoryTreeNodeCopyWith<$Res> implements $CategoryTreeNodeCopyWith<$Res> {
  factory _$CategoryTreeNodeCopyWith(_CategoryTreeNode value, $Res Function(_CategoryTreeNode) _then) = __$CategoryTreeNodeCopyWithImpl;
@override @useResult
$Res call({
 Category category, List<CategoryTreeNode> children
});


@override $CategoryCopyWith<$Res> get category;

}
/// @nodoc
class __$CategoryTreeNodeCopyWithImpl<$Res>
    implements _$CategoryTreeNodeCopyWith<$Res> {
  __$CategoryTreeNodeCopyWithImpl(this._self, this._then);

  final _CategoryTreeNode _self;
  final $Res Function(_CategoryTreeNode) _then;

/// Create a copy of CategoryTreeNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? children = null,}) {
  return _then(_CategoryTreeNode(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<CategoryTreeNode>,
  ));
}

/// Create a copy of CategoryTreeNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

// dart format on
