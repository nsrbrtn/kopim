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

 SavingGoal get goal; List<AccountEntity> get accounts; List<AccountEntity> get goalStorageAccounts; String? get selectedAccountId; String? get selectedStorageAccountId; String? get goalAccountCurrency; String get amountInput; String? get amountError; String? get sourceAccountError; String? get storageAccountError; String? get note; bool get isSubmitting; bool get success; String? get errorMessage;
/// Create a copy of ContributeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributeStateCopyWith<ContributeState> get copyWith => _$ContributeStateCopyWithImpl<ContributeState>(this as ContributeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributeState&&(identical(other.goal, goal) || other.goal == goal)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&const DeepCollectionEquality().equals(other.goalStorageAccounts, goalStorageAccounts)&&(identical(other.selectedAccountId, selectedAccountId) || other.selectedAccountId == selectedAccountId)&&(identical(other.selectedStorageAccountId, selectedStorageAccountId) || other.selectedStorageAccountId == selectedStorageAccountId)&&(identical(other.goalAccountCurrency, goalAccountCurrency) || other.goalAccountCurrency == goalAccountCurrency)&&(identical(other.amountInput, amountInput) || other.amountInput == amountInput)&&(identical(other.amountError, amountError) || other.amountError == amountError)&&(identical(other.sourceAccountError, sourceAccountError) || other.sourceAccountError == sourceAccountError)&&(identical(other.storageAccountError, storageAccountError) || other.storageAccountError == storageAccountError)&&(identical(other.note, note) || other.note == note)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,goal,const DeepCollectionEquality().hash(accounts),const DeepCollectionEquality().hash(goalStorageAccounts),selectedAccountId,selectedStorageAccountId,goalAccountCurrency,amountInput,amountError,sourceAccountError,storageAccountError,note,isSubmitting,success,errorMessage);

