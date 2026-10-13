import 'package:com.tara.passenger/mock/mock_mode.dart';

/// Whether the invite QR, the invite code at sign-up, ride credit and the
/// rewards screen are reachable (D40).
///
/// The backend has none of these routes yet, so the feature lives on the QA
/// mock backend only. Against the real API every entry point stays hidden:
/// a passenger never reaches a screen that can only fail. Replace this with
/// `true`, or a server flag, when the routes in `ReferralDatasource` exist.
bool get inviteFeatureEnabled => MockMode.isActive;
