// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contribute_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContributeState {

 SavingGoal get goal; List<AccountEntity> get accounts; String? get selectedAccountId; String get amountInput; String? get amountError; String? get note; bool get isSubmitting; bool get success; String? get errorMessage;
/// Create a copy of ContributeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributeStateCopyWith<ContributeState> get copyWith => _$ContributeStateCopyWithImpl<ContributeState>(this as ContributeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributeState&&(identical(other.goal, goal) || other.goal == goal)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&(identical(other.selectedAccountId, selectedAccountId) || other.selectedAccountId == selectedAccountId)&&(identical(other.amountInput, amountInput) || other.amountInput == amountInput)&&(identical(other.amountError, amountError) || other.amountError == amountError)&&(identical(other.note, note) || other.note == note)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,goal,const DeepCollectionEquality().hash(accounts),selectedAccountId,amountInput,amountError,note,isSubmitting,success,errorMessage);

@override
String toString() {
  return 'ContributeState(goal: $goal, accounts: $accounts, selectedAccountId: $selectedAccountId, amountInput: $amountInput, amountError: $amountError, note: $note, isSubmitting: $isSubmitting, success: $success, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ContributeStateCopyWith<$Res>  {
  factory $ContributeStateCopyWith(ContributeState value, $Res Function(ContributeState) _then) = _$ContributeStateCopyWithImpl;
@useResult
$Res call({
 SavingGoal goal, List<AccountEntity> accounts, String? selectedAccountId, String amountInput, String? amountError, String? note, bool isSubmitting, bool success, String? errorMessage
});


$SavingGoalCopyWith<$Res> get goal;

}
/// @nodoc
class _$ContributeStateCopyWithImpl<$Res>
    implements $ContributeStateCopyWith<$Res> {
  _$ContributeStateCopyWithImpl(this._self, this._then);

  final ContributeState _self;
  final $Res Function(ContributeState) _then;

/// Create a copy of ContributeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? goal = null,Object? accounts = null,Object? selectedAccountId = freezed,Object? amountInput = null,Object? amountError = freezed,Object? note = freezed,Object? isSubmitting = null,Object? success = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as SavingGoal,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountEntity>,selectedAccountId: freezed == selectedAccountId ? _self.selectedAccountId : selectedAccountId // ignore: cast_nullable_to_non_nullable
as String?,amountInput: null == amountInput ? _self.amountInput : amountInput // ignore: cast_nullable_to_non_nullable
as String,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ContributeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavingGoalCopyWith<$Res> get goal {
  
  return $SavingGoalCopyWith<$Res>(_self.goal, (value) {
    return _then(_self.copyWith(goal: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContributeState].
extension ContributeStatePatterns on ContributeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributeState value)  $default,){
final _that = this;
switch (_that) {
case _ContributeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributeState value)?  $default,){
final _that = this;
switch (_that) {
case _ContributeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SavingGoal goal,  List<AccountEntity> accounts,  String? selectedAccountId,  String amountInput,  String? amountError,  String? note,  bool isSubmitting,  bool success,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributeState() when $default != null:
return $default(_that.goal,_that.accounts,_that.selectedAccountId,_that.amountInput,_that.amountError,_that.note,_that.isSubmitting,_that.success,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SavingGoal goal,  List<AccountEntity> accounts,  String? selectedAccountId,  String amountInput,  String? amountError,  String? note,  bool isSubmitting,  bool success,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ContributeState():
return $default(_that.goal,_that.accounts,_that.selectedAccountId,_that.amountInput,_that.amountError,_that.note,_that.isSubmitting,_that.success,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SavingGoal goal,  List<AccountEntity> accounts,  String? selectedAccountId,  String amountInput,  String? amountError,  String? note,  bool isSubmitting,  bool success,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ContributeState() when $default != null:
return $default(_that.goal,_that.accounts,_that.selectedAccountId,_that.amountInput,_that.amountError,_that.note,_that.isSubmitting,_that.success,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ContributeState implements ContributeState {
  const _ContributeState({required this.goal, final  List<AccountEntity> accounts = const <AccountEntity>[], this.selectedAccountId, this.amountInput = '', this.amountError, this.note, this.isSubmitting = false, this.success = false, this.errorMessage}): _accounts = accounts;
  

@override final  SavingGoal goal;
 final  List<AccountEntity> _accounts;
@override@JsonKey() List<AccountEntity> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

@override final  String? selectedAccountId;
@override@JsonKey() final  String amountInput;
@override final  String? amountError;
@override final  String? note;
@override@JsonKey() final  bool isSubmitting;
@override@JsonKey() final  bool success;
@override final  String? errorMessage;

/// Create a copy of ContributeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributeStateCopyWith<_ContributeState> get copyWith => __$ContributeStateCopyWithImpl<_ContributeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributeState&&(identical(other.goal, goal) || other.goal == goal)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&(identical(other.selectedAccountId, selectedAccountId) || other.selectedAccountId == selectedAccountId)&&(identical(other.amountInput, amountInput) || other.amountInput == amountInput)&&(identical(other.amountError, amountError) || other.amountError == amountError)&&(identical(other.note, note) || other.note == note)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,goal,const DeepCollectionEquality().hash(_accounts),selectedAccountId,amountInput,amountError,note,isSubmitting,success,errorMessage);

@override
String toString() {
  return 'ContributeState(goal: $goal, accounts: $accounts, selectedAccountId: $selectedAccountId, amountInput: $amountInput, amountError: $amountError, note: $note, isSubmitting: $isSubmitting, success: $success, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ContributeStateCopyWith<$Res> implements $ContributeStateCopyWith<$Res> {
  factory _$ContributeStateCopyWith(_ContributeState value, $Res Function(_ContributeState) _then) = __$ContributeStateCopyWithImpl;
@override @useResult
$Res call({
 SavingGoal goal, List<AccountEntity> accounts, String? selectedAccountId, String amountInput, String? amountError, String? note, bool isSubmitting, bool success, String? errorMessage
});


@override $SavingGoalCopyWith<$Res> get goal;

}
/// @nodoc
class __$ContributeStateCopyWithImpl<$Res>
    implements _$ContributeStateCopyWith<$Res> {
  __$ContributeStateCopyWithImpl(this._self, this._then);

  final _ContributeState _self;
  final $Res Function(_ContributeState) _then;

/// Create a copy of ContributeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? goal = null,Object? accounts = null,Object? selectedAccountId = freezed,Object? amountInput = null,Object? amountError = freezed,Object? note = freezed,Object? isSubmitting = null,Object? success = null,Object? errorMessage = freezed,}) {
  return _then(_ContributeState(
goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as SavingGoal,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountEntity>,selectedAccountId: freezed == selectedAccountId ? _self.selectedAccountId : selectedAccountId // ignore: cast_nullable_to_non_nullable
as String?,amountInput: null == amountInput ? _self.amountInput : amountInput // ignore: cast_nullable_to_non_nullable
as String,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ContributeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavingGoalCopyWith<$Res> get goal {
  
  return $SavingGoalCopyWith<$Res>(_self.goal, (value) {
    return _then(_self.copyWith(goal: value));
  });
}
}

// dart format on
