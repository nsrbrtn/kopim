// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_dashboard_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeDashboardPreferences {

 bool get showGamificationWidget; bool get showBudgetWidget; bool get showRecurringWidget; bool get showSavingsWidget; String? get budgetId;
/// Create a copy of HomeDashboardPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeDashboardPreferencesCopyWith<HomeDashboardPreferences> get copyWith => _$HomeDashboardPreferencesCopyWithImpl<HomeDashboardPreferences>(this as HomeDashboardPreferences, _$identity);

  /// Serializes this HomeDashboardPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeDashboardPreferences&&(identical(other.showGamificationWidget, showGamificationWidget) || other.showGamificationWidget == showGamificationWidget)&&(identical(other.showBudgetWidget, showBudgetWidget) || other.showBudgetWidget == showBudgetWidget)&&(identical(other.showRecurringWidget, showRecurringWidget) || other.showRecurringWidget == showRecurringWidget)&&(identical(other.showSavingsWidget, showSavingsWidget) || other.showSavingsWidget == showSavingsWidget)&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showGamificationWidget,showBudgetWidget,showRecurringWidget,showSavingsWidget,budgetId);

@override
String toString() {
  return 'HomeDashboardPreferences(showGamificationWidget: $showGamificationWidget, showBudgetWidget: $showBudgetWidget, showRecurringWidget: $showRecurringWidget, showSavingsWidget: $showSavingsWidget, budgetId: $budgetId)';
}


}

