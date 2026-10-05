import 'package:com.tara.passenger/data/models/request_booking_model.dart';

/// Screen 12 (Thank you) state — the finished trip, carried from the fare
/// page; the stars once the passenger gives them; and the seconds left
/// before the page returns home by itself. Nothing is fetched here.
class ReceiptState {
  ReceiptState({
    this.booking,
    this.stars,
    this.promptRating = false,
    required this.secondsLeft,
  });

  final Data? booking;

  /// Null until the passenger rates, and for good if they skip: the page
  /// then shows no rating row rather than inventing one.
  int? stars;

  /// Whether to open the rating dialog over the page (N-10's
  /// `shouldPromptForRating`, decided by the fare page).
  final bool promptRating;

  int secondsLeft;
}
