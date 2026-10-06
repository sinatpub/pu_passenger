import 'package:intl/intl.dart';

/// The one way the app writes an amount: US dollars with cents — `$0.30`,
/// `$1,234.50`.
///
/// The backend prices in dollar decimals (`"0.30"` per km, `"0.50"` minimum
/// fare), which settled `PDD-01` in favour of `D15`. Every amount on screen
/// goes through here, so the currency cannot differ between the vehicle
/// list, the booking sheet, the fare page, the receipt and the history.
String formatMoney(num amount) => _dollars.format(amount);

/// [amount] to the cent. An estimate multiplies a distance by a rate, and
/// the result has more digits than money does.
double roundToCents(num amount) => (amount * 100).roundToDouble() / 100;

final NumberFormat _dollars =
    NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: 2);
