// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_bundle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExportBundle {

/// Версия схемы экспортируемых данных.
 String get schemaVersion;/// Временная метка формирования бандла.
 DateTime get generatedAt;/// Набор локальных счетов.
 List<AccountEntity> get accounts;/// Набор локальных транзакций.
 List<TransactionEntity> get transactions;/// Набор локальных категорий.
 List<Category> get categories;/// Набор локальных тегов.
 List<TagEntity> get tags;/// Набор связей транзакций и тегов.
 List<TransactionTagEntity> get transactionTags;/// Набор локальных целей накоплений.
 List<SavingGoal> get savingGoals;/// Набор локальных кредитов.
 List<CreditEntity> get credits;/// Набор локальных кредитных карт.
 List<CreditCardEntity> get creditCards;/// Набор локальных долгов.
 List<DebtEntity> get debts;/// Набор локальных бюджетов.
 List<Budget> get budgets;/// Набор локальных инстансов бюджетов.
 List<BudgetInstance> get budgetInstances;/// Набор локальных recurring payments.
 List<UpcomingPayment> get upcomingPayments;/// Набор локальных reminders.
 List<PaymentReminder> get paymentReminders;/// Локальный профиль пользователя, если он доступен в кэше.
 Profile? get profile;/// Снимок пользовательского прогресса на момент экспорта.
 UserProgress? get progress;/// Метаданные целостности для каноничного JSON-экспорта.
 ExportBundleIntegrity? get integrity;
/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportBundleCopyWith<ExportBundle> get copyWith => _$ExportBundleCopyWithImpl<ExportBundle>(this as ExportBundle, _$identity);

  /// Serializes this ExportBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportBundle&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&const DeepCollectionEquality().equals(other.transactions, transactions)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.transactionTags, transactionTags)&&const DeepCollectionEquality().equals(other.savingGoals, savingGoals)&&const DeepCollectionEquality().equals(other.credits, credits)&&const DeepCollectionEquality().equals(other.creditCards, creditCards)&&const DeepCollectionEquality().equals(other.debts, debts)&&const DeepCollectionEquality().equals(other.budgets, budgets)&&const DeepCollectionEquality().equals(other.budgetInstances, budgetInstances)&&const DeepCollectionEquality().equals(other.upcomingPayments, upcomingPayments)&&const DeepCollectionEquality().equals(other.paymentReminders, paymentReminders)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.integrity, integrity) || other.integrity == integrity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,generatedAt,const DeepCollectionEquality().hash(accounts),const DeepCollectionEquality().hash(transactions),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(transactionTags),const DeepCollectionEquality().hash(savingGoals),const DeepCollectionEquality().hash(credits),const DeepCollectionEquality().hash(creditCards),const DeepCollectionEquality().hash(debts),const DeepCollectionEquality().hash(budgets),const DeepCollectionEquality().hash(budgetInstances),const DeepCollectionEquality().hash(upcomingPayments),const DeepCollectionEquality().hash(paymentReminders),profile,progress,integrity);

@override
String toString() {
  return 'ExportBundle(schemaVersion: $schemaVersion, generatedAt: $generatedAt, accounts: $accounts, transactions: $transactions, categories: $categories, tags: $tags, transactionTags: $transactionTags, savingGoals: $savingGoals, credits: $credits, creditCards: $creditCards, debts: $debts, budgets: $budgets, budgetInstances: $budgetInstances, upcomingPayments: $upcomingPayments, paymentReminders: $paymentReminders, profile: $profile, progress: $progress, integrity: $integrity)';
}


}

