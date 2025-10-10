/// Обёртка для опционального обновления поля.
class ValueUpdate<T> {
  const ValueUpdate._(this.value, this.isPresent);

  /// Отсутствие обновления.
  const ValueUpdate.absent() : this._(null, false);

  /// Передача нового значения (включая `null`).
  const ValueUpdate.present(T? value) : this._(value, true);

  /// Значение обновления. Может быть `null`.
  final T? value;

  /// Флаг наличия обновления.
  final bool isPresent;
}
