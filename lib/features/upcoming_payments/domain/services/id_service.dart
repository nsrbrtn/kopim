import 'package:uuid/uuid.dart';

/// Сервис генерации идентификаторов домена.
abstract class IdService {
  /// Возвращает новый уникальный идентификатор.
  String generate();
}

/// Реализация на базе UUID v4.
class UuidIdService implements IdService {
  UuidIdService(this._uuid);

  final Uuid _uuid;

  @override
  String generate() => _uuid.v4();
}
