// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantSessionState {

 List<AssistantMessage> get messages; AssistantMessage? get streamingMessage; bool get isSending; bool get isOffline; Set<AssistantFilter> get activeFilters; AssistantErrorType get lastError;
/// Create a copy of AssistantSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantSessionStateCopyWith<AssistantSessionState> get copyWith => _$AssistantSessionStateCopyWithImpl<AssistantSessionState>(this as AssistantSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantSessionState&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.streamingMessage, streamingMessage) || other.streamingMessage == streamingMessage)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.isOffline, isOffline) || other.isOffline == isOffline)&&const DeepCollectionEquality().equals(other.activeFilters, activeFilters)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),streamingMessage,isSending,isOffline,const DeepCollectionEquality().hash(activeFilters),lastError);

@override
String toString() {
  return 'AssistantSessionState(messages: $messages, streamingMessage: $streamingMessage, isSending: $isSending, isOffline: $isOffline, activeFilters: $activeFilters, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class $AssistantSessionStateCopyWith<$Res>  {
  factory $AssistantSessionStateCopyWith(AssistantSessionState value, $Res Function(AssistantSessionState) _then) = _$AssistantSessionStateCopyWithImpl;
@useResult
$Res call({
 List<AssistantMessage> messages, AssistantMessage? streamingMessage, bool isSending, bool isOffline, Set<AssistantFilter> activeFilters, AssistantErrorType lastError
});


$AssistantMessageCopyWith<$Res>? get streamingMessage;

}
/// @nodoc
class _$AssistantSessionStateCopyWithImpl<$Res>
    implements $AssistantSessionStateCopyWith<$Res> {
  _$AssistantSessionStateCopyWithImpl(this._self, this._then);

  final AssistantSessionState _self;
  final $Res Function(AssistantSessionState) _then;

/// Create a copy of AssistantSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? streamingMessage = freezed,Object? isSending = null,Object? isOffline = null,Object? activeFilters = null,Object? lastError = null,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<AssistantMessage>,streamingMessage: freezed == streamingMessage ? _self.streamingMessage : streamingMessage // ignore: cast_nullable_to_non_nullable
as AssistantMessage?,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,isOffline: null == isOffline ? _self.isOffline : isOffline // ignore: cast_nullable_to_non_nullable
as bool,activeFilters: null == activeFilters ? _self.activeFilters : activeFilters // ignore: cast_nullable_to_non_nullable
as Set<AssistantFilter>,lastError: null == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as AssistantErrorType,
  ));
}
/// Create a copy of AssistantSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssistantMessageCopyWith<$Res>? get streamingMessage {
    if (_self.streamingMessage == null) {
    return null;
  }

  return $AssistantMessageCopyWith<$Res>(_self.streamingMessage!, (value) {
    return _then(_self.copyWith(streamingMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [AssistantSessionState].
extension AssistantSessionStatePatterns on AssistantSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantSessionState value)  $default,){
final _that = this;
switch (_that) {
case _AssistantSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AssistantMessage> messages,  AssistantMessage? streamingMessage,  bool isSending,  bool isOffline,  Set<AssistantFilter> activeFilters,  AssistantErrorType lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantSessionState() when $default != null:
return $default(_that.messages,_that.streamingMessage,_that.isSending,_that.isOffline,_that.activeFilters,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AssistantMessage> messages,  AssistantMessage? streamingMessage,  bool isSending,  bool isOffline,  Set<AssistantFilter> activeFilters,  AssistantErrorType lastError)  $default,) {final _that = this;
switch (_that) {
case _AssistantSessionState():
return $default(_that.messages,_that.streamingMessage,_that.isSending,_that.isOffline,_that.activeFilters,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AssistantMessage> messages,  AssistantMessage? streamingMessage,  bool isSending,  bool isOffline,  Set<AssistantFilter> activeFilters,  AssistantErrorType lastError)?  $default,) {final _that = this;
switch (_that) {
case _AssistantSessionState() when $default != null:
return $default(_that.messages,_that.streamingMessage,_that.isSending,_that.isOffline,_that.activeFilters,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantSessionState implements AssistantSessionState {
  const _AssistantSessionState({final  List<AssistantMessage> messages = const <AssistantMessage>[], this.streamingMessage, this.isSending = false, this.isOffline = false, final  Set<AssistantFilter> activeFilters = const <AssistantFilter>{}, this.lastError = AssistantErrorType.none}): _messages = messages,_activeFilters = activeFilters;
  

 final  List<AssistantMessage> _messages;
@override@JsonKey() List<AssistantMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override final  AssistantMessage? streamingMessage;
@override@JsonKey() final  bool isSending;
@override@JsonKey() final  bool isOffline;
 final  Set<AssistantFilter> _activeFilters;
@override@JsonKey() Set<AssistantFilter> get activeFilters {
  if (_activeFilters is EqualUnmodifiableSetView) return _activeFilters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_activeFilters);
}

@override@JsonKey() final  AssistantErrorType lastError;

/// Create a copy of AssistantSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantSessionStateCopyWith<_AssistantSessionState> get copyWith => __$AssistantSessionStateCopyWithImpl<_AssistantSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantSessionState&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.streamingMessage, streamingMessage) || other.streamingMessage == streamingMessage)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.isOffline, isOffline) || other.isOffline == isOffline)&&const DeepCollectionEquality().equals(other._activeFilters, _activeFilters)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),streamingMessage,isSending,isOffline,const DeepCollectionEquality().hash(_activeFilters),lastError);

@override
String toString() {
  return 'AssistantSessionState(messages: $messages, streamingMessage: $streamingMessage, isSending: $isSending, isOffline: $isOffline, activeFilters: $activeFilters, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$AssistantSessionStateCopyWith<$Res> implements $AssistantSessionStateCopyWith<$Res> {
  factory _$AssistantSessionStateCopyWith(_AssistantSessionState value, $Res Function(_AssistantSessionState) _then) = __$AssistantSessionStateCopyWithImpl;
@override @useResult
$Res call({
 List<AssistantMessage> messages, AssistantMessage? streamingMessage, bool isSending, bool isOffline, Set<AssistantFilter> activeFilters, AssistantErrorType lastError
});


@override $AssistantMessageCopyWith<$Res>? get streamingMessage;

}
/// @nodoc
class __$AssistantSessionStateCopyWithImpl<$Res>
    implements _$AssistantSessionStateCopyWith<$Res> {
  __$AssistantSessionStateCopyWithImpl(this._self, this._then);

  final _AssistantSessionState _self;
  final $Res Function(_AssistantSessionState) _then;

/// Create a copy of AssistantSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? streamingMessage = freezed,Object? isSending = null,Object? isOffline = null,Object? activeFilters = null,Object? lastError = null,}) {
  return _then(_AssistantSessionState(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<AssistantMessage>,streamingMessage: freezed == streamingMessage ? _self.streamingMessage : streamingMessage // ignore: cast_nullable_to_non_nullable
as AssistantMessage?,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,isOffline: null == isOffline ? _self.isOffline : isOffline // ignore: cast_nullable_to_non_nullable
as bool,activeFilters: null == activeFilters ? _self._activeFilters : activeFilters // ignore: cast_nullable_to_non_nullable
as Set<AssistantFilter>,lastError: null == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as AssistantErrorType,
  ));
}

/// Create a copy of AssistantSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssistantMessageCopyWith<$Res>? get streamingMessage {
    if (_self.streamingMessage == null) {
    return null;
  }

  return $AssistantMessageCopyWith<$Res>(_self.streamingMessage!, (value) {
    return _then(_self.copyWith(streamingMessage: value));
  });
}
}

// dart format on
