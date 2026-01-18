const Map<String, int> kCurrencyScale = <String, int>{
  'USD': 2,
  'EUR': 2,
  'RUB': 2,
  'JPY': 0,
  'BTC': 8,
  'ETH': 18,
};

int resolveCurrencyScale(String currency, {int defaultScale = 2}) {
  return kCurrencyScale[currency.toUpperCase()] ?? defaultScale;
}
