// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringRule {

 String get id; String get title; String get accountId; double get amount; String get currency; DateTime get startAt; DateTime? get endAt; String get timezone; String get rrule; String? get notes; bool get isActive; bool get autoPost; int? get reminderMinutesBefore; RecurringRuleShortMonthPolicy get shortMonthPolicy; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringRuleCopyWith<RecurringRule> get copyWith => _$RecurringRuleCopyWithImpl<RecurringRule>(this as RecurringRule, _$identity);

  /// Serializes this RecurringRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringRule&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.rrule, rrule) || other.rrule == rrule)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost)&&(identical(other.reminderMinutesBefore, reminderMinutesBefore) || other.reminderMinutesBefore == reminderMinutesBefore)&&(identical(other.shortMonthPolicy, shortMonthPolicy) || other.shortMonthPolicy == shortMonthPolicy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,accountId,amount,currency,startAt,endAt,timezone,rrule,notes,isActive,autoPost,reminderMinutesBefore,shortMonthPolicy,createdAt,updatedAt);

@override
String toString() {
  return 'RecurringRule(id: $id, title: $title, accountId: $accountId, amount: $amount, currency: $currency, startAt: $startAt, endAt: $endAt, timezone: $timezone, rrule: $rrule, notes: $notes, isActive: $isActive, autoPost: $autoPost, reminderMinutesBefore: $reminderMinutesBefore, shortMonthPolicy: $shortMonthPolicy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RecurringRuleCopyWith<$Res>  {
  factory $RecurringRuleCopyWith(RecurringRule value, $Res Function(RecurringRule) _then) = _$RecurringRuleCopyWithImpl;
@useResult
$Res call({
 String id, String title, String accountId, double amount, String currency, DateTime startAt, DateTime? endAt, String timezone, String rrule, String? notes, bool isActive, bool autoPost, int? reminderMinutesBefore, RecurringRuleShortMonthPolicy shortMonthPolicy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$RecurringRuleCopyWithImpl<$Res>
    implements $RecurringRuleCopyWith<$Res> {
  _$RecurringRuleCopyWithImpl(this._self, this._then);

  final RecurringRule _self;
  final $Res Function(RecurringRule) _then;

/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? accountId = null,Object? amount = null,Object? currency = null,Object? startAt = null,Object? endAt = freezed,Object? timezone = null,Object? rrule = null,Object? notes = freezed,Object? isActive = null,Object? autoPost = null,Object? reminderMinutesBefore = freezed,Object? shortMonthPolicy = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,rrule: null == rrule ? _self.rrule : rrule // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,autoPost: null == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool,reminderMinutesBefore: freezed == reminderMinutesBefore ? _self.reminderMinutesBefore : reminderMinutesBefore // ignore: cast_nullable_to_non_nullable
as int?,shortMonthPolicy: null == shortMonthPolicy ? _self.shortMonthPolicy : shortMonthPolicy // ignore: cast_nullable_to_non_nullable
as RecurringRuleShortMonthPolicy,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringRule].
extension RecurringRulePatterns on RecurringRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringRule value)  $default,){
final _that = this;
switch (_that) {
case _RecurringRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringRule value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String accountId,  double amount,  String currency,  DateTime startAt,  DateTime? endAt,  String timezone,  String rrule,  String? notes,  bool isActive,  bool autoPost,  int? reminderMinutesBefore,  RecurringRuleShortMonthPolicy shortMonthPolicy,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
return $default(_that.id,_that.title,_that.accountId,_that.amount,_that.currency,_that.startAt,_that.endAt,_that.timezone,_that.rrule,_that.notes,_that.isActive,_that.autoPost,_that.reminderMinutesBefore,_that.shortMonthPolicy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String accountId,  double amount,  String currency,  DateTime startAt,  DateTime? endAt,  String timezone,  String rrule,  String? notes,  bool isActive,  bool autoPost,  int? reminderMinutesBefore,  RecurringRuleShortMonthPolicy shortMonthPolicy,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RecurringRule():
return $default(_that.id,_that.title,_that.accountId,_that.amount,_that.currency,_that.startAt,_that.endAt,_that.timezone,_that.rrule,_that.notes,_that.isActive,_that.autoPost,_that.reminderMinutesBefore,_that.shortMonthPolicy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String accountId,  double amount,  String currency,  DateTime startAt,  DateTime? endAt,  String timezone,  String rrule,  String? notes,  bool isActive,  bool autoPost,  int? reminderMinutesBefore,  RecurringRuleShortMonthPolicy shortMonthPolicy,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
return $default(_that.id,_that.title,_that.accountId,_that.amount,_that.currency,_that.startAt,_that.endAt,_that.timezone,_that.rrule,_that.notes,_that.isActive,_that.autoPost,_that.reminderMinutesBefore,_that.shortMonthPolicy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringRule extends RecurringRule {
  const _RecurringRule({required this.id, required this.title, required this.accountId, required this.amount, required this.currency, required this.startAt, this.endAt, required this.timezone, required this.rrule, this.notes, this.isActive = true, this.autoPost = false, this.reminderMinutesBefore, this.shortMonthPolicy = RecurringRuleShortMonthPolicy.clipToLastDay, required this.createdAt, required this.updatedAt}): super._();
  factory _RecurringRule.fromJson(Map<String, dynamic> json) => _$RecurringRuleFromJson(json);

@override final  String id;
@override final  String title;
@override final  String accountId;
@override final  double amount;
@override final  String currency;
@override final  DateTime startAt;
@override final  DateTime? endAt;
@override final  String timezone;
@override final  String rrule;
@override final  String? notes;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool autoPost;
@override final  int? reminderMinutesBefore;
@override@JsonKey() final  RecurringRuleShortMonthPolicy shortMonthPolicy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringRuleCopyWith<_RecurringRule> get copyWith => __$RecurringRuleCopyWithImpl<_RecurringRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringRule&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.rrule, rrule) || other.rrule == rrule)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost)&&(identical(other.reminderMinutesBefore, reminderMinutesBefore) || other.reminderMinutesBefore == reminderMinutesBefore)&&(identical(other.shortMonthPolicy, shortMonthPolicy) || other.shortMonthPolicy == shortMonthPolicy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,accountId,amount,currency,startAt,endAt,timezone,rrule,notes,isActive,autoPost,reminderMinutesBefore,shortMonthPolicy,createdAt,updatedAt);

@override
String toString() {
  return 'RecurringRule(id: $id, title: $title, accountId: $accountId, amount: $amount, currency: $currency, startAt: $startAt, endAt: $endAt, timezone: $timezone, rrule: $rrule, notes: $notes, isActive: $isActive, autoPost: $autoPost, reminderMinutesBefore: $reminderMinutesBefore, shortMonthPolicy: $shortMonthPolicy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RecurringRuleCopyWith<$Res> implements $RecurringRuleCopyWith<$Res> {
  factory _$RecurringRuleCopyWith(_RecurringRule value, $Res Function(_RecurringRule) _then) = __$RecurringRuleCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String accountId, double amount, String currency, DateTime startAt, DateTime? endAt, String timezone, String rrule, String? notes, bool isActive, bool autoPost, int? reminderMinutesBefore, RecurringRuleShortMonthPolicy shortMonthPolicy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$RecurringRuleCopyWithImpl<$Res>
    implements _$RecurringRuleCopyWith<$Res> {
  __$RecurringRuleCopyWithImpl(this._self, this._then);

  final _RecurringRule _self;
  final $Res Function(_RecurringRule) _then;

/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? accountId = null,Object? amount = null,Object? currency = null,Object? startAt = null,Object? endAt = freezed,Object? timezone = null,Object? rrule = null,Object? notes = freezed,Object? isActive = null,Object? autoPost = null,Object? reminderMinutesBefore = freezed,Object? shortMonthPolicy = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_RecurringRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,rrule: null == rrule ? _self.rrule : rrule // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,autoPost: null == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool,reminderMinutesBefore: freezed == reminderMinutesBefore ? _self.reminderMinutesBefore : reminderMinutesBefore // ignore: cast_nullable_to_non_nullable
as int?,shortMonthPolicy: null == shortMonthPolicy ? _self.shortMonthPolicy : shortMonthPolicy // ignore: cast_nullable_to_non_nullable
as RecurringRuleShortMonthPolicy,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
