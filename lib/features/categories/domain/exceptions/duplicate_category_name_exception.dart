class DuplicateCategoryNameException implements Exception {
  const DuplicateCategoryNameException();

  @override
  String toString() => 'duplicate_category_name';
}
