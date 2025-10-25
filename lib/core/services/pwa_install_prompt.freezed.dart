// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pwa_install_prompt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PwaInstallPromptState implements DiagnosticableTreeMixin {

 bool get isSupported; bool get canPrompt; bool get isInstalled; DateTime? get lastPromptTime;
/// Create a copy of PwaInstallPromptState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PwaInstallPromptStateCopyWith<PwaInstallPromptState> get copyWith => _$PwaInstallPromptStateCopyWithImpl<PwaInstallPromptState>(this as PwaInstallPromptState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PwaInstallPromptState'))
    ..add(DiagnosticsProperty('isSupported', isSupported))..add(DiagnosticsProperty('canPrompt', canPrompt))..add(DiagnosticsProperty('isInstalled', isInstalled))..add(DiagnosticsProperty('lastPromptTime', lastPromptTime));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PwaInstallPromptState&&(identical(other.isSupported, isSupported) || other.isSupported == isSupported)&&(identical(other.canPrompt, canPrompt) || other.canPrompt == canPrompt)&&(identical(other.isInstalled, isInstalled) || other.isInstalled == isInstalled)&&(identical(other.lastPromptTime, lastPromptTime) || other.lastPromptTime == lastPromptTime));
}


@override
int get hashCode => Object.hash(runtimeType,isSupported,canPrompt,isInstalled,lastPromptTime);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PwaInstallPromptState(isSupported: $isSupported, canPrompt: $canPrompt, isInstalled: $isInstalled, lastPromptTime: $lastPromptTime)';
}


}

/// @nodoc
abstract mixin class $PwaInstallPromptStateCopyWith<$Res>  {
  factory $PwaInstallPromptStateCopyWith(PwaInstallPromptState value, $Res Function(PwaInstallPromptState) _then) = _$PwaInstallPromptStateCopyWithImpl;
@useResult
$Res call({
 bool isSupported, bool canPrompt, bool isInstalled, DateTime? lastPromptTime
});




}
/// @nodoc
class _$PwaInstallPromptStateCopyWithImpl<$Res>
    implements $PwaInstallPromptStateCopyWith<$Res> {
  _$PwaInstallPromptStateCopyWithImpl(this._self, this._then);

  final PwaInstallPromptState _self;
  final $Res Function(PwaInstallPromptState) _then;

/// Create a copy of PwaInstallPromptState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSupported = null,Object? canPrompt = null,Object? isInstalled = null,Object? lastPromptTime = freezed,}) {
  return _then(_self.copyWith(
isSupported: null == isSupported ? _self.isSupported : isSupported // ignore: cast_nullable_to_non_nullable
as bool,canPrompt: null == canPrompt ? _self.canPrompt : canPrompt // ignore: cast_nullable_to_non_nullable
as bool,isInstalled: null == isInstalled ? _self.isInstalled : isInstalled // ignore: cast_nullable_to_non_nullable
as bool,lastPromptTime: freezed == lastPromptTime ? _self.lastPromptTime : lastPromptTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PwaInstallPromptState].
extension PwaInstallPromptStatePatterns on PwaInstallPromptState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PwaInstallPromptState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PwaInstallPromptState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PwaInstallPromptState value)  $default,){
final _that = this;
switch (_that) {
case _PwaInstallPromptState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PwaInstallPromptState value)?  $default,){
final _that = this;
switch (_that) {
case _PwaInstallPromptState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSupported,  bool canPrompt,  bool isInstalled,  DateTime? lastPromptTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PwaInstallPromptState() when $default != null:
return $default(_that.isSupported,_that.canPrompt,_that.isInstalled,_that.lastPromptTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSupported,  bool canPrompt,  bool isInstalled,  DateTime? lastPromptTime)  $default,) {final _that = this;
switch (_that) {
case _PwaInstallPromptState():
return $default(_that.isSupported,_that.canPrompt,_that.isInstalled,_that.lastPromptTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSupported,  bool canPrompt,  bool isInstalled,  DateTime? lastPromptTime)?  $default,) {final _that = this;
switch (_that) {
case _PwaInstallPromptState() when $default != null:
return $default(_that.isSupported,_that.canPrompt,_that.isInstalled,_that.lastPromptTime);case _:
  return null;

}
}

}

/// @nodoc


class _PwaInstallPromptState with DiagnosticableTreeMixin implements PwaInstallPromptState {
  const _PwaInstallPromptState({this.isSupported = false, this.canPrompt = false, this.isInstalled = false, this.lastPromptTime});
  

@override@JsonKey() final  bool isSupported;
@override@JsonKey() final  bool canPrompt;
@override@JsonKey() final  bool isInstalled;
@override final  DateTime? lastPromptTime;

/// Create a copy of PwaInstallPromptState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PwaInstallPromptStateCopyWith<_PwaInstallPromptState> get copyWith => __$PwaInstallPromptStateCopyWithImpl<_PwaInstallPromptState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PwaInstallPromptState'))
    ..add(DiagnosticsProperty('isSupported', isSupported))..add(DiagnosticsProperty('canPrompt', canPrompt))..add(DiagnosticsProperty('isInstalled', isInstalled))..add(DiagnosticsProperty('lastPromptTime', lastPromptTime));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PwaInstallPromptState&&(identical(other.isSupported, isSupported) || other.isSupported == isSupported)&&(identical(other.canPrompt, canPrompt) || other.canPrompt == canPrompt)&&(identical(other.isInstalled, isInstalled) || other.isInstalled == isInstalled)&&(identical(other.lastPromptTime, lastPromptTime) || other.lastPromptTime == lastPromptTime));
}


@override
int get hashCode => Object.hash(runtimeType,isSupported,canPrompt,isInstalled,lastPromptTime);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PwaInstallPromptState(isSupported: $isSupported, canPrompt: $canPrompt, isInstalled: $isInstalled, lastPromptTime: $lastPromptTime)';
}


}

/// @nodoc
abstract mixin class _$PwaInstallPromptStateCopyWith<$Res> implements $PwaInstallPromptStateCopyWith<$Res> {
  factory _$PwaInstallPromptStateCopyWith(_PwaInstallPromptState value, $Res Function(_PwaInstallPromptState) _then) = __$PwaInstallPromptStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSupported, bool canPrompt, bool isInstalled, DateTime? lastPromptTime
});




}
/// @nodoc
class __$PwaInstallPromptStateCopyWithImpl<$Res>
    implements _$PwaInstallPromptStateCopyWith<$Res> {
  __$PwaInstallPromptStateCopyWithImpl(this._self, this._then);

  final _PwaInstallPromptState _self;
  final $Res Function(_PwaInstallPromptState) _then;

/// Create a copy of PwaInstallPromptState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSupported = null,Object? canPrompt = null,Object? isInstalled = null,Object? lastPromptTime = freezed,}) {
  return _then(_PwaInstallPromptState(
isSupported: null == isSupported ? _self.isSupported : isSupported // ignore: cast_nullable_to_non_nullable
as bool,canPrompt: null == canPrompt ? _self.canPrompt : canPrompt // ignore: cast_nullable_to_non_nullable
as bool,isInstalled: null == isInstalled ? _self.isInstalled : isInstalled // ignore: cast_nullable_to_non_nullable
as bool,lastPromptTime: freezed == lastPromptTime ? _self.lastPromptTime : lastPromptTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
