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

  
  static String formatPercent(num amount) {
    final formatter = NumberFormat.decimalPercentPattern(locale: 'id', decimalDigits: 2);
    String raw = formatter.format(amount);
    final match = RegExp(r'^([\d.,]+)(%)$').firstMatch(raw);
    if (match == null) return raw;
    
    String number = match.group(1)!;
    String percent = match.group(2)!;
    number = number.replaceAll(RegExp(r'([.,]\d*?[1-9])0+$'), r'\1'); // 18,50 → 18,5
    number = number.replaceAll(RegExp(r'[.,]0+$'), ''); // 18,00 → 18
    return '$number$percent';
  }
}