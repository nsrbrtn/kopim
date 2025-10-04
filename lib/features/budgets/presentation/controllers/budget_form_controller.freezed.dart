// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetFormState implements DiagnosticableTreeMixin {

 String get title; String get amountText; BudgetPeriod get period; BudgetScope get scope; DateTime get startDate; DateTime? get endDate; List<String> get categoryIds; List<String> get accountIds; Budget? get initialBudget; bool get isSubmitting; String? get errorMessage;
/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetFormStateCopyWith<BudgetFormState> get copyWith => _$BudgetFormStateCopyWithImpl<BudgetFormState>(this as BudgetFormState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'BudgetFormState'))
    ..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('amountText', amountText))..add(DiagnosticsProperty('period', period))..add(DiagnosticsProperty('scope', scope))..add(DiagnosticsProperty('startDate', startDate))..add(DiagnosticsProperty('endDate', endDate))..add(DiagnosticsProperty('categoryIds', categoryIds))..add(DiagnosticsProperty('accountIds', accountIds))..add(DiagnosticsProperty('initialBudget', initialBudget))..add(DiagnosticsProperty('isSubmitting', isSubmitting))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetFormState&&(identical(other.title, title) || other.title == title)&&(identical(other.amountText, amountText) || other.amountText == amountText)&&(identical(other.period, period) || other.period == period)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.accountIds, accountIds)&&(identical(other.initialBudget, initialBudget) || other.initialBudget == initialBudget)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,title,amountText,period,scope,startDate,endDate,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(accountIds),initialBudget,isSubmitting,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'BudgetFormState(title: $title, amountText: $amountText, period: $period, scope: $scope, startDate: $startDate, endDate: $endDate, categoryIds: $categoryIds, accountIds: $accountIds, initialBudget: $initialBudget, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $BudgetFormStateCopyWith<$Res>  {
  factory $BudgetFormStateCopyWith(BudgetFormState value, $Res Function(BudgetFormState) _then) = _$BudgetFormStateCopyWithImpl;
@useResult
$Res call({
 String title, String amountText, BudgetPeriod period, BudgetScope scope, DateTime startDate, DateTime? endDate, List<String> categoryIds, List<String> accountIds, Budget? initialBudget, bool isSubmitting, String? errorMessage
});


