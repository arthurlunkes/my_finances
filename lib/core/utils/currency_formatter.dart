import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String format(double value) {
    return _currencyFormat.format(value);
  }

  static String formatWithSign(double value) {
    final formatted = format(value.abs());
    return value >= 0 ? '+ $formatted' : '- $formatted';
  }

  static double parse(String value) {
    try {
      // Remove símbolos de moeda e espaços
      String cleanValue = value
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();

      return double.parse(cleanValue);
    } catch (e) {
      return 0.0;
    }
  }

  static String formatCompact(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}K';
    }
    return format(value);
  }
}
