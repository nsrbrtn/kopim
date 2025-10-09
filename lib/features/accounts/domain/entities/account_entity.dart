import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_entity.freezed.dart';
part 'account_entity.g.dart';

@freezed
abstract class AccountEntity with _$AccountEntity {
  const AccountEntity._();

  const factory AccountEntity({
    required String id,
    required String name,
    required double balance,
    required String currency,
    required String type,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
    @Default(false) bool isPrimary,
  }) = _AccountEntity;

  factory AccountEntity.fromJson(Map<String, Object?> json) =>
      _$AccountEntityFromJson(json);
}
