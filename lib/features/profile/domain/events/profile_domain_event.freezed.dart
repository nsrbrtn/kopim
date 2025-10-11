// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_domain_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileDomainEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileDomainEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileDomainEvent()';
}


}

/// @nodoc
class $ProfileDomainEventCopyWith<$Res>  {
$ProfileDomainEventCopyWith(ProfileDomainEvent _, $Res Function(ProfileDomainEvent) __);
}


/// Adds pattern-matching-related methods to [ProfileDomainEvent].
extension ProfileDomainEventPatterns on ProfileDomainEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProfileUpdatedEvent value)?  profileUpdated,TResult Function( ProfileAvatarUpdatedEvent value)?  avatarUpdated,TResult Function( ProfileAvatarProcessingWarningEvent value)?  avatarProcessingWarning,TResult Function( ProfileLevelIncreasedEvent value)?  levelIncreased,TResult Function( ProfileProgressSyncFailedEvent value)?  progressSyncFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProfileUpdatedEvent() when profileUpdated != null:
return profileUpdated(_that);case ProfileAvatarUpdatedEvent() when avatarUpdated != null:
return avatarUpdated(_that);case ProfileAvatarProcessingWarningEvent() when avatarProcessingWarning != null:
return avatarProcessingWarning(_that);case ProfileLevelIncreasedEvent() when levelIncreased != null:
return levelIncreased(_that);case ProfileProgressSyncFailedEvent() when progressSyncFailed != null:
return progressSyncFailed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProfileUpdatedEvent value)  profileUpdated,required TResult Function( ProfileAvatarUpdatedEvent value)  avatarUpdated,required TResult Function( ProfileAvatarProcessingWarningEvent value)  avatarProcessingWarning,required TResult Function( ProfileLevelIncreasedEvent value)  levelIncreased,required TResult Function( ProfileProgressSyncFailedEvent value)  progressSyncFailed,}){
final _that = this;
switch (_that) {
case ProfileUpdatedEvent():
return profileUpdated(_that);case ProfileAvatarUpdatedEvent():
return avatarUpdated(_that);case ProfileAvatarProcessingWarningEvent():
return avatarProcessingWarning(_that);case ProfileLevelIncreasedEvent():
return levelIncreased(_that);case ProfileProgressSyncFailedEvent():
return progressSyncFailed(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProfileUpdatedEvent value)?  profileUpdated,TResult? Function( ProfileAvatarUpdatedEvent value)?  avatarUpdated,TResult? Function( ProfileAvatarProcessingWarningEvent value)?  avatarProcessingWarning,TResult? Function( ProfileLevelIncreasedEvent value)?  levelIncreased,TResult? Function( ProfileProgressSyncFailedEvent value)?  progressSyncFailed,}){
final _that = this;
switch (_that) {
case ProfileUpdatedEvent() when profileUpdated != null:
return profileUpdated(_that);case ProfileAvatarUpdatedEvent() when avatarUpdated != null:
return avatarUpdated(_that);case ProfileAvatarProcessingWarningEvent() when avatarProcessingWarning != null:
return avatarProcessingWarning(_that);case ProfileLevelIncreasedEvent() when levelIncreased != null:
return levelIncreased(_that);case ProfileProgressSyncFailedEvent() when progressSyncFailed != null:
return progressSyncFailed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Profile profile)?  profileUpdated,TResult Function( String uid,  AvatarImageSource source,  int sizeBytes,  bool offlineOnly)?  avatarUpdated,TResult Function( String message)?  avatarProcessingWarning,TResult Function( int previousLevel,  int newLevel,  int totalTransactions)?  levelIncreased,TResult Function( String uid,  Object error,  StackTrace stackTrace)?  progressSyncFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProfileUpdatedEvent() when profileUpdated != null:
return profileUpdated(_that.profile);case ProfileAvatarUpdatedEvent() when avatarUpdated != null:
return avatarUpdated(_that.uid,_that.source,_that.sizeBytes,_that.offlineOnly);case ProfileAvatarProcessingWarningEvent() when avatarProcessingWarning != null:
return avatarProcessingWarning(_that.message);case ProfileLevelIncreasedEvent() when levelIncreased != null:
return levelIncreased(_that.previousLevel,_that.newLevel,_that.totalTransactions);case ProfileProgressSyncFailedEvent() when progressSyncFailed != null:
return progressSyncFailed(_that.uid,_that.error,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Profile profile)  profileUpdated,required TResult Function( String uid,  AvatarImageSource source,  int sizeBytes,  bool offlineOnly)  avatarUpdated,required TResult Function( String message)  avatarProcessingWarning,required TResult Function( int previousLevel,  int newLevel,  int totalTransactions)  levelIncreased,required TResult Function( String uid,  Object error,  StackTrace stackTrace)  progressSyncFailed,}) {final _that = this;
switch (_that) {
case ProfileUpdatedEvent():
return profileUpdated(_that.profile);case ProfileAvatarUpdatedEvent():
return avatarUpdated(_that.uid,_that.source,_that.sizeBytes,_that.offlineOnly);case ProfileAvatarProcessingWarningEvent():
return avatarProcessingWarning(_that.message);case ProfileLevelIncreasedEvent():
return levelIncreased(_that.previousLevel,_that.newLevel,_that.totalTransactions);case ProfileProgressSyncFailedEvent():
return progressSyncFailed(_that.uid,_that.error,_that.stackTrace);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Profile profile)?  profileUpdated,TResult? Function( String uid,  AvatarImageSource source,  int sizeBytes,  bool offlineOnly)?  avatarUpdated,TResult? Function( String message)?  avatarProcessingWarning,TResult? Function( int previousLevel,  int newLevel,  int totalTransactions)?  levelIncreased,TResult? Function( String uid,  Object error,  StackTrace stackTrace)?  progressSyncFailed,}) {final _that = this;
switch (_that) {
case ProfileUpdatedEvent() when profileUpdated != null:
return profileUpdated(_that.profile);case ProfileAvatarUpdatedEvent() when avatarUpdated != null:
return avatarUpdated(_that.uid,_that.source,_that.sizeBytes,_that.offlineOnly);case ProfileAvatarProcessingWarningEvent() when avatarProcessingWarning != null:
return avatarProcessingWarning(_that.message);case ProfileLevelIncreasedEvent() when levelIncreased != null:
return levelIncreased(_that.previousLevel,_that.newLevel,_that.totalTransactions);case ProfileProgressSyncFailedEvent() when progressSyncFailed != null:
return progressSyncFailed(_that.uid,_that.error,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class ProfileUpdatedEvent implements ProfileDomainEvent {
  const ProfileUpdatedEvent({required this.profile});
  

 final  Profile profile;

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileUpdatedEventCopyWith<ProfileUpdatedEvent> get copyWith => _$ProfileUpdatedEventCopyWithImpl<ProfileUpdatedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUpdatedEvent&&(identical(other.profile, profile) || other.profile == profile));
}


@override
int get hashCode => Object.hash(runtimeType,profile);

@override
String toString() {
  return 'ProfileDomainEvent.profileUpdated(profile: $profile)';
}


}

/// @nodoc
abstract mixin class $ProfileUpdatedEventCopyWith<$Res> implements $ProfileDomainEventCopyWith<$Res> {
  factory $ProfileUpdatedEventCopyWith(ProfileUpdatedEvent value, $Res Function(ProfileUpdatedEvent) _then) = _$ProfileUpdatedEventCopyWithImpl;
@useResult
$Res call({
 Profile profile
});


$ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$ProfileUpdatedEventCopyWithImpl<$Res>
    implements $ProfileUpdatedEventCopyWith<$Res> {
  _$ProfileUpdatedEventCopyWithImpl(this._self, this._then);

  final ProfileUpdatedEvent _self;
  final $Res Function(ProfileUpdatedEvent) _then;

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? profile = null,}) {
  return _then(ProfileUpdatedEvent(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,
  ));
}

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get profile {
  
  return $ProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

/// @nodoc


class ProfileAvatarUpdatedEvent implements ProfileDomainEvent {
  const ProfileAvatarUpdatedEvent({required this.uid, required this.source, required this.sizeBytes, required this.offlineOnly});
  

 final  String uid;
 final  AvatarImageSource source;
 final  int sizeBytes;
 final  bool offlineOnly;

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileAvatarUpdatedEventCopyWith<ProfileAvatarUpdatedEvent> get copyWith => _$ProfileAvatarUpdatedEventCopyWithImpl<ProfileAvatarUpdatedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileAvatarUpdatedEvent&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.source, source) || other.source == source)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.offlineOnly, offlineOnly) || other.offlineOnly == offlineOnly));
}


