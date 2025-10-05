// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saving_goals_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SavingGoalsState {

 List<SavingGoal> get goals; bool get showArchived; bool get isLoading; String? get error;
/// Create a copy of SavingGoalsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingGoalsStateCopyWith<SavingGoalsState> get copyWith => _$SavingGoalsStateCopyWithImpl<SavingGoalsState>(this as SavingGoalsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingGoalsState&&const DeepCollectionEquality().equals(other.goals, goals)&&(identical(other.showArchived, showArchived) || other.showArchived == showArchived)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(goals),showArchived,isLoading,error);

@override
String toString() {
  return 'SavingGoalsState(goals: $goals, showArchived: $showArchived, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $SavingGoalsStateCopyWith<$Res>  {
  factory $SavingGoalsStateCopyWith(SavingGoalsState value, $Res Function(SavingGoalsState) _then) = _$SavingGoalsStateCopyWithImpl;
@useResult
$Res call({
 List<SavingGoal> goals, bool showArchived, bool isLoading, String? error
});




}
/// @nodoc
class _$SavingGoalsStateCopyWithImpl<$Res>
    implements $SavingGoalsStateCopyWith<$Res> {
  _$SavingGoalsStateCopyWithImpl(this._self, this._then);

  final SavingGoalsState _self;
  final $Res Function(SavingGoalsState) _then;

/// Create a copy of SavingGoalsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? goals = null,Object? showArchived = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as List<SavingGoal>,showArchived: null == showArchived ? _self.showArchived : showArchived // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingGoalsState].
extension SavingGoalsStatePatterns on SavingGoalsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingGoalsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingGoalsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingGoalsState value)  $default,){
final _that = this;
switch (_that) {
case _SavingGoalsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingGoalsState value)?  $default,){
final _that = this;
switch (_that) {
case _SavingGoalsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SavingGoal> goals,  bool showArchived,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingGoalsState() when $default != null:
return $default(_that.goals,_that.showArchived,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SavingGoal> goals,  bool showArchived,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _SavingGoalsState():
return $default(_that.goals,_that.showArchived,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SavingGoal> goals,  bool showArchived,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _SavingGoalsState() when $default != null:
return $default(_that.goals,_that.showArchived,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _SavingGoalsState implements SavingGoalsState {
  const _SavingGoalsState({final  List<SavingGoal> goals = const <SavingGoal>[], this.showArchived = false, this.isLoading = true, this.error}): _goals = goals;
  

 final  List<SavingGoal> _goals;
@override@JsonKey() List<SavingGoal> get goals {
  if (_goals is EqualUnmodifiableListView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goals);
}

@override@JsonKey() final  bool showArchived;
@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of SavingGoalsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingGoalsStateCopyWith<_SavingGoalsState> get copyWith => __$SavingGoalsStateCopyWithImpl<_SavingGoalsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingGoalsState&&const DeepCollectionEquality().equals(other._goals, _goals)&&(identical(other.showArchived, showArchived) || other.showArchived == showArchived)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_goals),showArchived,isLoading,error);

@override
String toString() {
  return 'SavingGoalsState(goals: $goals, showArchived: $showArchived, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$SavingGoalsStateCopyWith<$Res> implements $SavingGoalsStateCopyWith<$Res> {
  factory _$SavingGoalsStateCopyWith(_SavingGoalsState value, $Res Function(_SavingGoalsState) _then) = __$SavingGoalsStateCopyWithImpl;
@override @useResult
$Res call({
 List<SavingGoal> goals, bool showArchived, bool isLoading, String? error
});




}
/// @nodoc
class __$SavingGoalsStateCopyWithImpl<$Res>
    implements _$SavingGoalsStateCopyWith<$Res> {
  __$SavingGoalsStateCopyWithImpl(this._self, this._then);

  final _SavingGoalsState _self;
  final $Res Function(_SavingGoalsState) _then;

/// Create a copy of SavingGoalsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? goals = null,Object? showArchived = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_SavingGoalsState(
goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as List<SavingGoal>,showArchived: null == showArchived ? _self.showArchived : showArchived // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