@override
String toString() {
  return 'ContributeState(goal: $goal, accounts: $accounts, goalStorageAccounts: $goalStorageAccounts, selectedAccountId: $selectedAccountId, selectedStorageAccountId: $selectedStorageAccountId, goalAccountCurrency: $goalAccountCurrency, amountInput: $amountInput, amountError: $amountError, sourceAccountError: $sourceAccountError, storageAccountError: $storageAccountError, note: $note, isSubmitting: $isSubmitting, success: $success, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ContributeStateCopyWith<$Res>  {
  factory $ContributeStateCopyWith(ContributeState value, $Res Function(ContributeState) _then) = _$ContributeStateCopyWithImpl;
@useResult
$Res call({
 SavingGoal goal, List<AccountEntity> accounts, List<AccountEntity> goalStorageAccounts, String? selectedAccountId, String? selectedStorageAccountId, String? goalAccountCurrency, String amountInput, String? amountError, String? sourceAccountError, String? storageAccountError, String? note, bool isSubmitting, bool success, String? errorMessage
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
@pragma('vm:prefer-inline') @override $Res call({Object? goal = null,Object? accounts = null,Object? goalStorageAccounts = null,Object? selectedAccountId = freezed,Object? selectedStorageAccountId = freezed,Object? goalAccountCurrency = freezed,Object? amountInput = null,Object? amountError = freezed,Object? sourceAccountError = freezed,Object? storageAccountError = freezed,Object? note = freezed,Object? isSubmitting = null,Object? success = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as SavingGoal,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountEntity>,goalStorageAccounts: null == goalStorageAccounts ? _self.goalStorageAccounts : goalStorageAccounts // ignore: cast_nullable_to_non_nullable
as List<AccountEntity>,selectedAccountId: freezed == selectedAccountId ? _self.selectedAccountId : selectedAccountId // ignore: cast_nullable_to_non_nullable
as String?,selectedStorageAccountId: freezed == selectedStorageAccountId ? _self.selectedStorageAccountId : selectedStorageAccountId // ignore: cast_nullable_to_non_nullable
as String?,goalAccountCurrency: freezed == goalAccountCurrency ? _self.goalAccountCurrency : goalAccountCurrency // ignore: cast_nullable_to_non_nullable
as String?,amountInput: null == amountInput ? _self.amountInput : amountInput // ignore: cast_nullable_to_non_nullable
as String,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,sourceAccountError: freezed == sourceAccountError ? _self.sourceAccountError : sourceAccountError // ignore: cast_nullable_to_non_nullable
as String?,storageAccountError: freezed == storageAccountError ? _self.storageAccountError : storageAccountError // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SavingGoal goal,  List<AccountEntity> accounts,  List<AccountEntity> goalStorageAccounts,  String? selectedAccountId,  String? selectedStorageAccountId,  String? goalAccountCurrency,  String amountInput,  String? amountError,  String? sourceAccountError,  String? storageAccountError,  String? note,  bool isSubmitting,  bool success,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributeState() when $default != null:
return $default(_that.goal,_that.accounts,_that.goalStorageAccounts,_that.selectedAccountId,_that.selectedStorageAccountId,_that.goalAccountCurrency,_that.amountInput,_that.amountError,_that.sourceAccountError,_that.storageAccountError,_that.note,_that.isSubmitting,_that.success,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SavingGoal goal,  List<AccountEntity> accounts,  List<AccountEntity> goalStorageAccounts,  String? selectedAccountId,  String? selectedStorageAccountId,  String? goalAccountCurrency,  String amountInput,  String? amountError,  String? sourceAccountError,  String? storageAccountError,  String? note,  bool isSubmitting,  bool success,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ContributeState():
return $default(_that.goal,_that.accounts,_that.goalStorageAccounts,_that.selectedAccountId,_that.selectedStorageAccountId,_that.goalAccountCurrency,_that.amountInput,_that.amountError,_that.sourceAccountError,_that.storageAccountError,_that.note,_that.isSubmitting,_that.success,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SavingGoal goal,  List<AccountEntity> accounts,  List<AccountEntity> goalStorageAccounts,  String? selectedAccountId,  String? selectedStorageAccountId,  String? goalAccountCurrency,  String amountInput,  String? amountError,  String? sourceAccountError,  String? storageAccountError,  String? note,  bool isSubmitting,  bool success,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ContributeState() when $default != null:
return $default(_that.goal,_that.accounts,_that.goalStorageAccounts,_that.selectedAccountId,_that.selectedStorageAccountId,_that.goalAccountCurrency,_that.amountInput,_that.amountError,_that.sourceAccountError,_that.storageAccountError,_that.note,_that.isSubmitting,_that.success,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ContributeState implements ContributeState {
  const _ContributeState({required this.goal, final  List<AccountEntity> accounts = const <AccountEntity>[], final  List<AccountEntity> goalStorageAccounts = const <AccountEntity>[], this.selectedAccountId, this.selectedStorageAccountId, this.goalAccountCurrency, this.amountInput = '', this.amountError, this.sourceAccountError, this.storageAccountError, this.note, this.isSubmitting = false, this.success = false, this.errorMessage}): _accounts = accounts,_goalStorageAccounts = goalStorageAccounts;
  

@override final  SavingGoal goal;
 final  List<AccountEntity> _accounts;
@override@JsonKey() List<AccountEntity> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

 final  List<AccountEntity> _goalStorageAccounts;
@override@JsonKey() List<AccountEntity> get goalStorageAccounts {
  if (_goalStorageAccounts is EqualUnmodifiableListView) return _goalStorageAccounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goalStorageAccounts);
}

@override final  String? selectedAccountId;
@override final  String? selectedStorageAccountId;
@override final  String? goalAccountCurrency;
@override@JsonKey() final  String amountInput;
@override final  String? amountError;
@override final  String? sourceAccountError;
@override final  String? storageAccountError;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributeState&&(identical(other.goal, goal) || other.goal == goal)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&const DeepCollectionEquality().equals(other._goalStorageAccounts, _goalStorageAccounts)&&(identical(other.selectedAccountId, selectedAccountId) || other.selectedAccountId == selectedAccountId)&&(identical(other.selectedStorageAccountId, selectedStorageAccountId) || other.selectedStorageAccountId == selectedStorageAccountId)&&(identical(other.goalAccountCurrency, goalAccountCurrency) || other.goalAccountCurrency == goalAccountCurrency)&&(identical(other.amountInput, amountInput) || other.amountInput == amountInput)&&(identical(other.amountError, amountError) || other.amountError == amountError)&&(identical(other.sourceAccountError, sourceAccountError) || other.sourceAccountError == sourceAccountError)&&(identical(other.storageAccountError, storageAccountError) || other.storageAccountError == storageAccountError)&&(identical(other.note, note) || other.note == note)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,goal,const DeepCollectionEquality().hash(_accounts),const DeepCollectionEquality().hash(_goalStorageAccounts),selectedAccountId,selectedStorageAccountId,goalAccountCurrency,amountInput,amountError,sourceAccountError,storageAccountError,note,isSubmitting,success,errorMessage);

@override
String toString() {
  return 'ContributeState(goal: $goal, accounts: $accounts, goalStorageAccounts: $goalStorageAccounts, selectedAccountId: $selectedAccountId, selectedStorageAccountId: $selectedStorageAccountId, goalAccountCurrency: $goalAccountCurrency, amountInput: $amountInput, amountError: $amountError, sourceAccountError: $sourceAccountError, storageAccountError: $storageAccountError, note: $note, isSubmitting: $isSubmitting, success: $success, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ContributeStateCopyWith<$Res> implements $ContributeStateCopyWith<$Res> {
  factory _$ContributeStateCopyWith(_ContributeState value, $Res Function(_ContributeState) _then) = __$ContributeStateCopyWithImpl;
@override @useResult
$Res call({
 SavingGoal goal, List<AccountEntity> accounts, List<AccountEntity> goalStorageAccounts, String? selectedAccountId, String? selectedStorageAccountId, String? goalAccountCurrency, String amountInput, String? amountError, String? sourceAccountError, String? storageAccountError, String? note, bool isSubmitting, bool success, String? errorMessage
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
@override @pragma('vm:prefer-inline') $Res call({Object? goal = null,Object? accounts = null,Object? goalStorageAccounts = null,Object? selectedAccountId = freezed,Object? selectedStorageAccountId = freezed,Object? goalAccountCurrency = freezed,Object? amountInput = null,Object? amountError = freezed,Object? sourceAccountError = freezed,Object? storageAccountError = freezed,Object? note = freezed,Object? isSubmitting = null,Object? success = null,Object? errorMessage = freezed,}) {
  return _then(_ContributeState(
goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as SavingGoal,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountEntity>,goalStorageAccounts: null == goalStorageAccounts ? _self._goalStorageAccounts : goalStorageAccounts // ignore: cast_nullable_to_non_nullable
as List<AccountEntity>,selectedAccountId: freezed == selectedAccountId ? _self.selectedAccountId : selectedAccountId // ignore: cast_nullable_to_non_nullable
as String?,selectedStorageAccountId: freezed == selectedStorageAccountId ? _self.selectedStorageAccountId : selectedStorageAccountId // ignore: cast_nullable_to_non_nullable
as String?,goalAccountCurrency: freezed == goalAccountCurrency ? _self.goalAccountCurrency : goalAccountCurrency // ignore: cast_nullable_to_non_nullable
as String?,amountInput: null == amountInput ? _self.amountInput : amountInput // ignore: cast_nullable_to_non_nullable
as String,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,sourceAccountError: freezed == sourceAccountError ? _self.sourceAccountError : sourceAccountError // ignore: cast_nullable_to_non_nullable
as String?,storageAccountError: freezed == storageAccountError ? _self.storageAccountError : storageAccountError // ignore: cast_nullable_to_non_nullable
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
