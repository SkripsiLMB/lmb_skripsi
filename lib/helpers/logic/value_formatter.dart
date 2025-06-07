import 'package:intl/intl.dart';

class ValueFormatter {
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].length < 2) return email;

    final name = parts[0];
    final domain = parts[1];

    final maskedName = name[0] + '*' * (name.length - 2) + name[name.length - 1];

    return '$maskedName@$domain';
  }

  static String formatPriceIDR(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}