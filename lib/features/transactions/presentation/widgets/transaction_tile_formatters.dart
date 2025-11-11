import 'package:intl/intl.dart';

class TransactionTileFormatters {
  const TransactionTileFormatters._();

  static final Map<String, NumberFormat> _currencyCache =
      <String, NumberFormat>{};
  static final Map<String, String> _fallbackSymbols = <String, String>{};
  static final Map<String, DateFormat> _dayHeaderCache = <String, DateFormat>{};

  static DateFormat dayHeader(String locale) {
    return _dayHeaderCache.putIfAbsent(locale, () => DateFormat.yMMMMd(locale));
  }

  static NumberFormat currency(
    String locale,
    String symbol, {
    int? decimalDigits,
  }) {
    final String cacheKey = '$locale|$symbol|${decimalDigits ?? 'default'}';
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
}
