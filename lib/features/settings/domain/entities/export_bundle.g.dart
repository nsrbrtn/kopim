// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExportBundle _$ExportBundleFromJson(
  Map<String, dynamic> json,
) => _ExportBundle(
  schemaVersion: json['schemaVersion'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  accounts:
      (json['accounts'] as List<dynamic>?)
          ?.map((e) => AccountEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AccountEntity>[],
  transactions:
      (json['transactions'] as List<dynamic>?)
          ?.map((e) => TransactionEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TransactionEntity>[],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Category>[],
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => TagEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TagEntity>[],
  transactionTags:
      (json['transactionTags'] as List<dynamic>?)
          ?.map((e) => TransactionTagEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TransactionTagEntity>[],
  savingGoals:
      (json['savingGoals'] as List<dynamic>?)
          ?.map((e) => SavingGoal.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SavingGoal>[],
  credits:
      (json['credits'] as List<dynamic>?)
          ?.map((e) => CreditEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CreditEntity>[],
  creditCards:
      (json['creditCards'] as List<dynamic>?)
          ?.map((e) => CreditCardEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CreditCardEntity>[],
  debts:
      (json['debts'] as List<dynamic>?)
          ?.map((e) => DebtEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DebtEntity>[],
  budgets:
      (json['budgets'] as List<dynamic>?)
          ?.map((e) => Budget.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Budget>[],
  budgetInstances:
      (json['budgetInstances'] as List<dynamic>?)
          ?.map((e) => BudgetInstance.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BudgetInstance>[],
  upcomingPayments:
      (json['upcomingPayments'] as List<dynamic>?)
          ?.map((e) => UpcomingPayment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <UpcomingPayment>[],
  paymentReminders:
      (json['paymentReminders'] as List<dynamic>?)
          ?.map((e) => PaymentReminder.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PaymentReminder>[],
);

Map<String, dynamic> _$ExportBundleToJson(_ExportBundle instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'accounts': instance.accounts,
      'transactions': instance.transactions,
      'categories': instance.categories,
      'tags': instance.tags,
      'transactionTags': instance.transactionTags,
      'savingGoals': instance.savingGoals,
      'credits': instance.credits,
      'creditCards': instance.creditCards,
      'debts': instance.debts,
      'budgets': instance.budgets,
      'budgetInstances': instance.budgetInstances,
      'upcomingPayments': instance.upcomingPayments,
      'paymentReminders': instance.paymentReminders,
    };