@override
int get hashCode => Object.hash(runtimeType,uid,source,sizeBytes,offlineOnly);

@override
String toString() {
  return 'ProfileDomainEvent.avatarUpdated(uid: $uid, source: $source, sizeBytes: $sizeBytes, offlineOnly: $offlineOnly)';
}


}

/// @nodoc
abstract mixin class $ProfileAvatarUpdatedEventCopyWith<$Res> implements $ProfileDomainEventCopyWith<$Res> {
  factory $ProfileAvatarUpdatedEventCopyWith(ProfileAvatarUpdatedEvent value, $Res Function(ProfileAvatarUpdatedEvent) _then) = _$ProfileAvatarUpdatedEventCopyWithImpl;
@useResult
$Res call({
 String uid, AvatarImageSource source, int sizeBytes, bool offlineOnly
});




}
/// @nodoc
class _$ProfileAvatarUpdatedEventCopyWithImpl<$Res>
    implements $ProfileAvatarUpdatedEventCopyWith<$Res> {
  _$ProfileAvatarUpdatedEventCopyWithImpl(this._self, this._then);

  final ProfileAvatarUpdatedEvent _self;
  final $Res Function(ProfileAvatarUpdatedEvent) _then;

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? source = null,Object? sizeBytes = null,Object? offlineOnly = null,}) {
  return _then(ProfileAvatarUpdatedEvent(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AvatarImageSource,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,offlineOnly: null == offlineOnly ? _self.offlineOnly : offlineOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ProfileAvatarProcessingWarningEvent implements ProfileDomainEvent {
  const ProfileAvatarProcessingWarningEvent({required this.message});
  

 final  String message;

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileAvatarProcessingWarningEventCopyWith<ProfileAvatarProcessingWarningEvent> get copyWith => _$ProfileAvatarProcessingWarningEventCopyWithImpl<ProfileAvatarProcessingWarningEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileAvatarProcessingWarningEvent&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ProfileDomainEvent.avatarProcessingWarning(message: $message)';
}


}

/// @nodoc
abstract mixin class $ProfileAvatarProcessingWarningEventCopyWith<$Res> implements $ProfileDomainEventCopyWith<$Res> {
  factory $ProfileAvatarProcessingWarningEventCopyWith(ProfileAvatarProcessingWarningEvent value, $Res Function(ProfileAvatarProcessingWarningEvent) _then) = _$ProfileAvatarProcessingWarningEventCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ProfileAvatarProcessingWarningEventCopyWithImpl<$Res>
    implements $ProfileAvatarProcessingWarningEventCopyWith<$Res> {
  _$ProfileAvatarProcessingWarningEventCopyWithImpl(this._self, this._then);

  final ProfileAvatarProcessingWarningEvent _self;
  final $Res Function(ProfileAvatarProcessingWarningEvent) _then;

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ProfileAvatarProcessingWarningEvent(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ProfileLevelIncreasedEvent implements ProfileDomainEvent {
  const ProfileLevelIncreasedEvent({required this.previousLevel, required this.newLevel, required this.totalTransactions});
  

 final  int previousLevel;
 final  int newLevel;
 final  int totalTransactions;

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileLevelIncreasedEventCopyWith<ProfileLevelIncreasedEvent> get copyWith => _$ProfileLevelIncreasedEventCopyWithImpl<ProfileLevelIncreasedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLevelIncreasedEvent&&(identical(other.previousLevel, previousLevel) || other.previousLevel == previousLevel)&&(identical(other.newLevel, newLevel) || other.newLevel == newLevel)&&(identical(other.totalTransactions, totalTransactions) || other.totalTransactions == totalTransactions));
}


@override
int get hashCode => Object.hash(runtimeType,previousLevel,newLevel,totalTransactions);

@override
String toString() {
  return 'ProfileDomainEvent.levelIncreased(previousLevel: $previousLevel, newLevel: $newLevel, totalTransactions: $totalTransactions)';
}


}

/// @nodoc
abstract mixin class $ProfileLevelIncreasedEventCopyWith<$Res> implements $ProfileDomainEventCopyWith<$Res> {
  factory $ProfileLevelIncreasedEventCopyWith(ProfileLevelIncreasedEvent value, $Res Function(ProfileLevelIncreasedEvent) _then) = _$ProfileLevelIncreasedEventCopyWithImpl;
@useResult
$Res call({
 int previousLevel, int newLevel, int totalTransactions
});




}
/// @nodoc
class _$ProfileLevelIncreasedEventCopyWithImpl<$Res>
    implements $ProfileLevelIncreasedEventCopyWith<$Res> {
  _$ProfileLevelIncreasedEventCopyWithImpl(this._self, this._then);

  final ProfileLevelIncreasedEvent _self;
  final $Res Function(ProfileLevelIncreasedEvent) _then;

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? previousLevel = null,Object? newLevel = null,Object? totalTransactions = null,}) {
  return _then(ProfileLevelIncreasedEvent(
previousLevel: null == previousLevel ? _self.previousLevel : previousLevel // ignore: cast_nullable_to_non_nullable
as int,newLevel: null == newLevel ? _self.newLevel : newLevel // ignore: cast_nullable_to_non_nullable
as int,totalTransactions: null == totalTransactions ? _self.totalTransactions : totalTransactions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ProfileProgressSyncFailedEvent implements ProfileDomainEvent {
  const ProfileProgressSyncFailedEvent({required this.uid, required this.error, required this.stackTrace});
  

 final  String uid;
 final  Object error;
 final  StackTrace stackTrace;

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileProgressSyncFailedEventCopyWith<ProfileProgressSyncFailedEvent> get copyWith => _$ProfileProgressSyncFailedEventCopyWithImpl<ProfileProgressSyncFailedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileProgressSyncFailedEvent&&(identical(other.uid, uid) || other.uid == uid)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,uid,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'ProfileDomainEvent.progressSyncFailed(uid: $uid, error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $ProfileProgressSyncFailedEventCopyWith<$Res> implements $ProfileDomainEventCopyWith<$Res> {
  factory $ProfileProgressSyncFailedEventCopyWith(ProfileProgressSyncFailedEvent value, $Res Function(ProfileProgressSyncFailedEvent) _then) = _$ProfileProgressSyncFailedEventCopyWithImpl;
@useResult
$Res call({
 String uid, Object error, StackTrace stackTrace
});




}
/// @nodoc
class _$ProfileProgressSyncFailedEventCopyWithImpl<$Res>
    implements $ProfileProgressSyncFailedEventCopyWith<$Res> {
  _$ProfileProgressSyncFailedEventCopyWithImpl(this._self, this._then);

  final ProfileProgressSyncFailedEvent _self;
  final $Res Function(ProfileProgressSyncFailedEvent) _then;

/// Create a copy of ProfileDomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? error = null,Object? stackTrace = null,}) {
  return _then(ProfileProgressSyncFailedEvent(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error ,stackTrace: null == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace,
  ));
}


}

// dart format on
