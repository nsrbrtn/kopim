// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'overview_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OverviewPreferences {

 List<String>? get accountIds; List<String>? get categoryIds;
/// Create a copy of OverviewPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverviewPreferencesCopyWith<OverviewPreferences> get copyWith => _$OverviewPreferencesCopyWithImpl<OverviewPreferences>(this as OverviewPreferences, _$identity);

  /// Serializes this OverviewPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverviewPreferences&&const DeepCollectionEquality().equals(other.accountIds, accountIds)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(accountIds),const DeepCollectionEquality().hash(categoryIds));

@override
String toString() {
  return 'OverviewPreferences(accountIds: $accountIds, categoryIds: $categoryIds)';
}


}

/// @nodoc
abstract mixin class $OverviewPreferencesCopyWith<$Res>  {
  factory $OverviewPreferencesCopyWith(OverviewPreferences value, $Res Function(OverviewPreferences) _then) = _$OverviewPreferencesCopyWithImpl;
@useResult
$Res call({
 List<String>? accountIds, List<String>? categoryIds
});




}
/// @nodoc
class _$OverviewPreferencesCopyWithImpl<$Res>
    implements $OverviewPreferencesCopyWith<$Res> {
  _$OverviewPreferencesCopyWithImpl(this._self, this._then);

  final OverviewPreferences _self;
  final $Res Function(OverviewPreferences) _then;

/// Create a copy of OverviewPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountIds = freezed,Object? categoryIds = freezed,}) {
  return _then(_self.copyWith(
accountIds: freezed == accountIds ? _self.accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as List<String>?,categoryIds: freezed == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [OverviewPreferences].
extension OverviewPreferencesPatterns on OverviewPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OverviewPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OverviewPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OverviewPreferences value)  $default,){
final _that = this;
switch (_that) {
case _OverviewPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OverviewPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _OverviewPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String>? accountIds,  List<String>? categoryIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverviewPreferences() when $default != null:
return $default(_that.accountIds,_that.categoryIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String>? accountIds,  List<String>? categoryIds)  $default,) {final _that = this;
switch (_that) {
case _OverviewPreferences():
return $default(_that.accountIds,_that.categoryIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String>? accountIds,  List<String>? categoryIds)?  $default,) {final _that = this;
switch (_that) {
case _OverviewPreferences() when $default != null:
return $default(_that.accountIds,_that.categoryIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OverviewPreferences extends OverviewPreferences {
  const _OverviewPreferences({final  List<String>? accountIds, final  List<String>? categoryIds}): _accountIds = accountIds,_categoryIds = categoryIds,super._();
  factory _OverviewPreferences.fromJson(Map<String, dynamic> json) => _$OverviewPreferencesFromJson(json);

 final  List<String>? _accountIds;
@override List<String>? get accountIds {
  final value = _accountIds;
  if (value == null) return null;
  if (_accountIds is EqualUnmodifiableListView) return _accountIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _categoryIds;
@override List<String>? get categoryIds {
  final value = _categoryIds;
  if (value == null) return null;
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of OverviewPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverviewPreferencesCopyWith<_OverviewPreferences> get copyWith => __$OverviewPreferencesCopyWithImpl<_OverviewPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OverviewPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverviewPreferences&&const DeepCollectionEquality().equals(other._accountIds, _accountIds)&&const DeepCollectionEquality().equals(other._categoryIds, _categoryIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_accountIds),const DeepCollectionEquality().hash(_categoryIds));

@override
String toString() {
  return 'OverviewPreferences(accountIds: $accountIds, categoryIds: $categoryIds)';
}


}

/// @nodoc
abstract mixin class _$OverviewPreferencesCopyWith<$Res> implements $OverviewPreferencesCopyWith<$Res> {
  factory _$OverviewPreferencesCopyWith(_OverviewPreferences value, $Res Function(_OverviewPreferences) _then) = __$OverviewPreferencesCopyWithImpl;
@override @useResult
$Res call({
 List<String>? accountIds, List<String>? categoryIds
});




}
/// @nodoc
class __$OverviewPreferencesCopyWithImpl<$Res>
    implements _$OverviewPreferencesCopyWith<$Res> {
  __$OverviewPreferencesCopyWithImpl(this._self, this._then);

  final _OverviewPreferences _self;
  final $Res Function(_OverviewPreferences) _then;

/// Create a copy of OverviewPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountIds = freezed,Object? categoryIds = freezed,}) {
  return _then(_OverviewPreferences(
accountIds: freezed == accountIds ? _self._accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as List<String>?,categoryIds: freezed == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