/// @nodoc
abstract mixin class $ExportBundleCopyWith<$Res>  {
  factory $ExportBundleCopyWith(ExportBundle value, $Res Function(ExportBundle) _then) = _$ExportBundleCopyWithImpl;
@useResult
$Res call({
 String schemaVersion, DateTime generatedAt, List<AccountEntity> accounts, List<TransactionEntity> transactions, List<Category> categories, List<TagEntity> tags, List<TransactionTagEntity> transactionTags, List<SavingGoal> savingGoals, List<CreditEntity> credits, List<CreditCardEntity> creditCards, List<DebtEntity> debts, List<Budget> budgets, List<BudgetInstance> budgetInstances, List<UpcomingPayment> upcomingPayments, List<PaymentReminder> paymentReminders, Profile? profile, UserProgress? progress, ExportBundleIntegrity? integrity
});


$ProfileCopyWith<$Res>? get profile;$UserProgressCopyWith<$Res>? get progress;$ExportBundleIntegrityCopyWith<$Res>? get integrity;

}
/// @nodoc
class _$ExportBundleCopyWithImpl<$Res>
    implements $ExportBundleCopyWith<$Res> {
  _$ExportBundleCopyWithImpl(this._self, this._then);

  final ExportBundle _self;
  final $Res Function(ExportBundle) _then;

/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? generatedAt = null,Object? accounts = null,Object? transactions = null,Object? categories = null,Object? tags = null,Object? transactionTags = null,Object? savingGoals = null,Object? credits = null,Object? creditCards = null,Object? debts = null,Object? budgets = null,Object? budgetInstances = null,Object? upcomingPayments = null,Object? paymentReminders = null,Object? profile = freezed,Object? progress = freezed,Object? integrity = freezed,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountEntity>,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntity>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagEntity>,transactionTags: null == transactionTags ? _self.transactionTags : transactionTags // ignore: cast_nullable_to_non_nullable
as List<TransactionTagEntity>,savingGoals: null == savingGoals ? _self.savingGoals : savingGoals // ignore: cast_nullable_to_non_nullable
as List<SavingGoal>,credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as List<CreditEntity>,creditCards: null == creditCards ? _self.creditCards : creditCards // ignore: cast_nullable_to_non_nullable
as List<CreditCardEntity>,debts: null == debts ? _self.debts : debts // ignore: cast_nullable_to_non_nullable
as List<DebtEntity>,budgets: null == budgets ? _self.budgets : budgets // ignore: cast_nullable_to_non_nullable
as List<Budget>,budgetInstances: null == budgetInstances ? _self.budgetInstances : budgetInstances // ignore: cast_nullable_to_non_nullable
as List<BudgetInstance>,upcomingPayments: null == upcomingPayments ? _self.upcomingPayments : upcomingPayments // ignore: cast_nullable_to_non_nullable
as List<UpcomingPayment>,paymentReminders: null == paymentReminders ? _self.paymentReminders : paymentReminders // ignore: cast_nullable_to_non_nullable
as List<PaymentReminder>,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as UserProgress?,integrity: freezed == integrity ? _self.integrity : integrity // ignore: cast_nullable_to_non_nullable
as ExportBundleIntegrity?,
  ));
}
/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $UserProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExportBundleIntegrityCopyWith<$Res>? get integrity {
    if (_self.integrity == null) {
    return null;
  }

  return $ExportBundleIntegrityCopyWith<$Res>(_self.integrity!, (value) {
    return _then(_self.copyWith(integrity: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExportBundle].
extension ExportBundlePatterns on ExportBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportBundle value)  $default,){
final _that = this;
switch (_that) {
case _ExportBundle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportBundle value)?  $default,){
final _that = this;
switch (_that) {
case _ExportBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String schemaVersion,  DateTime generatedAt,  List<AccountEntity> accounts,  List<TransactionEntity> transactions,  List<Category> categories,  List<TagEntity> tags,  List<TransactionTagEntity> transactionTags,  List<SavingGoal> savingGoals,  List<CreditEntity> credits,  List<CreditCardEntity> creditCards,  List<DebtEntity> debts,  List<Budget> budgets,  List<BudgetInstance> budgetInstances,  List<UpcomingPayment> upcomingPayments,  List<PaymentReminder> paymentReminders,  Profile? profile,  UserProgress? progress,  ExportBundleIntegrity? integrity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportBundle() when $default != null:
return $default(_that.schemaVersion,_that.generatedAt,_that.accounts,_that.transactions,_that.categories,_that.tags,_that.transactionTags,_that.savingGoals,_that.credits,_that.creditCards,_that.debts,_that.budgets,_that.budgetInstances,_that.upcomingPayments,_that.paymentReminders,_that.profile,_that.progress,_that.integrity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String schemaVersion,  DateTime generatedAt,  List<AccountEntity> accounts,  List<TransactionEntity> transactions,  List<Category> categories,  List<TagEntity> tags,  List<TransactionTagEntity> transactionTags,  List<SavingGoal> savingGoals,  List<CreditEntity> credits,  List<CreditCardEntity> creditCards,  List<DebtEntity> debts,  List<Budget> budgets,  List<BudgetInstance> budgetInstances,  List<UpcomingPayment> upcomingPayments,  List<PaymentReminder> paymentReminders,  Profile? profile,  UserProgress? progress,  ExportBundleIntegrity? integrity)  $default,) {final _that = this;
switch (_that) {
case _ExportBundle():
return $default(_that.schemaVersion,_that.generatedAt,_that.accounts,_that.transactions,_that.categories,_that.tags,_that.transactionTags,_that.savingGoals,_that.credits,_that.creditCards,_that.debts,_that.budgets,_that.budgetInstances,_that.upcomingPayments,_that.paymentReminders,_that.profile,_that.progress,_that.integrity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String schemaVersion,  DateTime generatedAt,  List<AccountEntity> accounts,  List<TransactionEntity> transactions,  List<Category> categories,  List<TagEntity> tags,  List<TransactionTagEntity> transactionTags,  List<SavingGoal> savingGoals,  List<CreditEntity> credits,  List<CreditCardEntity> creditCards,  List<DebtEntity> debts,  List<Budget> budgets,  List<BudgetInstance> budgetInstances,  List<UpcomingPayment> upcomingPayments,  List<PaymentReminder> paymentReminders,  Profile? profile,  UserProgress? progress,  ExportBundleIntegrity? integrity)?  $default,) {final _that = this;
switch (_that) {
case _ExportBundle() when $default != null:
return $default(_that.schemaVersion,_that.generatedAt,_that.accounts,_that.transactions,_that.categories,_that.tags,_that.transactionTags,_that.savingGoals,_that.credits,_that.creditCards,_that.debts,_that.budgets,_that.budgetInstances,_that.upcomingPayments,_that.paymentReminders,_that.profile,_that.progress,_that.integrity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportBundle extends ExportBundle {
  const _ExportBundle({required this.schemaVersion, required this.generatedAt, final  List<AccountEntity> accounts = const <AccountEntity>[], final  List<TransactionEntity> transactions = const <TransactionEntity>[], final  List<Category> categories = const <Category>[], final  List<TagEntity> tags = const <TagEntity>[], final  List<TransactionTagEntity> transactionTags = const <TransactionTagEntity>[], final  List<SavingGoal> savingGoals = const <SavingGoal>[], final  List<CreditEntity> credits = const <CreditEntity>[], final  List<CreditCardEntity> creditCards = const <CreditCardEntity>[], final  List<DebtEntity> debts = const <DebtEntity>[], final  List<Budget> budgets = const <Budget>[], final  List<BudgetInstance> budgetInstances = const <BudgetInstance>[], final  List<UpcomingPayment> upcomingPayments = const <UpcomingPayment>[], final  List<PaymentReminder> paymentReminders = const <PaymentReminder>[], this.profile, this.progress, this.integrity}): _accounts = accounts,_transactions = transactions,_categories = categories,_tags = tags,_transactionTags = transactionTags,_savingGoals = savingGoals,_credits = credits,_creditCards = creditCards,_debts = debts,_budgets = budgets,_budgetInstances = budgetInstances,_upcomingPayments = upcomingPayments,_paymentReminders = paymentReminders,super._();
  factory _ExportBundle.fromJson(Map<String, dynamic> json) => _$ExportBundleFromJson(json);

/// Версия схемы экспортируемых данных.
@override final  String schemaVersion;
/// Временная метка формирования бандла.
@override final  DateTime generatedAt;
/// Набор локальных счетов.
 final  List<AccountEntity> _accounts;
/// Набор локальных счетов.
@override@JsonKey() List<AccountEntity> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

/// Набор локальных транзакций.
 final  List<TransactionEntity> _transactions;
/// Набор локальных транзакций.
@override@JsonKey() List<TransactionEntity> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}

/// Набор локальных категорий.
 final  List<Category> _categories;
/// Набор локальных категорий.
@override@JsonKey() List<Category> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// Набор локальных тегов.
 final  List<TagEntity> _tags;
/// Набор локальных тегов.
@override@JsonKey() List<TagEntity> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// Набор связей транзакций и тегов.
 final  List<TransactionTagEntity> _transactionTags;
/// Набор связей транзакций и тегов.
@override@JsonKey() List<TransactionTagEntity> get transactionTags {
  if (_transactionTags is EqualUnmodifiableListView) return _transactionTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactionTags);
}

/// Набор локальных целей накоплений.
 final  List<SavingGoal> _savingGoals;
/// Набор локальных целей накоплений.
@override@JsonKey() List<SavingGoal> get savingGoals {
  if (_savingGoals is EqualUnmodifiableListView) return _savingGoals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savingGoals);
}

/// Набор локальных кредитов.
 final  List<CreditEntity> _credits;
/// Набор локальных кредитов.
@override@JsonKey() List<CreditEntity> get credits {
  if (_credits is EqualUnmodifiableListView) return _credits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_credits);
}

/// Набор локальных кредитных карт.
 final  List<CreditCardEntity> _creditCards;
/// Набор локальных кредитных карт.
@override@JsonKey() List<CreditCardEntity> get creditCards {
  if (_creditCards is EqualUnmodifiableListView) return _creditCards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_creditCards);
}

/// Набор локальных долгов.
 final  List<DebtEntity> _debts;
/// Набор локальных долгов.
@override@JsonKey() List<DebtEntity> get debts {
  if (_debts is EqualUnmodifiableListView) return _debts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_debts);
}

/// Набор локальных бюджетов.
 final  List<Budget> _budgets;
/// Набор локальных бюджетов.
@override@JsonKey() List<Budget> get budgets {
  if (_budgets is EqualUnmodifiableListView) return _budgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_budgets);
}

/// Набор локальных инстансов бюджетов.
 final  List<BudgetInstance> _budgetInstances;
/// Набор локальных инстансов бюджетов.
@override@JsonKey() List<BudgetInstance> get budgetInstances {
  if (_budgetInstances is EqualUnmodifiableListView) return _budgetInstances;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_budgetInstances);
}

