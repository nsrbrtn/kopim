import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_user_data_result.freezed.dart';

/// Результат выполнения импорта пользовательских данных.
@freezed
class ImportUserDataResult with _$ImportUserDataResult {
  const factory ImportUserDataResult.success({
    required int accounts,
    required int categories,
    required int transactions,
  }) = ImportUserDataResultSuccess;

  const factory ImportUserDataResult.cancelled() =
      ImportUserDataResultCancelled;

  const factory ImportUserDataResult.failure(String message) =
      ImportUserDataResultFailure;
}
