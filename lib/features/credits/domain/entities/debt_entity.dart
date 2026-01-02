import 'package:freezed_annotation/freezed_annotation.dart';

part 'debt_entity.freezed.dart';
part 'debt_entity.g.dart';

@freezed
abstract class DebtEntity with _$DebtEntity {
  const factory DebtEntity({
    required String id,
    required String accountId,
    @Default('') String name,
    required double amount,
    required DateTime dueDate,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _DebtEntity;

  factory DebtEntity.fromJson(Map<String, Object?> json) =>
      _$DebtEntityFromJson(json);
}
