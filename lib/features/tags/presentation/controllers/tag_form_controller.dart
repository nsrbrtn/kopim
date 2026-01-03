import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/use_cases/save_tag_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'tag_form_controller.freezed.dart';
part 'tag_form_controller.g.dart';

@immutable
class TagFormParams {
  const TagFormParams({this.initial});

  final TagEntity? initial;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagFormParams && other.initial == initial;
  }

  @override
  int get hashCode => initial.hashCode;
}

@freezed
abstract class TagFormState with _$TagFormState {
  const factory TagFormState({
    required String id,
    required String name,
    required String color,
    required DateTime createdAt,
    required DateTime updatedAt,
    TagEntity? initialTag,
    @Default(false) bool isSaving,
    @Default(false) bool isSuccess,
    String? errorMessage,
    @Default(false) bool showValidationError,
    @Default(false) bool isNew,
  }) = _TagFormState;

  const TagFormState._();

  bool get nameHasError => showValidationError && name.trim().isEmpty;

  bool get colorHasError => showValidationError && color.trim().isEmpty;

  bool get canSubmit => !isSaving && name.trim().isNotEmpty;

  bool get hasChanges {
    final TagEntity? base = initialTag;
    final String trimmedName = name.trim();
    final String normalizedColor = color.trim();
    if (base == null) {
      return trimmedName.isNotEmpty || normalizedColor.isNotEmpty;
    }
    return trimmedName != base.name || normalizedColor != base.color;
  }
}

@riverpod
class TagFormController extends _$TagFormController {
  late final SaveTagUseCase _saveTagUseCase;
  late final Uuid _uuid;

  @override
  TagFormState build(TagFormParams params) {
    _saveTagUseCase = ref.watch(saveTagUseCaseProvider);
    _uuid = ref.watch(uuidGeneratorProvider);

    final TagEntity? initial = params.initial;
    final DateTime now = DateTime.now().toUtc();
    return TagFormState(
      id: initial?.id ?? _uuid.v4(),
      name: initial?.name ?? '',
      color: initial?.color ?? '',
      createdAt: initial?.createdAt ?? now,
      updatedAt: initial?.updatedAt ?? now,
      initialTag: initial,
      isNew: initial == null,
    );
  }

  void updateName(String value) {
    state = state.copyWith(
      name: value,
      showValidationError: false,
      errorMessage: null,
      isSuccess: false,
    );
  }

  void updateColor(String? value) {
    state = state.copyWith(color: value ?? '', isSuccess: false);
  }

  void resetSuccess() {
    if (state.isSuccess) {
      state = state.copyWith(isSuccess: false);
    }
  }

  Future<void> submit() async {
    if (state.isSaving) {
      return;
    }

    final String trimmedName = state.name.trim();
    if (trimmedName.isEmpty || state.color.trim().isEmpty) {
      state = state.copyWith(showValidationError: true);
      return;
    }

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      showValidationError: false,
      isSuccess: false,
    );

    final DateTime now = DateTime.now().toUtc();
    final DateTime createdAt = state.initialTag?.createdAt ?? now;
    final TagEntity base =
        state.initialTag ??
        TagEntity(
          id: state.id,
          name: trimmedName,
          color: state.color.trim(),
          createdAt: createdAt,
          updatedAt: createdAt,
        );
    try {
      await _saveTagUseCase(
        base.copyWith(
          name: trimmedName,
          color: state.color.trim(),
          updatedAt: now,
        ),
      );
      state = state.copyWith(
        isSaving: false,
        isSuccess: true,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.toString(),
      );
    }
  }
}
