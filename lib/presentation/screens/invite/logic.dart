import 'package:get/get.dart';

import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/repository/referral_repository.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_feature.dart';

import 'state.dart';

/// The passenger's invite code, ride credit and rewards (D40).
///
/// App-lifetime, registered once in `app/service.dart`: the QR sheet on Home,
/// the card on Profile, the rewards screen and the booking sheet all read the
/// same answer. Nothing is fetched while the feature is off.
class InviteLogic extends GetxController {
  InviteLogic(
    this._repository, {
    bool Function()? enabled,
    bool Function()? creditUsable,
  })  : _enabled = enabled ?? (() => inviteFeatureEnabled),
        _creditUsable = creditUsable ?? (() => rideCreditUsable);

  final ReferralRepository _repository;
  final bool Function() _enabled;
  final bool Function() _creditUsable;

  final InviteState state = InviteState();

  /// Ride credit the passenger can use now. Zero until it is known.
  double get creditBalance => state.referral.value?.rewardBalance ?? 0;

  /// The part of [creditBalance] a booking may ask for. None while the
  /// balance is made up (D41): it is shown, but it cannot pay a driver.
  double get usableCredit {
    // Read first: the booking sheet's `Obx` must have a value to watch even
    // when the answer is "none".
    final double balance = creditBalance;
    return _creditUsable() ? balance : 0;
  }

  /// A failed refresh keeps what was on screen: stale credit is better than
  /// a blank card, and the server checks the amount again anyway.
  Future<void> fetch() async {
    if (!_enabled() || state.isLoading.value) return;
    state.isLoading.value = true;
    try {
      final result = await _repository.referral();
      result.when(
        ok: (ReferralModel data) {
          state.referral.value = data;
          state.failed.value = false;
        },
        err: (_) => state.failed.value = state.referral.value == null,
      );
    } finally {
      state.isLoading.value = false;
    }
  }

  /// A sign-out: the next passenger must not see this one's credit.
  void clear() {
    state.referral.value = null;
    state.failed.value = false;
  }
}
