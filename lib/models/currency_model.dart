/// A country paired with its currency code and display symbol.
/// Deliberately a plain data class — no Firestore serialization needed
/// here, since only the `code` gets persisted (see CurrencyRepository);
/// the full model is looked up from this static list by code.
class CurrencyModel {
  final String countryName;
  final String code; // e.g. "USD", "NPR"
  final String symbol; // e.g. "$", "Rs."

  const CurrencyModel({
    required this.countryName,
    required this.code,
    required this.symbol,
  });
}

/// A curated set of common currencies. Not every country on Earth —
/// extend this list if you need one that's missing.
const List<CurrencyModel> supportedCurrencies = [
  CurrencyModel(countryName: 'United States', code: 'USD', symbol: '\$'),
  CurrencyModel(countryName: 'Nepal', code: 'NPR', symbol: 'Rs.'),
  CurrencyModel(countryName: 'India', code: 'INR', symbol: '₹'),
  CurrencyModel(countryName: 'United Kingdom', code: 'GBP', symbol: '£'),
  CurrencyModel(countryName: 'European Union', code: 'EUR', symbol: '€'),
  CurrencyModel(countryName: 'Japan', code: 'JPY', symbol: '¥'),
  CurrencyModel(countryName: 'China', code: 'CNY', symbol: '¥'),
  CurrencyModel(countryName: 'Australia', code: 'AUD', symbol: 'A\$'),
  CurrencyModel(countryName: 'Canada', code: 'CAD', symbol: 'C\$'),
  CurrencyModel(countryName: 'Switzerland', code: 'CHF', symbol: 'Fr.'),
  CurrencyModel(countryName: 'South Korea', code: 'KRW', symbol: '₩'),
  CurrencyModel(countryName: 'Singapore', code: 'SGD', symbol: 'S\$'),
  CurrencyModel(countryName: 'New Zealand', code: 'NZD', symbol: 'NZ\$'),
  CurrencyModel(countryName: 'Pakistan', code: 'PKR', symbol: 'Rs.'),
  CurrencyModel(countryName: 'Bangladesh', code: 'BDT', symbol: '৳'),
  CurrencyModel(countryName: 'Sri Lanka', code: 'LKR', symbol: 'Rs.'),
  CurrencyModel(countryName: 'United Arab Emirates', code: 'AED', symbol: 'د.إ'),
  CurrencyModel(countryName: 'Saudi Arabia', code: 'SAR', symbol: '﷼'),
  CurrencyModel(countryName: 'South Africa', code: 'ZAR', symbol: 'R'),
  CurrencyModel(countryName: 'Brazil', code: 'BRL', symbol: 'R\$'),
  CurrencyModel(countryName: 'Mexico', code: 'MXN', symbol: '\$'),
  CurrencyModel(countryName: 'Russia', code: 'RUB', symbol: '₽'),
  CurrencyModel(countryName: 'Indonesia', code: 'IDR', symbol: 'Rp'),
  CurrencyModel(countryName: 'Malaysia', code: 'MYR', symbol: 'RM'),
  CurrencyModel(countryName: 'Thailand', code: 'THB', symbol: '฿'),
  CurrencyModel(countryName: 'Philippines', code: 'PHP', symbol: '₱'),
  CurrencyModel(countryName: 'Vietnam', code: 'VND', symbol: '₫'),
  CurrencyModel(countryName: 'Turkey', code: 'TRY', symbol: '₺'),
  CurrencyModel(countryName: 'Egypt', code: 'EGP', symbol: 'E£'),
  CurrencyModel(countryName: 'Nigeria', code: 'NGN', symbol: '₦'),
  CurrencyModel(countryName: 'Kenya', code: 'KES', symbol: 'KSh'),
  CurrencyModel(countryName: 'Sweden', code: 'SEK', symbol: 'kr'),
  CurrencyModel(countryName: 'Norway', code: 'NOK', symbol: 'kr'),
  CurrencyModel(countryName: 'Denmark', code: 'DKK', symbol: 'kr'),
  CurrencyModel(countryName: 'Poland', code: 'PLN', symbol: 'zł'),
  CurrencyModel(countryName: 'Hong Kong', code: 'HKD', symbol: 'HK\$'),
  CurrencyModel(countryName: 'Israel', code: 'ILS', symbol: '₪'),
  CurrencyModel(countryName: 'Argentina', code: 'ARS', symbol: '\$'),
];

const CurrencyModel defaultCurrency = CurrencyModel(
  countryName: 'United States',
  code: 'USD',
  symbol: '\$',
);