/// Набор локальных recurring payments.
 final  List<UpcomingPayment> _upcomingPayments;
/// Набор локальных recurring payments.
@override@JsonKey() List<UpcomingPayment> get upcomingPayments {
  if (_upcomingPayments is EqualUnmodifiableListView) return _upcomingPayments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upcomingPayments);
}

/// Набор локальных reminders.
 final  List<PaymentReminder> _paymentReminders;
/// Набор локальных reminders.
@override@JsonKey() List<PaymentReminder> get paymentReminders {
  if (_paymentReminders is EqualUnmodifiableListView) return _paymentReminders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paymentReminders);
}

/// Локальный профиль пользователя, если он доступен в кэше.
@override final  Profile? profile;
/// Снимок пользовательского прогресса на момент экспорта.
@override final  UserProgress? progress;
/// Метаданные целостности для каноничного JSON-экспорта.
@override final  ExportBundleIntegrity? integrity;

/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportBundleCopyWith<_ExportBundle> get copyWith => __$ExportBundleCopyWithImpl<_ExportBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportBundleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportBundle&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&const DeepCollectionEquality().equals(other._transactions, _transactions)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._transactionTags, _transactionTags)&&const DeepCollectionEquality().equals(other._savingGoals, _savingGoals)&&const DeepCollectionEquality().equals(other._credits, _credits)&&const DeepCollectionEquality().equals(other._creditCards, _creditCards)&&const DeepCollectionEquality().equals(other._debts, _debts)&&const DeepCollectionEquality().equals(other._budgets, _budgets)&&const DeepCollectionEquality().equals(other._budgetInstances, _budgetInstances)&&const DeepCollectionEquality().equals(other._upcomingPayments, _upcomingPayments)&&const DeepCollectionEquality().equals(other._paymentReminders, _paymentReminders)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.integrity, integrity) || other.integrity == integrity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,generatedAt,const DeepCollectionEquality().hash(_accounts),const DeepCollectionEquality().hash(_transactions),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_transactionTags),const DeepCollectionEquality().hash(_savingGoals),const DeepCollectionEquality().hash(_credits),const DeepCollectionEquality().hash(_creditCards),const DeepCollectionEquality().hash(_debts),const DeepCollectionEquality().hash(_budgets),const DeepCollectionEquality().hash(_budgetInstances),const DeepCollectionEquality().hash(_upcomingPayments),const DeepCollectionEquality().hash(_paymentReminders),profile,progress,integrity);