$BudgetCopyWith<$Res>? get initialBudget;

}
/// @nodoc
class _$BudgetFormStateCopyWithImpl<$Res>
    implements $BudgetFormStateCopyWith<$Res> {
  _$BudgetFormStateCopyWithImpl(this._self, this._then);

  final BudgetFormState _self;
  final $Res Function(BudgetFormState) _then;

/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? amountText = null,Object? period = null,Object? scope = null,Object? startDate = null,Object? endDate = freezed,Object? categoryIds = null,Object? accountIds = null,Object? initialBudget = freezed,Object? isSubmitting = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amountText: null == amountText ? _self.amountText : amountText // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as BudgetPeriod,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as BudgetScope,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,accountIds: null == accountIds ? _self.accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as List<String>,initialBudget: freezed == initialBudget ? _self.initialBudget : initialBudget // ignore: cast_nullable_to_non_nullable
as Budget?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetCopyWith<$Res>? get initialBudget {
    if (_self.initialBudget == null) {
    return null;
  }

  return $BudgetCopyWith<$Res>(_self.initialBudget!, (value) {
    return _then(_self.copyWith(initialBudget: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetFormState].
extension BudgetFormStatePatterns on BudgetFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetFormState value)  $default,){
final _that = this;
switch (_that) {
case _BudgetFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetFormState value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String amountText,  BudgetPeriod period,  BudgetScope scope,  DateTime startDate,  DateTime? endDate,  List<String> categoryIds,  List<String> accountIds,  Budget? initialBudget,  bool isSubmitting,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetFormState() when $default != null:
return $default(_that.title,_that.amountText,_that.period,_that.scope,_that.startDate,_that.endDate,_that.categoryIds,_that.accountIds,_that.initialBudget,_that.isSubmitting,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String amountText,  BudgetPeriod period,  BudgetScope scope,  DateTime startDate,  DateTime? endDate,  List<String> categoryIds,  List<String> accountIds,  Budget? initialBudget,  bool isSubmitting,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _BudgetFormState():
return $default(_that.title,_that.amountText,_that.period,_that.scope,_that.startDate,_that.endDate,_that.categoryIds,_that.accountIds,_that.initialBudget,_that.isSubmitting,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String amountText,  BudgetPeriod period,  BudgetScope scope,  DateTime startDate,  DateTime? endDate,  List<String> categoryIds,  List<String> accountIds,  Budget? initialBudget,  bool isSubmitting,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _BudgetFormState() when $default != null:
return $default(_that.title,_that.amountText,_that.period,_that.scope,_that.startDate,_that.endDate,_that.categoryIds,_that.accountIds,_that.initialBudget,_that.isSubmitting,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetFormState with DiagnosticableTreeMixin implements BudgetFormState {
  const _BudgetFormState({required this.title, required this.amountText, required this.period, required this.scope, required this.startDate, this.endDate, final  List<String> categoryIds = const <String>[], final  List<String> accountIds = const <String>[], this.initialBudget, this.isSubmitting = false, this.errorMessage}): _categoryIds = categoryIds,_accountIds = accountIds;
  

@override final  String title;
@override final  String amountText;
@override final  BudgetPeriod period;
@override final  BudgetScope scope;
@override final  DateTime startDate;
@override final  DateTime? endDate;
 final  List<String> _categoryIds;
@override@JsonKey() List<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryIds);
}

 final  List<String> _accountIds;
@override@JsonKey() List<String> get accountIds {
  if (_accountIds is EqualUnmodifiableListView) return _accountIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accountIds);
}

@override final  Budget? initialBudget;
@override@JsonKey() final  bool isSubmitting;
@override final  String? errorMessage;

/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetFormStateCopyWith<_BudgetFormState> get copyWith => __$BudgetFormStateCopyWithImpl<_BudgetFormState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'BudgetFormState'))
    ..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('amountText', amountText))..add(DiagnosticsProperty('period', period))..add(DiagnosticsProperty('scope', scope))..add(DiagnosticsProperty('startDate', startDate))..add(DiagnosticsProperty('endDate', endDate))..add(DiagnosticsProperty('categoryIds', categoryIds))..add(DiagnosticsProperty('accountIds', accountIds))..add(DiagnosticsProperty('initialBudget', initialBudget))..add(DiagnosticsProperty('isSubmitting', isSubmitting))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetFormState&&(identical(other.title, title) || other.title == title)&&(identical(other.amountText, amountText) || other.amountText == amountText)&&(identical(other.period, period) || other.period == period)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._categoryIds, _categoryIds)&&const DeepCollectionEquality().equals(other._accountIds, _accountIds)&&(identical(other.initialBudget, initialBudget) || other.initialBudget == initialBudget)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,title,amountText,period,scope,startDate,endDate,const DeepCollectionEquality().hash(_categoryIds),const DeepCollectionEquality().hash(_accountIds),initialBudget,isSubmitting,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'BudgetFormState(title: $title, amountText: $amountText, period: $period, scope: $scope, startDate: $startDate, endDate: $endDate, categoryIds: $categoryIds, accountIds: $accountIds, initialBudget: $initialBudget, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$BudgetFormStateCopyWith<$Res> implements $BudgetFormStateCopyWith<$Res> {
  factory _$BudgetFormStateCopyWith(_BudgetFormState value, $Res Function(_BudgetFormState) _then) = __$BudgetFormStateCopyWithImpl;
@override @useResult
$Res call({
 String title, String amountText, BudgetPeriod period, BudgetScope scope, DateTime startDate, DateTime? endDate, List<String> categoryIds, List<String> accountIds, Budget? initialBudget, bool isSubmitting, String? errorMessage
});


@override $BudgetCopyWith<$Res>? get initialBudget;

}
/// @nodoc
class __$BudgetFormStateCopyWithImpl<$Res>
    implements _$BudgetFormStateCopyWith<$Res> {
  __$BudgetFormStateCopyWithImpl(this._self, this._then);

  final _BudgetFormState _self;
  final $Res Function(_BudgetFormState) _then;

/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? amountText = null,Object? period = null,Object? scope = null,Object? startDate = null,Object? endDate = freezed,Object? categoryIds = null,Object? accountIds = null,Object? initialBudget = freezed,Object? isSubmitting = null,Object? errorMessage = freezed,}) {
  return _then(_BudgetFormState(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amountText: null == amountText ? _self.amountText : amountText // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as BudgetPeriod,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as BudgetScope,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,accountIds: null == accountIds ? _self._accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as List<String>,initialBudget: freezed == initialBudget ? _self.initialBudget : initialBudget // ignore: cast_nullable_to_non_nullable
as Budget?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetCopyWith<$Res>? get initialBudget {
    if (_self.initialBudget == null) {
    return null;
  }

  return $BudgetCopyWith<$Res>(_self.initialBudget!, (value) {
    return _then(_self.copyWith(initialBudget: value));
  });
}
}

// dart format on
