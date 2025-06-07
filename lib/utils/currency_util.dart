import 'package:intl/intl.dart';

class CurrencyUtil {
  static const double usdToIdr = 15500;
  static const double usdToEur = 0.92;
  static const double usdToYen = 157.0;

  static double convert(double usd, String region) {
    if (region == 'indo') return usd * usdToIdr;
    if (region == 'europe') return usd * usdToEur;
    if (region == 'japan') return usd * usdToYen;
    return usd;
  }

  static double convertToUSD(double amount, String region) {
    if (region == 'indo') return amount / usdToIdr;
    if (region == 'europe') return amount / usdToEur;
    if (region == 'japan') return amount / usdToYen;
    return amount;
  }

  static String format(double value, String region) {
    if (region == 'indo' || region == 'japan') {
      final formatter = NumberFormat('#,###', 'id_ID');
      final formatted = formatter.format(value);
      return region == 'indo'
          ? 'Rp $formatted'
          : '¥$formatted';
    } else if (region == 'europe') {
      final formatter = NumberFormat('#,###.00', 'en_US');
      final formatted = formatter.format(value);
      return '€$formatted';
    } else {
      final formatter = NumberFormat('#,###.00', 'en_US');
      final formatted = formatter.format(value);
      return '\$$formatted';
    }
  }
} 