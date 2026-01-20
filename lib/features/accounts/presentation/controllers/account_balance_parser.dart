import 'package:kopim/core/money/money_utils.dart';

/// Парсит ввод баланса в [MoneyAmount].
///
/// Поддерживает запятую и точку как разделители. Возвращает `null`, если
/// значение не удалось разобрать. Пустая строка трактуется как ноль.
MoneyAmount? parseBalanceInput(String input, {required int scale}) {
  final String trimmed = input.trim();
  if (trimmed.isEmpty) {
    return MoneyAmount(minor: BigInt.zero, scale: scale);
  }

  final String normalized = trimmed.replaceAll(',', '.');
  return tryParseMoneyAmount(input: normalized, scale: scale);
}
