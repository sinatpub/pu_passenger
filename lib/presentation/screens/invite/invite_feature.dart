import 'package:com.tara.passenger/demo/demo_invite.dart';

/// Whether the invite QR, the invite code at sign-up, ride credit and the
/// rewards screen are reachable (D40, D41).
///
/// Always, since D41. The backend has none of the routes in
/// `ReferralDatasource` yet, so until it does they are answered with made-up
/// data (`demo/demo_invite.dart`). The QA mock backend answers them itself.
///
/// Kept as one getter so a server flag can take its place.
bool get inviteFeatureEnabled => true;

/// Whether ride credit can be put on a booking.
///
/// Not while the credit is made up: the real backend would ignore it, and
/// the driver would still be owed the whole fare in cash. The balance is
/// shown on Profile and in "Invite rewards" all the same.
bool get rideCreditUsable => !DemoInvite.isActive;
