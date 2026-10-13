import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/money.dart';
import 'package:com.tara.passenger/presentation/screens/invite/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The ride credit card on Profile (D40): the balance, and the way into the
/// rewards screen. A passenger has no wallet, so this is where credit lives.
class RideCreditCard extends StatelessWidget {
  const RideCreditCard({super.key, required this.logic});

  final InviteLogic logic;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool known = logic.state.referral.value != null;
      return TaCard(
        onTap: () => Get.toNamed(AppRoutes.INVITE_REWARDS),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: TaColors.primaryBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.confirmation_number_outlined,
                  size: 20, color: TaColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocale.rideCredit.tr,
                    style: TaTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocale.rideCreditCardSub.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TaTextStyles.bodySmall
                        .copyWith(color: TaColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (known)
              Text(
                formatMoney(logic.creditBalance),
                style: TaTextStyles.titleLarge,
              )
            else
              const TaSkeleton(width: 48, height: 18),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 20, color: TaColors.textMuted),
          ],
        ),
      );
    });
  }
}
