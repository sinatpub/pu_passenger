import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/money.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_presentation.dart';
import 'package:com.tara.passenger/presentation/screens/invite/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// "My invite QR" (D40): the QR and the code in one card, a share button,
/// what an invite earns, and one line on what it has earned so far.
///
/// Laid out as the driver app's "My QR" (DD-45), so the two apps show one
/// feature the same way. One QR for everyone: the same code invites a
/// passenger and a driver.
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
            : const _MyQrSkeleton();
      }
      return MyQrContent(
        referral: referral,
        onOpenRewards: () => Get.toNamed(AppRoutes.INVITE_REWARDS),
      );
    });
  }
}

class MyQrContent extends StatelessWidget {
  const MyQrContent({super.key, required this.referral, this.onOpenRewards});

  final ReferralModel referral;

  /// Opens "Invite rewards". The row is not a button without it.
  final VoidCallback? onOpenRewards;

  @override
  Widget build(BuildContext context) {
    final String? data = inviteQrData(referral);
    final String code = referral.code ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppLocale.myInviteQr.tr, style: TaTextStyles.headlineMedium),
        const SizedBox(height: 6),
        Text(
          AppLocale.myInviteQrHint.tr,
          style:
              TaTextStyles.bodyMedium.copyWith(color: TaColors.textSecondary),
        ),
        const SizedBox(height: 14),
        if (data != null) ...[
          InviteQrCard(
            data: data,
            code: code,
            onCopy: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (context.mounted) {
                TaToast.show(context, AppLocale.codeCopied.tr);
              }
            },
          ),
          const SizedBox(height: 12),
        ],
        TaButton(
          label: AppLocale.shareInvite.tr,
          icon: Icons.ios_share,
          width: double.infinity,
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
        const SizedBox(height: 12),
        InviteRules(referral: referral),
        const SizedBox(height: 12),
        InviteSummaryRow(
          summary: AppLocale.inviteSummary.trParams({
            'amount': formatMoney(totalEarned(referral.rewards)),
            'count': '${referral.invitees.length}',
          }),
          onTap: onOpenRewards,
        ),
      ],
    );
  }
}

/// The QR, and under a rule the code with a copy button.
class InviteQrCard extends StatelessWidget {
  const InviteQrCard({
    super.key,
    required this.data,
    required this.code,
    required this.onCopy,
  });

  /// What the QR holds: the invite link.
  final String data;
  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return _Outlined(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 6),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              image: true,
              label: AppLocale.myInviteQr.tr,
              excludeSemantics: true,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Always dark on white: a scanner needs the contrast.
                  QrImageView(
                    data: data,
                    size: 184,
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white,
                    // High: the mark in the middle covers some modules.
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        ImageAssets.brandMark,
                        width: 36,
                        height: 36,
                        // The file is 1024px; decode it near the size shown.
                        cacheWidth: 108,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(width: 36, height: 36),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Divider(height: 1, thickness: 1, color: TaColors.border),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocale.inviteCode.tr,
                        style: TaTextStyles.bodySmall
                            .copyWith(color: TaColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          code,
                          maxLines: 1,
                          style: TaTextStyles.headlineMedium
                              .copyWith(letterSpacing: 3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: code.isEmpty ? null : onCopy,
                tooltip: AppLocale.copyCode.tr,
                icon: const Icon(Icons.copy_rounded, size: 20),
                color: TaColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// What an invite earns, with the rates the server sent: one line per kind
/// of invited person, and what the reward is.
class InviteRules extends StatelessWidget {
  const InviteRules({super.key, required this.referral});

  final ReferralModel referral;

  @override
  Widget build(BuildContext context) {
    final List<(IconData, String)> rules = [
      if (referral.driverTopUpRate != null)
        (
          Icons.directions_car_outlined,
          AppLocale.inviteRuleDriver
              .trParams({'rate': _rate(referral.driverTopUpRate!)}),
        ),
      if (referral.passengerCommissionRate != null)
        (
          Icons.people_outline,
          AppLocale.inviteRulePassenger
              .trParams({'rate': _rate(referral.passengerCommissionRate!)}),
        ),
      (Icons.confirmation_number_outlined, AppLocale.inviteRuleCredit.tr),
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
          for (int i = 0; i < rules.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(rules[i].$1, size: 18, color: TaColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rules[i].$2,
                    style: TaTextStyles.bodyMedium
                        .copyWith(color: TaColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// `1` and `10`, not `1.0`; `2.5` stays.
  static String _rate(double rate) =>
      rate == rate.roundToDouble() ? rate.toInt().toString() : '$rate';
}

/// What the invites have earned, in one line at the foot of the sheet. It
/// opens "Invite rewards", the screen the Profile card opens too.
class InviteSummaryRow extends StatelessWidget {
  const InviteSummaryRow({super.key, required this.summary, this.onTap});

  /// "$2.07 earned · 2 invited".
  final String summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: _Outlined(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard,
                  size: 22, color: TaColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.inviteRewards.tr,
                      style: TaTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary,
                      style: TaTextStyles.bodySmall
                          .copyWith(color: TaColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right,
                    size: 20, color: TaColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// A white card with a hairline border: on the white sheet a shadow card
/// has nothing to stand out from.
class _Outlined extends StatelessWidget {
  const _Outlined({required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TaColors.border),
      ),
      child: child,
    );
  }
}

/// Loading placeholder with the sheet's shape: the QR card, the button, the
/// rewards row.
class _MyQrSkeleton extends StatelessWidget {
  const _MyQrSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TaSkeleton(height: 280, radius: 16),
        SizedBox(height: 12),
        TaSkeleton(height: 52, radius: 14),
        SizedBox(height: 12),
        TaSkeleton(height: 64, radius: 16),
      ],
    );
  }
}

/// The rewards could not be loaded and there is nothing older to show.
class InviteLoadError extends StatelessWidget {
  const InviteLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Full width: a bottom sheet is only as wide as what is in it, and this
    // is all there is in "My invite QR" when it cannot load.
    return Container(
      width: double.infinity,
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
