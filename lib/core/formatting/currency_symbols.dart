import 'package:intl/intl.dart';

const Map<String, String> _explicitCurrencySymbols = <String, String>{
  'AUD': r'$',
  'CAD': r'$',
  'CHF': 'CHF',
  'CNY': '¥',
  'CZK': 'Kč',
  'EUR': '€',
  'GBP': '£',
  'HUF': 'Ft',
  'INR': '₹',
  'JPY': '¥',
  'KGS': 'лв',
  'KZT': '₸',
  'NOK': 'kr',
  'PLN': 'zł',
  'RUB': '₽',
  'SEK': 'kr',
  'TRY': '₺',
  'UAH': '₴',
  'USD': r'$',
};

final Map<String, String> _currencySymbolCache = <String, String>{};
final Map<String, NumberFormat> _currencyFormatCache = <String, NumberFormat>{};

String resolveCurrencySymbol(
  String? currencyCode, {
  String? locale,
  String fallback = '₽',
}) {
  final String code = (currencyCode ?? '').trim().toUpperCase();
  if (code.isEmpty) {
    return fallback;
  }

  final String localeKey = (locale?.isNotEmpty ?? false)
      ? locale!
      : ((Intl.getCurrentLocale().isNotEmpty
            ? Intl.getCurrentLocale()
            : Intl.defaultLocale ?? 'en_US'));
  final String cacheKey = '$code|$localeKey';

  return _currencySymbolCache.putIfAbsent(cacheKey, () {
    try {
      final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: localeKey,
        name: code,
      );
      final String symbol = formatter.currencySymbol;
      if (symbol.isNotEmpty && symbol != code) {
        return symbol;
      }
    } catch (_) {
      // Ignored, fallback to explicit map or code.
    }
    return _explicitCurrencySymbols[code] ?? code;
  });
}

String resolveFallbackCurrencySymbol(
  String locale, {
  String fallbackCurrencyCode = 'RUB',
}) {
  return resolveCurrencySymbol(
    fallbackCurrencyCode,
    locale: locale,
    fallback:
        _explicitCurrencySymbols[fallbackCurrencyCode] ?? fallbackCurrencyCode,
  );
}

NumberFormat resolveCurrencyFormat({
  required String locale,
  String? currencyCode,
  int? decimalDigits,
  String fallbackCurrencyCode = 'RUB',
}) {
  final String resolvedCode = (currencyCode ?? '').trim().isEmpty
      ? fallbackCurrencyCode
      : currencyCode!.trim().toUpperCase();
  final String symbol = resolveCurrencySymbol(
    resolvedCode,
    locale: locale,
    fallback:
        _explicitCurrencySymbols[fallbackCurrencyCode] ?? fallbackCurrencyCode,
  );
  final String digitsKey = decimalDigits?.toString() ?? 'default';
  final String cacheKey = '$locale|$resolvedCode|$digitsKey';

  return _currencyFormatCache.putIfAbsent(
    cacheKey,
    () => NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    ),
  );
}
