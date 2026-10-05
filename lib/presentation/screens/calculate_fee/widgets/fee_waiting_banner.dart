import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/motion.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The fare page's status: the passenger has nothing to press, the driver
/// confirms the payment. A pulsing dot says the page is still listening.
///
/// The same message for every payment method — what "paying" means for each
/// is the backend's to say, and it does not.
class FeeWaitingBanner extends StatefulWidget {
  const FeeWaitingBanner({super.key});

  @override
  State<FeeWaitingBanner> createState() => _FeeWaitingBannerState();
}

class _FeeWaitingBannerState extends State<FeeWaitingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: Motion.ambient,
  );

  /// `TaColors.warning` on `warningBg` is 3.3:1 — too faint for a sentence
  /// the passenger has to read. This darker amber is 6.3:1.
  static const Color _text = Color(0xFF7A5200);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // P1 — the pulse holds still when the viewer has asked the OS to remove
    // animations.
    applyAmbientMotion(context, _pulse);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TaColors.warningBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0.3).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: TaColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocale.waitPaymentDriver.tr,
              style: TaTextStyles.labelLarge.copyWith(color: _text),
            ),
          ),
        ],
      ),
    );
  }
}
