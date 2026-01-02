import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/use_cases/export_user_data_use_case.dart';

part 'export_user_data_controller.g.dart';

@riverpod
class ExportUserDataController extends _$ExportUserDataController {
  @override
  AsyncValue<ExportFileSaveResult?> build() {
    return const AsyncValue<ExportFileSaveResult?>.data(null);
  }

  Future<void> export({
    String? directoryPath,
    DataTransferFormat format = DataTransferFormat.csv,
  }) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncValue<ExportFileSaveResult?>.loading();
    try {
      final ExportFileSaveResult result = await ref
          .read(exportUserDataUseCaseProvider)
          .call(
            ExportUserDataParams(directoryPath: directoryPath, format: format),
          );
      if (!ref.mounted) {
        return;
      }
      state = AsyncValue<ExportFileSaveResult?>.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue<ExportFileSaveResult?>.error(error, stackTrace);
    }
  }

  void clearResult() {
    state = const AsyncValue<ExportFileSaveResult?>.data(null);
  }
}
