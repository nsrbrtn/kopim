import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_use_case.dart';

part 'import_user_data_controller.g.dart';

@riverpod
class ImportUserDataController extends _$ImportUserDataController {
  @override
  AsyncValue<ImportUserDataResult?> build() {
    return const AsyncValue<ImportUserDataResult?>.data(null);
  }

  Future<void> importData({
    DataTransferFormat format = DataTransferFormat.csv,
  }) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncValue<ImportUserDataResult?>.loading();
    try {
      final ImportUserDataResult result = await ref
          .read(importUserDataUseCaseProvider)
          .call(ImportUserDataParams(format: format));
      if (!ref.mounted) {
        return;
      }
      state = AsyncValue<ImportUserDataResult?>.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue<ImportUserDataResult?>.error(error, stackTrace);
    }
  }

  void clearResult() {
    state = const AsyncValue<ImportUserDataResult?>.data(null);
  }
}
