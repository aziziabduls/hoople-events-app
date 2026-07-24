import 'package:intl/intl.dart';

String formatNumber(int number) {
  if (number >= 1000000) {
    double result = number / 1000000;
    return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}M';
  } else if (number >= 1000) {
    double result = number / 1000;
    return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}K';
  } else {
    return number.toString();
  }
}

String formatNumberIDR(int number) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(number);
}
