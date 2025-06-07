import 'package:intl/intl.dart';

class TimezoneUtil {
  static String formatAllTimezones(DateTime dateTime) {
    // Asumsikan dateTime dalam UTC
    final utc = dateTime.toUtc();
    final wib = utc.add(const Duration(hours: 7));
    final wita = utc.add(const Duration(hours: 8));
    final wit = utc.add(const Duration(hours: 9));
    final df = DateFormat('dd MMM yyyy, HH:mm');
    return '${df.format(wib)} WIB\n'
           '${df.format(wita)} WITA\n'
           '${df.format(wit)} WIT\n'
           '${df.format(utc)} UTC';
  }
} 