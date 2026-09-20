import 'package:flutter/widgets.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';

/// Screen 11 (Rating) state.
///
/// The choosing rules live in `rate_driver/rating.dart` (N-10) and are reused
/// read-only: this holds the current [RatingDraft] and the trip it belongs to,
/// and delegates every "what may be selected" question to that module.
class RatingState {
  RatingState({this.booking});

  /// The trip being rated, carried from the fee screen.
  final Data? booking;

  RatingDraft draft = const RatingDraft();

  final TextEditingController noteController = TextEditingController();

  /// `Submit` needs a star; everything else is optional (N-10 `canSubmit`).
  bool get canSubmit => draft.canSubmit;

  /// The tags offered at the current star count — none before a star is
  /// chosen, and none at 1–3★ until negative tags are written.
  List<RatingTag> get offeredTags => draft.offeredTags;

  String? get driverName => promptDriverName(booking?.driver?.name);
}
