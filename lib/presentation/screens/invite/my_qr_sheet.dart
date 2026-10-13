import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/money.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_presentation.dart';
import 'package:com.tara.passenger/presentation/screens/invite/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// "My invite QR" (D40): the QR, the code to read out or copy, a share
/// button, what an invite earns and what it has earned so far.
///
/// One QR for everyone: the same code invites a passenger and a driver.
class MyQrSheet extends StatelessWidget {
  const MyQrSheet({super.key, required this.logic});

  final InviteLogic logic;

  static Future<void> show(BuildContext context) {
    final InviteLogic logic = Get.find<InviteLogic>();
    logic.fetch();
    return TaBottomSheet.show<void>(context, MyQrSheet(logic: logic));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ReferralModel? referral = logic.state.referral.value;
      if (referral == null) {
        return logic.state.failed.value
            ? InviteLoadError(onRetry: logic.fetch)
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: TaSkeleton(height: 220, radius: 16),
              );
      }
      return MyQrContent(referral: referral);
    });
  }
}

class MyQrContent extends StatelessWidget {
  const MyQrContent({super.key, required this.referral});

  final ReferralModel referral;

  @override
  Widget build(BuildContext context) {
    final String? data = inviteQrData(referral);
    final String code = referral.code ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocale.myInviteQr.tr,
          textAlign: TextAlign.center,
          style: TaTextStyles.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          AppLocale.myInviteQrHint.tr,
          textAlign: TextAlign.center,
          style: TaTextStyles.bodySmall.copyWith(color: TaColors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (data != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TaColors.border),
              ),
              // Always dark on white: a scanner needs the contrast.
              child: QrImageView(
                data: data,
                size: 196,
                semanticsLabel: AppLocale.myInviteQr.tr,
              ),
            ),
          ),
        const SizedBox(height: 14),
        Text(
          AppLocale.inviteCode.tr,
          textAlign: TextAlign.center,
          style: TaTextStyles.bodySmall.copyWith(color: TaColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          code,
          textAlign: TextAlign.center,
          style: TaTextStyles.displayLarge.copyWith(letterSpacing: 4),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TaButton(
                label: AppLocale.copyCode.tr,
                icon: Icons.copy,
                variant: TaButtonVariant.ghost,
                size: TaButtonSize.small,
                isEnabled: code.isNotEmpty,
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (context.mounted) {
                    TaToast.show(context, AppLocale.codeCopied.tr);
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TaButton(
                label: AppLocale.shareInvite.tr,
                icon: Icons.ios_share,
                variant: TaButtonVariant.dark,
                size: TaButtonSize.small,
                isEnabled: data != null,
                onTap: () => SharePlus.instance.share(
                  ShareParams(
                    text: AppLocale.shareInviteText.trParams({
                      'code': code,
                      'link': referral.link ?? '',
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InviteRules(referral: referral),
        const SizedBox(height: 12),
        Text(
          AppLocale.earnedSoFar.trParams(
            {'amount': formatMoney(totalEarned(referral.rewards))},
          ),
          textAlign: TextAlign.center,
          style: TaTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: TaColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// What an invite earns, with the rates the server sent.
class InviteRules extends StatelessWidget {
  const InviteRules({super.key, required this.referral});

  final ReferralModel referral;

  @override
  Widget build(BuildContext context) {
    final List<String> rules = [
      if (referral.driverTopUpRate != null)
        AppLocale.inviteRuleDriver
            .trParams({'rate': _rate(referral.driverTopUpRate!)}),
      if (referral.passengerCommissionRate != null)
        AppLocale.inviteRulePassenger
            .trParams({'rate': _rate(referral.passengerCommissionRate!)}),
      AppLocale.inviteRuleCredit.tr,
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaColors.primaryBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final String rule in rules)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: TaColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      rule,
                      style: TaTextStyles.bodySmall
                          .copyWith(color: TaColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// `1` and `10`, not `1.0`; `2.5` stays.
  static String _rate(double rate) =>
      rate == rate.roundToDouble() ? rate.toInt().toString() : '$rate';
}

/// The rewards could not be loaded and there is nothing older to show.
class InviteLoadError extends StatelessWidget {
  const InviteLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 32, color: TaColors.textMuted),
          const SizedBox(height: 10),
          Text(
            AppLocale.couldntLoadRewards.tr,
            textAlign: TextAlign.center,
            style:
                TaTextStyles.bodyMedium.copyWith(color: TaColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TaButton(
            label: AppLocale.retry.tr,
            variant: TaButtonVariant.ghost,
            size: TaButtonSize.small,
            width: 140,
            onTap: onRetry,
          ),
        ],
      ),
    );
  }
}
