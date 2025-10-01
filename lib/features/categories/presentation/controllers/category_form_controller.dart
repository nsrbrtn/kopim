import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'category_form_controller.freezed.dart';
part 'category_form_controller.g.dart';

const String _kDefaultCategoryType = 'expense';

@immutable
class CategoryFormParams {
  const CategoryFormParams({this.initial});

  final Category? initial;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CategoryFormParams && other.initial == initial;
  }

  @override
  int get hashCode => initial.hashCode;
}

@freezed
abstract class CategoryFormState with _$CategoryFormState {
  const factory CategoryFormState({
    required String id,
    required String name,
    required String type,
    @Default('') String icon,
    @Default('') String color,
    required DateTime createdAt,
    required DateTime updatedAt,
    Category? initialCategory,
    @Default(false) bool isSaving,
    @Default(false) bool isSuccess,
    String? errorMessage,
    @Default(false) bool showValidationError,
    @Default(false) bool isNew,
  }) = _CategoryFormState;

  const CategoryFormState._();

  bool get nameHasError => showValidationError && name.trim().isEmpty;

  bool get canSubmit => !isSaving && name.trim().isNotEmpty;

  bool get hasChanges {
    final Category? base = initialCategory;
    final String trimmedName = name.trim();
    final String normalizedIcon = icon.trim();
    final String normalizedColor = color.trim();
    if (base == null) {
      return trimmedName.isNotEmpty ||
          type != _kDefaultCategoryType ||
          normalizedIcon.isNotEmpty ||
          normalizedColor.isNotEmpty;
    }
    return trimmedName != base.name ||
        type != base.type ||
        normalizedIcon != (base.icon ?? '').trim() ||
        normalizedColor != (base.color ?? '').trim();
  }
}

@riverpod
class CategoryFormController extends _$CategoryFormController {
  late final SaveCategoryUseCase _saveCategoryUseCase;
  late final Uuid _uuid;

  @override
  CategoryFormState build(CategoryFormParams params) {
    _saveCategoryUseCase = ref.watch(saveCategoryUseCaseProvider);
    _uuid = ref.watch(uuidGeneratorProvider);

    final Category? initial = params.initial;
    final DateTime now = DateTime.now().toUtc();
    return CategoryFormState(
      id: initial?.id ?? _uuid.v4(),
      name: initial?.name ?? '',
      type: initial?.type ?? _kDefaultCategoryType,
      icon: initial?.icon ?? '',
      color: initial?.color ?? '',
      createdAt: initial?.createdAt ?? now,
      updatedAt: initial?.updatedAt ?? now,
      initialCategory: initial,
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

  void updateType(String value) {
    if (value.isEmpty || value == state.type) {
      return;
    }
    state = state.copyWith(type: value, isSuccess: false);
  }

  void updateIcon(String value) {
    state = state.copyWith(icon: value, isSuccess: false);
  }

  void updateColor(String value) {
    state = state.copyWith(color: value, isSuccess: false);
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
    if (trimmedName.isEmpty) {
      state = state.copyWith(showValidationError: true);
      return;
    }

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      showValidationError: false,
      isSuccess: false,
    );

    final String normalizedIcon = state.icon.trim();
    final String normalizedColor = state.color.trim();
    final DateTime now = DateTime.now().toUtc();
    final DateTime createdAt = state.initialCategory?.createdAt ?? now;
    final Category base =
        state.initialCategory ??
        Category(
          id: state.id,
          name: trimmedName,
          type: state.type,
          icon: normalizedIcon.isEmpty ? null : normalizedIcon,
          color: normalizedColor.isEmpty ? null : normalizedColor,
          createdAt: createdAt,
          updatedAt: createdAt,
        );
    final Category toSave = base.copyWith(
      name: trimmedName,
      type: state.type,
      icon: normalizedIcon.isEmpty ? null : normalizedIcon,
      color: normalizedColor.isEmpty ? null : normalizedColor,
      updatedAt: now,
    );

    try {
      await _saveCategoryUseCase(toSave);
      state = state.copyWith(
        isSaving: false,
        isSuccess: true,
        errorMessage: null,
        initialCategory: toSave,
        name: toSave.name,
        type: toSave.type,
        icon: toSave.icon ?? '',
        color: toSave.color ?? '',
        createdAt: toSave.createdAt,
        updatedAt: toSave.updatedAt,
        isNew: false,
      );
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.toString(),
        isSuccess: false,
      );
    }
  }
}
