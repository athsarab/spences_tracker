import 'package:intl/intl.dart';

class LkrFormat {
  LkrFormat._();

  static final NumberFormat _fmt = NumberFormat.currency(
    locale: 'en_LK',
    symbol: 'LKR ',
    decimalDigits: 0,
  );

  static String money(num value) => _fmt.format(value);
}
