// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_rule_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecurringRuleFormState {

 String get title; String get amountInput; AccountEntity? get account; String? get accountId; TransactionType get type; DateTime get startDate; int get applyHour; int get applyMinute; bool get autoPost; bool get isSubmitting; bool get submissionSuccess; bool get isEditing; RecurringRule? get initialRule; RecurringRuleTitleError? get titleError; RecurringRuleAmountError? get amountError; RecurringRuleAccountError? get accountError; String? get generalErrorMessage;
/// Create a copy of RecurringRuleFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringRuleFormStateCopyWith<RecurringRuleFormState> get copyWith => _$RecurringRuleFormStateCopyWithImpl<RecurringRuleFormState>(this as RecurringRuleFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringRuleFormState&&(identical(other.title, title) || other.title == title)&&(identical(other.amountInput, amountInput) || other.amountInput == amountInput)&&(identical(other.account, account) || other.account == account)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.type, type) || other.type == type)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.applyHour, applyHour) || other.applyHour == applyHour)&&(identical(other.applyMinute, applyMinute) || other.applyMinute == applyMinute)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submissionSuccess, submissionSuccess) || other.submissionSuccess == submissionSuccess)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.initialRule, initialRule) || other.initialRule == initialRule)&&(identical(other.titleError, titleError) || other.titleError == titleError)&&(identical(other.amountError, amountError) || other.amountError == amountError)&&(identical(other.accountError, accountError) || other.accountError == accountError)&&(identical(other.generalErrorMessage, generalErrorMessage) || other.generalErrorMessage == generalErrorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,title,amountInput,account,accountId,type,startDate,applyHour,applyMinute,autoPost,isSubmitting,submissionSuccess,isEditing,initialRule,titleError,amountError,accountError,generalErrorMessage);

@override
String toString() {
  return 'RecurringRuleFormState(title: $title, amountInput: $amountInput, account: $account, accountId: $accountId, type: $type, startDate: $startDate, applyHour: $applyHour, applyMinute: $applyMinute, autoPost: $autoPost, isSubmitting: $isSubmitting, submissionSuccess: $submissionSuccess, isEditing: $isEditing, initialRule: $initialRule, titleError: $titleError, amountError: $amountError, accountError: $accountError, generalErrorMessage: $generalErrorMessage)';
}


}

