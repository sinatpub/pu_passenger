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
  InviteLogic(this._repository, {bool Function()? enabled})
      : _enabled = enabled ?? (() => inviteFeatureEnabled);

  final ReferralRepository _repository;
  final bool Function() _enabled;

  final InviteState state = InviteState();

  /// Ride credit the passenger can use now. Zero until it is known.
  double get creditBalance => state.referral.value?.rewardBalance ?? 0;

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
