import 'package:com.tara.passenger/demo/demo_invite.dart';
import 'package:com.tara.passenger/mock/mock_mode.dart';

/// Whether the invite QR, the invite code at sign-up, ride credit and the
/// rewards screen are reachable (D40, D41, D47).
///
/// The backend has none of the routes in `ReferralDatasource` yet. D41 showed
/// the feature in every build, answered with made-up data
/// (`demo/demo_invite.dart`); the QA mock backend answers it itself. D47:
/// only where one of those answers. A release build has neither unless it
/// asks for `DEMO_INVITE=true`, so a store build shows no invite at all —
/// not made-up figures, and not screens that can only fail.
///
/// Kept as one getter so a server flag can take its place.
bool get inviteFeatureEnabled => DemoInvite.isActive || MockMode.isActive;

/// Whether ride credit can be put on a booking.
///
/// Not while the credit is made up: the real backend would ignore it, and
/// the driver would still be owed the whole fare in cash. The balance is
/// shown on Profile and in "Invite rewards" all the same.
bool get rideCreditUsable => !DemoInvite.isActive;
