import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'category_form_controller.freezed.dart';
part 'category_form_controller.g.dart';

const String _kDefaultCategoryType = 'expense';

@immutable
class CategoryFormParams {
  const CategoryFormParams({
    this.initial,
    this.parents = const <Category>[],
    this.defaultParentId,
  });

  final Category? initial;
  final List<Category> parents;
  final String? defaultParentId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CategoryFormParams &&
            other.initial == initial &&
            other.defaultParentId == defaultParentId &&
            const ListEquality<Category>().equals(other.parents, parents);
  }

  @override
  int get hashCode =>
      Object.hash(initial, defaultParentId, Object.hashAll(parents));
}

@freezed
abstract class CategoryFormState with _$CategoryFormState {
  const factory CategoryFormState({
    required String id,
    required String name,
    required String type,
    PhosphorIconDescriptor? icon,
    @Default('') String color,
    String? parentId,
    String? initialParentId,
    @Default(<Category>[]) List<Category> availableParents,
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
    final String normalizedColor = color.trim();
    final PhosphorIconDescriptor? normalizedIcon =
        icon != null && icon!.isNotEmpty ? icon : null;
    final PhosphorIconDescriptor? baseIcon =
        base?.icon != null && base!.icon!.isNotEmpty ? base.icon : null;
    final String? normalizedParent = _normalizeParentId(parentId);
    final String? baseParent = base != null
        ? _normalizeParentId(base.parentId)
        : _normalizeParentId(initialParentId);
    if (base == null) {
      return trimmedName.isNotEmpty ||
          type != _kDefaultCategoryType ||
          normalizedIcon != null ||
          normalizedColor.isNotEmpty ||
          normalizedParent != baseParent;
    }
    return trimmedName != base.name ||
        type != base.type ||
        !_iconEquals(normalizedIcon, baseIcon) ||
        normalizedColor != (base.color ?? '').trim() ||
        normalizedParent != baseParent;
  }

  Category? get selectedParent {
    if (parentId == null) {
      return null;
    }
    for (final Category parent in availableParents) {
      if (parent.id == parentId) {
        return parent;
      }
    }
    return null;
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
    final List<Category> parents = List<Category>.unmodifiable(params.parents);
    final String? defaultParentId = initial?.parentId ?? params.defaultParentId;
    return CategoryFormState(
      id: initial?.id ?? _uuid.v4(),
      name: initial?.name ?? '',
      type: initial?.type ?? _kDefaultCategoryType,
      icon: initial?.icon,
      color: initial?.color ?? '',
      parentId: defaultParentId,
      initialParentId: defaultParentId,
      availableParents: parents,
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

  void updateIcon(PhosphorIconDescriptor? value) {
    state = state.copyWith(icon: value, isSuccess: false);
  }

  void updateColor(String value) {
    state = state.copyWith(color: value, isSuccess: false);
  }

  void updateParent(String? value) {
    final String? normalized = _normalizeParentId(value);
    if (normalized == state.parentId) {
      return;
    }
    state = state.copyWith(parentId: normalized, isSuccess: false);
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

    final String normalizedColor = state.color.trim();
    final PhosphorIconDescriptor? descriptor =
        state.icon != null && state.icon!.isNotEmpty ? state.icon : null;
    final String? normalizedParentId = _normalizeParentId(state.parentId);
    final DateTime now = DateTime.now().toUtc();
    final DateTime createdAt = state.initialCategory?.createdAt ?? now;
    final Category base =
        state.initialCategory ??
        Category(
          id: state.id,
          name: trimmedName,
          type: state.type,
          icon: descriptor,
          color: normalizedColor.isEmpty ? null : normalizedColor,
          parentId: normalizedParentId,
          createdAt: createdAt,
          updatedAt: createdAt,
        );
    final Category toSave = base.copyWith(
      name: trimmedName,
      type: state.type,
      icon: descriptor,
      color: normalizedColor.isEmpty ? null : normalizedColor,
      parentId: normalizedParentId,
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
        icon: toSave.icon,
        color: toSave.color ?? '',
        parentId: toSave.parentId,
        initialParentId: toSave.parentId,
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

String? _normalizeParentId(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return value.trim();
}

bool _iconEquals(PhosphorIconDescriptor? left, PhosphorIconDescriptor? right) {
  if (identical(left, right)) {
    return true;
  }
  if (left == null || right == null) {
    return left == right;
  }
  return left.name == right.name && left.style == right.style;
}
