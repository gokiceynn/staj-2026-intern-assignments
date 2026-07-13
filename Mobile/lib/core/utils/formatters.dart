import 'package:intl/intl.dart';

/// tr_TR yereline göre para ve tarih biçimlendirme.
abstract final class Formatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static final DateFormat _date = DateFormat('d MMMM y', 'tr_TR');
  static final DateFormat _dateTime = DateFormat('d MMMM y, HH:mm', 'tr_TR');

  /// 1299.9 → "₺1.299,90"
  static String price(num value) => _currency.format(value);

  static String date(DateTime value) => _date.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);
}
