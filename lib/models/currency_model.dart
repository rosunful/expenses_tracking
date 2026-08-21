
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
  CurrencyModel( countryName: 'United Arab Emirates',code: 'AED', symbol: 'د.إ', ),
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
  CurrencyModel(countryName: 'Afghanistan', code: 'AFN', symbol: '؋'),
  CurrencyModel(countryName: 'Albania', code: 'ALL', symbol: 'L'),
  CurrencyModel(countryName: 'Algeria', code: 'DZD', symbol: 'دج'),
  CurrencyModel(countryName: 'Angola', code: 'AOA', symbol: 'Kz'),
  CurrencyModel(countryName: 'Armenia', code: 'AMD', symbol: '֏'),
  CurrencyModel(countryName: 'Azerbaijan', code: 'AZN', symbol: '₼'),
  CurrencyModel(countryName: 'Bahamas', code: 'BSD', symbol: 'B\$'),
  CurrencyModel(countryName: 'Bahrain', code: 'BHD', symbol: '.د.ب'),
  CurrencyModel(countryName: 'Barbados', code: 'BBD', symbol: 'Bds\$'),
  CurrencyModel(countryName: 'Belarus', code: 'BYN', symbol: 'Br'),
  CurrencyModel(countryName: 'Belize', code: 'BZD', symbol: 'BZ\$'),
  CurrencyModel(countryName: 'Bermuda', code: 'BMD', symbol: '\$'),
  CurrencyModel(countryName: 'Bolivia', code: 'BOB', symbol: 'Bs.'),
  CurrencyModel(countryName: 'Bosnia and Herzegovina',code: 'BAM', symbol: 'KM',),
  CurrencyModel(countryName: 'Botswana', code: 'BWP', symbol: 'P'),
  CurrencyModel(countryName: 'Bulgaria', code: 'BGN', symbol: 'лв'),
  CurrencyModel(countryName: 'Cambodia', code: 'KHR', symbol: '៛'),
  CurrencyModel(countryName: 'Chile', code: 'CLP', symbol: '\$'),
  CurrencyModel(countryName: 'Colombia', code: 'COP', symbol: '\$'),
  CurrencyModel(countryName: 'Costa Rica', code: 'CRC', symbol: '₡'),
  CurrencyModel(countryName: 'Croatia', code: 'HRK', symbol: 'kn'),
  CurrencyModel(countryName: 'Cuba', code: 'CUP', symbol: '₱'),
  CurrencyModel(countryName: 'Czech Republic', code: 'CZK', symbol: 'Kč'),
  CurrencyModel(countryName: 'Dominican Republic', code: 'DOP', symbol: 'RD\$'),
  CurrencyModel(countryName: 'Ecuador', code: 'USD', symbol: '\$'),
  CurrencyModel(countryName: 'El Salvador', code: 'USD', symbol: '\$'),
  CurrencyModel(countryName: 'Estonia', code: 'EUR', symbol: '€'),
  CurrencyModel(countryName: 'Ethiopia', code: 'ETB', symbol: 'Br'),
  CurrencyModel(countryName: 'Fiji', code: 'FJD', symbol: 'FJ\$'),
  CurrencyModel(countryName: 'Georgia', code: 'GEL', symbol: '₾'),
  CurrencyModel(countryName: 'Ghana', code: 'GHS', symbol: '₵'),
  CurrencyModel(countryName: 'Guatemala', code: 'GTQ', symbol: 'Q'),
  CurrencyModel(countryName: 'Honduras', code: 'HNL', symbol: 'L'),
  CurrencyModel(countryName: 'Hungary', code: 'HUF', symbol: 'Ft'),
  CurrencyModel(countryName: 'Iceland', code: 'ISK', symbol: 'kr'),
  CurrencyModel(countryName: 'Iran', code: 'IRR', symbol: '﷼'),
  CurrencyModel(countryName: 'Iraq', code: 'IQD', symbol: 'ع.د'),
  CurrencyModel(countryName: 'Jamaica', code: 'JMD', symbol: 'J\$'),
  CurrencyModel(countryName: 'Jordan', code: 'JOD', symbol: 'د.ا'),
  CurrencyModel(countryName: 'Kazakhstan', code: 'KZT', symbol: '₸'),
  CurrencyModel(countryName: 'Kuwait', code: 'KWD', symbol: 'د.ك'),
  CurrencyModel(countryName: 'Kyrgyzstan', code: 'KGS', symbol: 'лв'),
  CurrencyModel(countryName: 'Laos', code: 'LAK', symbol: '₭'),
  CurrencyModel(countryName: 'Lebanon', code: 'LBP', symbol: 'ل.ل'),
  CurrencyModel(countryName: 'Libya', code: 'LYD', symbol: 'ل.د'),
  CurrencyModel(countryName: 'Macau', code: 'MOP', symbol: 'MOP\$'),
  CurrencyModel(countryName: 'Madagascar', code: 'MGA', symbol: 'Ar'),
  CurrencyModel(countryName: 'Malawi', code: 'MWK', symbol: 'MK'),
  CurrencyModel(countryName: 'Maldives', code: 'MVR', symbol: 'Rf'),
  CurrencyModel(countryName: 'Mauritius', code: 'MUR', symbol: '₨'),
  CurrencyModel(countryName: 'Moldova', code: 'MDL', symbol: 'L'),
  CurrencyModel(countryName: 'Mongolia', code: 'MNT', symbol: '₮'),
  CurrencyModel(countryName: 'Morocco', code: 'MAD', symbol: 'د.م.'),
  CurrencyModel(countryName: 'Mozambique', code: 'MZN', symbol: 'MT'),
  CurrencyModel(countryName: 'Myanmar', code: 'MMK', symbol: 'K'),
  CurrencyModel(countryName: 'Namibia', code: 'NAD', symbol: 'N\$'),
  CurrencyModel(countryName: 'Nicaragua', code: 'NIO', symbol: 'C\$'),
  CurrencyModel(countryName: 'Oman', code: 'OMR', symbol: 'ر.ع.'),
  CurrencyModel(countryName: 'Panama', code: 'PAB', symbol: 'B/.'),
  CurrencyModel(countryName: 'Paraguay', code: 'PYG', symbol: '₲'),
  CurrencyModel(countryName: 'Peru', code: 'PEN', symbol: 'S/.'),
  CurrencyModel(countryName: 'Qatar', code: 'QAR', symbol: 'ر.ق'),
  CurrencyModel(countryName: 'Romania', code: 'RON', symbol: 'lei'),
  CurrencyModel(countryName: 'Rwanda', code: 'RWF', symbol: 'FRw'),
  CurrencyModel(countryName: 'Serbia', code: 'RSD', symbol: 'дин.'),
  CurrencyModel(countryName: 'Somalia', code: 'SOS', symbol: 'S'),
  CurrencyModel(countryName: 'Sudan', code: 'SDG', symbol: 'ج.س.'),
  CurrencyModel(countryName: 'Syria', code: 'SYP', symbol: '£S'),
  CurrencyModel(countryName: 'Taiwan', code: 'TWD', symbol: 'NT\$'),
  CurrencyModel(countryName: 'Tajikistan', code: 'TJS', symbol: 'SM'),
  CurrencyModel(countryName: 'Tanzania', code: 'TZS', symbol: 'TSh'),
  CurrencyModel( countryName: 'Trinidad and Tobago',code: 'TTD',symbol: 'TT\$', ),
  CurrencyModel(countryName: 'Tunisia', code: 'TND', symbol: 'د.ت'),
  CurrencyModel(countryName: 'Turkmenistan', code: 'TMT', symbol: 'T'),
  CurrencyModel(countryName: 'Uganda', code: 'UGX', symbol: 'USh'),
  CurrencyModel(countryName: 'Ukraine', code: 'UAH', symbol: '₴'),
  CurrencyModel(countryName: 'Uruguay', code: 'UYU', symbol: '\$U'),
  CurrencyModel(countryName: 'Uzbekistan', code: 'UZS', symbol: 'лв'),
  CurrencyModel(countryName: 'Venezuela', code: 'VES', symbol: 'Bs.'),
  CurrencyModel(countryName: 'Yemen', code: 'YER', symbol: '﷼'),
  CurrencyModel(countryName: 'Zambia', code: 'ZMW', symbol: 'ZK'),
  CurrencyModel(countryName: 'Zimbabwe', code: 'ZWL', symbol: 'Z\$'),


];

const CurrencyModel defaultCurrency = CurrencyModel(
  countryName: 'United States',
  code: 'USD',
  symbol: '\$',
);

/// Looks up a currency by its stored code — this is what lets a
/// transaction show the currency it was actually saved in, rather than
/// whatever the app's CURRENT setting happens to be.
CurrencyModel currencyForCode(String code) {
  final match = supportedCurrencies.where((c) => c.code == code);
  return match.isNotEmpty ? match.first : defaultCurrency;
}







