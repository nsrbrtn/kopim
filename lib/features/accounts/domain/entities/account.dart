import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';  // Генерирует иммутабельные методы (copyWith, ==)
part 'account.g.dart';  // Генерирует JSON-сериализацию для Firebase sync

@freezed
class Account with _$Account {
  const factory Account({
    required String id,  // UUID для уникальности и sync
    required String name,
    required double balance,
    required String currency,  // 'USD', 'EUR' для мульти-валюты
    required String type,  // 'savings', 'checking' для аналитики
  }) = _Account;

  factory Account.fromJson(Map<String, Object?> json) => _$AccountFromJson(json);  // Для десериализации из Firestore/Drift
}