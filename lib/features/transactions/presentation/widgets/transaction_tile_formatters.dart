import 'package:intl/intl.dart';
import 'package:kopim/core/money/money_utils.dart';

class TransactionTileFormatters {
  const TransactionTileFormatters._();

  static final Map<String, NumberFormat> _currencyCache =
      <String, NumberFormat>{};
  static final Map<String, String> _fallbackSymbols = <String, String>{};
  static final Map<String, DateFormat> _dayHeaderCache = <String, DateFormat>{};

  static DateFormat dayHeader(String locale) {
    return _dayHeaderCache.putIfAbsent(locale, () => DateFormat.yMMMMd(locale));
  }

  /// Возвращает кешированный форматтер валюты с учётом точности.
  static NumberFormat currency(
    String locale,
    String symbol, {
    int? decimalDigits,
  }) {
    final String decimalDigitsKey = decimalDigits == null
        ? 'default'
        : decimalDigits.toString();
    final String cacheKey = '$locale|$symbol|$decimalDigitsKey';
    return _currencyCache.putIfAbsent(
      cacheKey,
      () => NumberFormat.currency(
        locale: locale,
        symbol: symbol,
        decimalDigits: decimalDigits,
      ),
    );
  }

  static String fallbackCurrencySymbol(String locale) {
    return _fallbackSymbols.putIfAbsent(
      locale,
      () => NumberFormat.simpleCurrency(locale: locale).currencySymbol,
    );
  }

  static String formatAmount({
    required NumberFormat formatter,
    required double amount,
    BigInt? amountMinor,
    int? amountScale,
    bool useAbs = true,
  }) {
    final MoneyAmount resolved = resolveMoneyAmount(
      amount: amount,
      minor: amountMinor,
      scale: amountScale,
      useAbs: useAbs,
    );
    return formatter.format(resolved.toDouble());
  }
}