@override
String toString() {
  return 'ExportBundle(schemaVersion: $schemaVersion, generatedAt: $generatedAt, accounts: $accounts, transactions: $transactions, categories: $categories, tags: $tags, transactionTags: $transactionTags, savingGoals: $savingGoals, credits: $credits, creditCards: $creditCards, debts: $debts, budgets: $budgets, budgetInstances: $budgetInstances, upcomingPayments: $upcomingPayments, paymentReminders: $paymentReminders, profile: $profile, progress: $progress, integrity: $integrity)';
}


}

/// @nodoc
abstract mixin class _$ExportBundleCopyWith<$Res> implements $ExportBundleCopyWith<$Res> {
  factory _$ExportBundleCopyWith(_ExportBundle value, $Res Function(_ExportBundle) _then) = __$ExportBundleCopyWithImpl;
@override @useResult
$Res call({
 String schemaVersion, DateTime generatedAt, List<AccountEntity> accounts, List<TransactionEntity> transactions, List<Category> categories, List<TagEntity> tags, List<TransactionTagEntity> transactionTags, List<SavingGoal> savingGoals, List<CreditEntity> credits, List<CreditCardEntity> creditCards, List<DebtEntity> debts, List<Budget> budgets, List<BudgetInstance> budgetInstances, List<UpcomingPayment> upcomingPayments, List<PaymentReminder> paymentReminders, Profile? profile, UserProgress? progress, ExportBundleIntegrity? integrity
});


@override $ProfileCopyWith<$Res>? get profile;@override $UserProgressCopyWith<$Res>? get progress;@override $ExportBundleIntegrityCopyWith<$Res>? get integrity;

}
/// @nodoc
class __$ExportBundleCopyWithImpl<$Res>
    implements _$ExportBundleCopyWith<$Res> {
  __$ExportBundleCopyWithImpl(this._self, this._then);

  final _ExportBundle _self;
  final $Res Function(_ExportBundle) _then;

/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? generatedAt = null,Object? accounts = null,Object? transactions = null,Object? categories = null,Object? tags = null,Object? transactionTags = null,Object? savingGoals = null,Object? credits = null,Object? creditCards = null,Object? debts = null,Object? budgets = null,Object? budgetInstances = null,Object? upcomingPayments = null,Object? paymentReminders = null,Object? profile = freezed,Object? progress = freezed,Object? integrity = freezed,}) {
  return _then(_ExportBundle(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountEntity>,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntity>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagEntity>,transactionTags: null == transactionTags ? _self._transactionTags : transactionTags // ignore: cast_nullable_to_non_nullable
as List<TransactionTagEntity>,savingGoals: null == savingGoals ? _self._savingGoals : savingGoals // ignore: cast_nullable_to_non_nullable
as List<SavingGoal>,credits: null == credits ? _self._credits : credits // ignore: cast_nullable_to_non_nullable
as List<CreditEntity>,creditCards: null == creditCards ? _self._creditCards : creditCards // ignore: cast_nullable_to_non_nullable
as List<CreditCardEntity>,debts: null == debts ? _self._debts : debts // ignore: cast_nullable_to_non_nullable
as List<DebtEntity>,budgets: null == budgets ? _self._budgets : budgets // ignore: cast_nullable_to_non_nullable
as List<Budget>,budgetInstances: null == budgetInstances ? _self._budgetInstances : budgetInstances // ignore: cast_nullable_to_non_nullable
as List<BudgetInstance>,upcomingPayments: null == upcomingPayments ? _self._upcomingPayments : upcomingPayments // ignore: cast_nullable_to_non_nullable
as List<UpcomingPayment>,paymentReminders: null == paymentReminders ? _self._paymentReminders : paymentReminders // ignore: cast_nullable_to_non_nullable
as List<PaymentReminder>,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as UserProgress?,integrity: freezed == integrity ? _self.integrity : integrity // ignore: cast_nullable_to_non_nullable
as ExportBundleIntegrity?,
  ));
}

/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $UserProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}/// Create a copy of ExportBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExportBundleIntegrityCopyWith<$Res>? get integrity {
    if (_self.integrity == null) {
    return null;
  }

  return $ExportBundleIntegrityCopyWith<$Res>(_self.integrity!, (value) {
    return _then(_self.copyWith(integrity: value));
  });
}
}

// dart format on
