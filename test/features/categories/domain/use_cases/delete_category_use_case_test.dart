import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late _MockCategoryRepository repository;
  late DeleteCategoryUseCase useCase;

  setUp(() {
    repository = _MockCategoryRepository();
    useCase = DeleteCategoryUseCase(repository);
  });

  test('delegates to repository for soft delete', () async {
    when(() => repository.softDelete('cat-1')).thenAnswer((_) async {});

    await useCase('cat-1');

    verify(() => repository.softDelete('cat-1')).called(1);
  });

  test('bubbles up repository errors', () async {
    when(() => repository.softDelete('cat-2')).thenThrow(StateError('failed'));

    expect(() => useCase('cat-2'), throwsStateError);
    verify(() => repository.softDelete('cat-2')).called(1);
  });
}
