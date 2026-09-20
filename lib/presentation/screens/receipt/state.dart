import 'package:com.tara.passenger/data/models/request_booking_model.dart';

/// Screen 12 (Receipt) state — the finished trip and the stars just given,
/// both carried from the rating screen. Nothing is fetched here.
class ReceiptState {
  ReceiptState({this.booking, this.stars});

  final Data? booking;

  /// Null when the passenger skipped: the receipt then shows no rating row
  /// rather than inventing one.
  final int? stars;
}
