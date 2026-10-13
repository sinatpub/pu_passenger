import 'package:get/get.dart';

import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';

class InviteState {
  /// Null until the first answer.
  final Rx<ReferralModel?> referral = Rx<ReferralModel?>(null);
  final RxBool isLoading = false.obs;

  /// The last fetch failed and there is nothing older to show.
  final RxBool failed = false.obs;
}
