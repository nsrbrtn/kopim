import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:kopim/features/categories/presentation/controllers/category_form_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/src/framework.dart';
import 'package:uuid/uuid.dart';

class _MockSaveCategoryUseCase extends Mock implements SaveCategoryUseCase {}

class _MockUuid extends Mock implements Uuid {}

Category _fallbackCategory() {
  final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );
  return Category(
    id: 'id',
    name: 'name',
    type: 'expense',
    icon: null,
    color: null,
    parentId: null,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_fallbackCategory());
  });

  late ProviderContainer container;
  late _MockSaveCategoryUseCase mockUseCase;
  late _MockUuid mockUuid;

  setUp(() {
    mockUseCase = _MockSaveCategoryUseCase();
    mockUuid = _MockUuid();
    when(() => mockUuid.v4()).thenReturn('uuid-123');
    container = ProviderContainer(
      overrides: <Override>[
        saveCategoryUseCaseProvider.overrideWithValue(mockUseCase),
        uuidGeneratorProvider.overrideWithValue(mockUuid),
      ],
    );
    addTearDown(container.dispose);
  });

  test('submit creates a new category with trimmed values', () async {
    when(() => mockUseCase.call(any())).thenAnswer((Invocation _) async {});

    final CategoryFormController controller = container.read(
      categoryFormControllerProvider(const CategoryFormParams()).notifier,
    );
    controller.updateName('  Groceries  ');
    controller.updateType('income');
    controller.updateIcon(
      const PhosphorIconDescriptor(name: 'airplane'),
    );
    controller.updateColor('#FFA500');

    await controller.submit();

    final Category captured = verify(
      () => mockUseCase.call(captureAny<Category>()),
    ).captured.single;

    expect(captured.id, 'uuid-123');
    expect(captured.name, 'Groceries');
    expect(captured.type, 'income');
    expect(captured.icon?.name, 'airplane');
    expect(captured.icon?.style, PhosphorIconStyle.regular);
    expect(captured.parentId, isNull);
    expect(captured.color, '#FFA500');
    expect(captured.createdAt.isUtc, isTrue);
    expect(captured.updatedAt.isUtc, isTrue);
    expect(captured.createdAt, captured.updatedAt);

    final CategoryFormState state = container.read(
      categoryFormControllerProvider(const CategoryFormParams()),
    );
    expect(state.isSuccess, isTrue);
    expect(state.initialCategory?.id, 'uuid-123');
    expect(state.hasChanges, isFalse);
  });

  test('submit updates existing category and preserves identifiers', () async {
    when(() => mockUseCase.call(any())).thenAnswer((Invocation _) async {});

    final DateTime createdAt = DateTime.utc(2024, 1, 1);
    final Category existing = Category(
      id: 'existing',
      name: 'Rent',
      type: 'expense',
      icon: const PhosphorIconDescriptor(name: 'house'),
      color: '#FF0000',
      parentId: null,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    final CategoryFormParams params = CategoryFormParams(initial: existing);

    final CategoryFormController controller = container.read(
      categoryFormControllerProvider(params).notifier,
    );
    controller.updateName(' Rent (Apartment) ');
    controller.updateColor('#CC0000');

    await controller.submit();

    final Category captured = verify(
      () => mockUseCase.call(captureAny<Category>()),
    ).captured.single;

    expect(captured.id, existing.id);
    expect(captured.createdAt, createdAt);
    expect(captured.updatedAt.isAfter(createdAt), isTrue);
    expect(captured.icon, existing.icon);
    expect(captured.color, '#CC0000');
    expect(captured.name, 'Rent (Apartment)');
    expect(captured.type, 'expense');

    final CategoryFormState state = container.read(
      categoryFormControllerProvider(params),
    );
    expect(state.isSuccess, isTrue);
    expect(state.initialCategory?.updatedAt, captured.updatedAt);
    expect(state.hasChanges, isFalse);
  });

  test('submit validates empty name without calling use case', () async {
    final CategoryFormController controller = container.read(
      categoryFormControllerProvider(const CategoryFormParams()).notifier,
    );

    await controller.submit();

    final CategoryFormState state = container.read(
      categoryFormControllerProvider(const CategoryFormParams()),
    );
    expect(state.nameHasError, isTrue);
    expect(state.isSuccess, isFalse);
    verifyNever(() => mockUseCase.call(any()));
  });

  test('submit includes selected parent id and clears icon', () async {
    when(() => mockUseCase.call(any())).thenAnswer((Invocation _) async {});

    final Category parent = Category(
      id: 'parent-1',
      name: 'Utilities',
      type: 'expense',
      icon: const PhosphorIconDescriptor(name: 'plug'),
      color: null,
      parentId: null,
      createdAt: DateTime.utc(2024, 1, 1),
      updatedAt: DateTime.utc(2024, 1, 1),
    );

    final CategoryFormController controller = container.read(
      categoryFormControllerProvider(
        CategoryFormParams(parents: <Category>[parent]),
      ).notifier,
    );

    controller.updateParent(parent.id);
    controller.updateIcon(
      const PhosphorIconDescriptor(name: 'airplane'),
    );
    controller.updateIcon(null);
    controller.updateName('Electricity');

    await controller.submit();

    final Category captured = verify(
      () => mockUseCase.call(captureAny<Category>()),
    ).captured.single;

    expect(captured.parentId, parent.id);
    expect(captured.icon, isNull);
  });
}