/// @nodoc
abstract mixin class $RecurringRuleFormStateCopyWith<$Res>  {
  factory $RecurringRuleFormStateCopyWith(RecurringRuleFormState value, $Res Function(RecurringRuleFormState) _then) = _$RecurringRuleFormStateCopyWithImpl;
@useResult
$Res call({
 String title, String amountInput, AccountEntity? account, String? accountId, TransactionType type, DateTime startDate, int applyHour, int applyMinute, bool autoPost, bool isSubmitting, bool submissionSuccess, bool isEditing, RecurringRule? initialRule, RecurringRuleTitleError? titleError, RecurringRuleAmountError? amountError, RecurringRuleAccountError? accountError, String? generalErrorMessage
});


$AccountEntityCopyWith<$Res>? get account;$RecurringRuleCopyWith<$Res>? get initialRule;

}
/// @nodoc
class _$RecurringRuleFormStateCopyWithImpl<$Res>
    implements $RecurringRuleFormStateCopyWith<$Res> {
  _$RecurringRuleFormStateCopyWithImpl(this._self, this._then);

  final RecurringRuleFormState _self;
  final $Res Function(RecurringRuleFormState) _then;

/// Create a copy of RecurringRuleFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? amountInput = null,Object? account = freezed,Object? accountId = freezed,Object? type = null,Object? startDate = null,Object? applyHour = null,Object? applyMinute = null,Object? autoPost = null,Object? isSubmitting = null,Object? submissionSuccess = null,Object? isEditing = null,Object? initialRule = freezed,Object? titleError = freezed,Object? amountError = freezed,Object? accountError = freezed,Object? generalErrorMessage = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amountInput: null == amountInput ? _self.amountInput : amountInput // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as AccountEntity?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,applyHour: null == applyHour ? _self.applyHour : applyHour // ignore: cast_nullable_to_non_nullable
as int,applyMinute: null == applyMinute ? _self.applyMinute : applyMinute // ignore: cast_nullable_to_non_nullable
as int,autoPost: null == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submissionSuccess: null == submissionSuccess ? _self.submissionSuccess : submissionSuccess // ignore: cast_nullable_to_non_nullable
as bool,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,initialRule: freezed == initialRule ? _self.initialRule : initialRule // ignore: cast_nullable_to_non_nullable
as RecurringRule?,titleError: freezed == titleError ? _self.titleError : titleError // ignore: cast_nullable_to_non_nullable
as RecurringRuleTitleError?,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as RecurringRuleAmountError?,accountError: freezed == accountError ? _self.accountError : accountError // ignore: cast_nullable_to_non_nullable
as RecurringRuleAccountError?,generalErrorMessage: freezed == generalErrorMessage ? _self.generalErrorMessage : generalErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RecurringRuleFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountEntityCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $AccountEntityCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of RecurringRuleFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringRuleCopyWith<$Res>? get initialRule {
    if (_self.initialRule == null) {
    return null;
  }

  return $RecurringRuleCopyWith<$Res>(_self.initialRule!, (value) {
    return _then(_self.copyWith(initialRule: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecurringRuleFormState].
extension RecurringRuleFormStatePatterns on RecurringRuleFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringRuleFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringRuleFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringRuleFormState value)  $default,){
final _that = this;
switch (_that) {
case _RecurringRuleFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringRuleFormState value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringRuleFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String amountInput,  AccountEntity? account,  String? accountId,  TransactionType type,  DateTime startDate,  int applyHour,  int applyMinute,  bool autoPost,  bool isSubmitting,  bool submissionSuccess,  bool isEditing,  RecurringRule? initialRule,  RecurringRuleTitleError? titleError,  RecurringRuleAmountError? amountError,  RecurringRuleAccountError? accountError,  String? generalErrorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringRuleFormState() when $default != null:
return $default(_that.title,_that.amountInput,_that.account,_that.accountId,_that.type,_that.startDate,_that.applyHour,_that.applyMinute,_that.autoPost,_that.isSubmitting,_that.submissionSuccess,_that.isEditing,_that.initialRule,_that.titleError,_that.amountError,_that.accountError,_that.generalErrorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String amountInput,  AccountEntity? account,  String? accountId,  TransactionType type,  DateTime startDate,  int applyHour,  int applyMinute,  bool autoPost,  bool isSubmitting,  bool submissionSuccess,  bool isEditing,  RecurringRule? initialRule,  RecurringRuleTitleError? titleError,  RecurringRuleAmountError? amountError,  RecurringRuleAccountError? accountError,  String? generalErrorMessage)  $default,) {final _that = this;
switch (_that) {
case _RecurringRuleFormState():
return $default(_that.title,_that.amountInput,_that.account,_that.accountId,_that.type,_that.startDate,_that.applyHour,_that.applyMinute,_that.autoPost,_that.isSubmitting,_that.submissionSuccess,_that.isEditing,_that.initialRule,_that.titleError,_that.amountError,_that.accountError,_that.generalErrorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String amountInput,  AccountEntity? account,  String? accountId,  TransactionType type,  DateTime startDate,  int applyHour,  int applyMinute,  bool autoPost,  bool isSubmitting,  bool submissionSuccess,  bool isEditing,  RecurringRule? initialRule,  RecurringRuleTitleError? titleError,  RecurringRuleAmountError? amountError,  RecurringRuleAccountError? accountError,  String? generalErrorMessage)?  $default,) {final _that = this;
switch (_that) {
case _RecurringRuleFormState() when $default != null:
return $default(_that.title,_that.amountInput,_that.account,_that.accountId,_that.type,_that.startDate,_that.applyHour,_that.applyMinute,_that.autoPost,_that.isSubmitting,_that.submissionSuccess,_that.isEditing,_that.initialRule,_that.titleError,_that.amountError,_that.accountError,_that.generalErrorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _RecurringRuleFormState extends RecurringRuleFormState {
  const _RecurringRuleFormState({this.title = '', this.amountInput = '', this.account, this.accountId, this.type = TransactionType.expense, required this.startDate, this.applyHour = 0, this.applyMinute = 0, this.autoPost = false, this.isSubmitting = false, this.submissionSuccess = false, this.isEditing = false, this.initialRule, this.titleError, this.amountError, this.accountError, this.generalErrorMessage}): super._();
  

@override@JsonKey() final  String title;
@override@JsonKey() final  String amountInput;
@override final  AccountEntity? account;
@override final  String? accountId;
@override@JsonKey() final  TransactionType type;
@override final  DateTime startDate;
@override@JsonKey() final  int applyHour;
@override@JsonKey() final  int applyMinute;
@override@JsonKey() final  bool autoPost;
@override@JsonKey() final  bool isSubmitting;
@override@JsonKey() final  bool submissionSuccess;
@override@JsonKey() final  bool isEditing;
@override final  RecurringRule? initialRule;
@override final  RecurringRuleTitleError? titleError;
@override final  RecurringRuleAmountError? amountError;
@override final  RecurringRuleAccountError? accountError;
@override final  String? generalErrorMessage;

/// Create a copy of RecurringRuleFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringRuleFormStateCopyWith<_RecurringRuleFormState> get copyWith => __$RecurringRuleFormStateCopyWithImpl<_RecurringRuleFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringRuleFormState&&(identical(other.title, title) || other.title == title)&&(identical(other.amountInput, amountInput) || other.amountInput == amountInput)&&(identical(other.account, account) || other.account == account)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.type, type) || other.type == type)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.applyHour, applyHour) || other.applyHour == applyHour)&&(identical(other.applyMinute, applyMinute) || other.applyMinute == applyMinute)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submissionSuccess, submissionSuccess) || other.submissionSuccess == submissionSuccess)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.initialRule, initialRule) || other.initialRule == initialRule)&&(identical(other.titleError, titleError) || other.titleError == titleError)&&(identical(other.amountError, amountError) || other.amountError == amountError)&&(identical(other.accountError, accountError) || other.accountError == accountError)&&(identical(other.generalErrorMessage, generalErrorMessage) || other.generalErrorMessage == generalErrorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,title,amountInput,account,accountId,type,startDate,applyHour,applyMinute,autoPost,isSubmitting,submissionSuccess,isEditing,initialRule,titleError,amountError,accountError,generalErrorMessage);

@override
String toString() {
  return 'RecurringRuleFormState(title: $title, amountInput: $amountInput, account: $account, accountId: $accountId, type: $type, startDate: $startDate, applyHour: $applyHour, applyMinute: $applyMinute, autoPost: $autoPost, isSubmitting: $isSubmitting, submissionSuccess: $submissionSuccess, isEditing: $isEditing, initialRule: $initialRule, titleError: $titleError, amountError: $amountError, accountError: $accountError, generalErrorMessage: $generalErrorMessage)';
}


}

/// @nodoc
abstract mixin class _$RecurringRuleFormStateCopyWith<$Res> implements $RecurringRuleFormStateCopyWith<$Res> {
  factory _$RecurringRuleFormStateCopyWith(_RecurringRuleFormState value, $Res Function(_RecurringRuleFormState) _then) = __$RecurringRuleFormStateCopyWithImpl;
@override @useResult
$Res call({
 String title, String amountInput, AccountEntity? account, String? accountId, TransactionType type, DateTime startDate, int applyHour, int applyMinute, bool autoPost, bool isSubmitting, bool submissionSuccess, bool isEditing, RecurringRule? initialRule, RecurringRuleTitleError? titleError, RecurringRuleAmountError? amountError, RecurringRuleAccountError? accountError, String? generalErrorMessage
});


@override $AccountEntityCopyWith<$Res>? get account;@override $RecurringRuleCopyWith<$Res>? get initialRule;

}
/// @nodoc
class __$RecurringRuleFormStateCopyWithImpl<$Res>
    implements _$RecurringRuleFormStateCopyWith<$Res> {
  __$RecurringRuleFormStateCopyWithImpl(this._self, this._then);

  final _RecurringRuleFormState _self;
  final $Res Function(_RecurringRuleFormState) _then;

/// Create a copy of RecurringRuleFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? amountInput = null,Object? account = freezed,Object? accountId = freezed,Object? type = null,Object? startDate = null,Object? applyHour = null,Object? applyMinute = null,Object? autoPost = null,Object? isSubmitting = null,Object? submissionSuccess = null,Object? isEditing = null,Object? initialRule = freezed,Object? titleError = freezed,Object? amountError = freezed,Object? accountError = freezed,Object? generalErrorMessage = freezed,}) {
  return _then(_RecurringRuleFormState(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amountInput: null == amountInput ? _self.amountInput : amountInput // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as AccountEntity?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,applyHour: null == applyHour ? _self.applyHour : applyHour // ignore: cast_nullable_to_non_nullable
as int,applyMinute: null == applyMinute ? _self.applyMinute : applyMinute // ignore: cast_nullable_to_non_nullable
as int,autoPost: null == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submissionSuccess: null == submissionSuccess ? _self.submissionSuccess : submissionSuccess // ignore: cast_nullable_to_non_nullable
as bool,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,initialRule: freezed == initialRule ? _self.initialRule : initialRule // ignore: cast_nullable_to_non_nullable
as RecurringRule?,titleError: freezed == titleError ? _self.titleError : titleError // ignore: cast_nullable_to_non_nullable
as RecurringRuleTitleError?,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as RecurringRuleAmountError?,accountError: freezed == accountError ? _self.accountError : accountError // ignore: cast_nullable_to_non_nullable
as RecurringRuleAccountError?,generalErrorMessage: freezed == generalErrorMessage ? _self.generalErrorMessage : generalErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RecurringRuleFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountEntityCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $AccountEntityCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of RecurringRuleFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringRuleCopyWith<$Res>? get initialRule {
    if (_self.initialRule == null) {
    return null;
  }

  return $RecurringRuleCopyWith<$Res>(_self.initialRule!, (value) {
    return _then(_self.copyWith(initialRule: value));
  });
}
}

// dart format on