/// @nodoc
abstract mixin class $HomeDashboardPreferencesCopyWith<$Res>  {
  factory $HomeDashboardPreferencesCopyWith(HomeDashboardPreferences value, $Res Function(HomeDashboardPreferences) _then) = _$HomeDashboardPreferencesCopyWithImpl;
@useResult
$Res call({
 bool showGamificationWidget, bool showBudgetWidget, bool showRecurringWidget, bool showSavingsWidget, String? budgetId
});




}
/// @nodoc
class _$HomeDashboardPreferencesCopyWithImpl<$Res>
    implements $HomeDashboardPreferencesCopyWith<$Res> {
  _$HomeDashboardPreferencesCopyWithImpl(this._self, this._then);

  final HomeDashboardPreferences _self;
  final $Res Function(HomeDashboardPreferences) _then;

/// Create a copy of HomeDashboardPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showGamificationWidget = null,Object? showBudgetWidget = null,Object? showRecurringWidget = null,Object? showSavingsWidget = null,Object? budgetId = freezed,}) {
  return _then(_self.copyWith(
showGamificationWidget: null == showGamificationWidget ? _self.showGamificationWidget : showGamificationWidget // ignore: cast_nullable_to_non_nullable
as bool,showBudgetWidget: null == showBudgetWidget ? _self.showBudgetWidget : showBudgetWidget // ignore: cast_nullable_to_non_nullable
as bool,showRecurringWidget: null == showRecurringWidget ? _self.showRecurringWidget : showRecurringWidget // ignore: cast_nullable_to_non_nullable
as bool,showSavingsWidget: null == showSavingsWidget ? _self.showSavingsWidget : showSavingsWidget // ignore: cast_nullable_to_non_nullable
as bool,budgetId: freezed == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeDashboardPreferences].
extension HomeDashboardPreferencesPatterns on HomeDashboardPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeDashboardPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeDashboardPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeDashboardPreferences value)  $default,){
final _that = this;
switch (_that) {
case _HomeDashboardPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeDashboardPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _HomeDashboardPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showGamificationWidget,  bool showBudgetWidget,  bool showRecurringWidget,  bool showSavingsWidget,  String? budgetId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeDashboardPreferences() when $default != null:
return $default(_that.showGamificationWidget,_that.showBudgetWidget,_that.showRecurringWidget,_that.showSavingsWidget,_that.budgetId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showGamificationWidget,  bool showBudgetWidget,  bool showRecurringWidget,  bool showSavingsWidget,  String? budgetId)  $default,) {final _that = this;
switch (_that) {
case _HomeDashboardPreferences():
return $default(_that.showGamificationWidget,_that.showBudgetWidget,_that.showRecurringWidget,_that.showSavingsWidget,_that.budgetId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showGamificationWidget,  bool showBudgetWidget,  bool showRecurringWidget,  bool showSavingsWidget,  String? budgetId)?  $default,) {final _that = this;
switch (_that) {
case _HomeDashboardPreferences() when $default != null:
return $default(_that.showGamificationWidget,_that.showBudgetWidget,_that.showRecurringWidget,_that.showSavingsWidget,_that.budgetId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeDashboardPreferences implements HomeDashboardPreferences {
  const _HomeDashboardPreferences({this.showGamificationWidget = false, this.showBudgetWidget = false, this.showRecurringWidget = false, this.showSavingsWidget = false, this.budgetId});
  factory _HomeDashboardPreferences.fromJson(Map<String, dynamic> json) => _$HomeDashboardPreferencesFromJson(json);

@override@JsonKey() final  bool showGamificationWidget;
@override@JsonKey() final  bool showBudgetWidget;
@override@JsonKey() final  bool showRecurringWidget;
@override@JsonKey() final  bool showSavingsWidget;
@override final  String? budgetId;

/// Create a copy of HomeDashboardPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeDashboardPreferencesCopyWith<_HomeDashboardPreferences> get copyWith => __$HomeDashboardPreferencesCopyWithImpl<_HomeDashboardPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeDashboardPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeDashboardPreferences&&(identical(other.showGamificationWidget, showGamificationWidget) || other.showGamificationWidget == showGamificationWidget)&&(identical(other.showBudgetWidget, showBudgetWidget) || other.showBudgetWidget == showBudgetWidget)&&(identical(other.showRecurringWidget, showRecurringWidget) || other.showRecurringWidget == showRecurringWidget)&&(identical(other.showSavingsWidget, showSavingsWidget) || other.showSavingsWidget == showSavingsWidget)&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showGamificationWidget,showBudgetWidget,showRecurringWidget,showSavingsWidget,budgetId);

@override
String toString() {
  return 'HomeDashboardPreferences(showGamificationWidget: $showGamificationWidget, showBudgetWidget: $showBudgetWidget, showRecurringWidget: $showRecurringWidget, showSavingsWidget: $showSavingsWidget, budgetId: $budgetId)';
}


}

/// @nodoc
abstract mixin class _$HomeDashboardPreferencesCopyWith<$Res> implements $HomeDashboardPreferencesCopyWith<$Res> {
  factory _$HomeDashboardPreferencesCopyWith(_HomeDashboardPreferences value, $Res Function(_HomeDashboardPreferences) _then) = __$HomeDashboardPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool showGamificationWidget, bool showBudgetWidget, bool showRecurringWidget, bool showSavingsWidget, String? budgetId
});




}
/// @nodoc
class __$HomeDashboardPreferencesCopyWithImpl<$Res>
    implements _$HomeDashboardPreferencesCopyWith<$Res> {
  __$HomeDashboardPreferencesCopyWithImpl(this._self, this._then);

  final _HomeDashboardPreferences _self;
  final $Res Function(_HomeDashboardPreferences) _then;

/// Create a copy of HomeDashboardPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showGamificationWidget = null,Object? showBudgetWidget = null,Object? showRecurringWidget = null,Object? showSavingsWidget = null,Object? budgetId = freezed,}) {
  return _then(_HomeDashboardPreferences(
showGamificationWidget: null == showGamificationWidget ? _self.showGamificationWidget : showGamificationWidget // ignore: cast_nullable_to_non_nullable
as bool,showBudgetWidget: null == showBudgetWidget ? _self.showBudgetWidget : showBudgetWidget // ignore: cast_nullable_to_non_nullable
as bool,showRecurringWidget: null == showRecurringWidget ? _self.showRecurringWidget : showRecurringWidget // ignore: cast_nullable_to_non_nullable
as bool,showSavingsWidget: null == showSavingsWidget ? _self.showSavingsWidget : showSavingsWidget // ignore: cast_nullable_to_non_nullable
as bool,budgetId: freezed == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
