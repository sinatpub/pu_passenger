import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/history_cell_data.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/core/utils/money.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_presentation.dart';
import 'package:com.tara.passenger/presentation/screens/invite/logic.dart';
import 'package:com.tara.passenger/presentation/screens/invite/my_qr_sheet.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// "Invite rewards" (D40, option 2a), opened from the ride credit card on
/// Profile: the credit, then what was earned and who was invited.
class InviteRewardsPage extends StatefulWidget {
  const InviteRewardsPage({super.key});

  @override
  State<InviteRewardsPage> createState() => _InviteRewardsPageState();
}

class _InviteRewardsPageState extends State<InviteRewardsPage> {
  final InviteLogic logic = Get.find<InviteLogic>();
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    logic.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  TaIconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    semanticLabel: AppLocale.back.tr,
                    onTap: Get.back,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocale.inviteRewards.tr,
                      style: TaTextStyles.titleLarge.copyWith(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: logic.fetch,
                child: Obx(() {
                  final ReferralModel? referral = logic.state.referral.value;
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    children: referral == null
                        ? [
                            if (logic.state.failed.value)
                              InviteLoadError(onRetry: logic.fetch)
                            else
                              const TaSkeleton(height: 132, radius: 16),
                          ]
                        : [
                            RideCreditSummary(referral: referral),
                            const SizedBox(height: 12),
                            TaButton(
                              label: AppLocale.showMyQr.tr,
                              icon: Icons.qr_code_2,
                              variant: TaButtonVariant.dark,
                              onTap: () => MyQrSheet.show(context),
                            ),
                            const SizedBox(height: 16),
                            TaSegment(
                              options: [
                                AppLocale.rewardsTab.tr,
                                AppLocale.peopleTab.tr,
                              ],
                              selectedIndex: _tab,
                              expanded: true,
                              onChanged: (int i) => setState(() => _tab = i),
                            ),
                            const SizedBox(height: 12),
                            if (_tab == 0)
                              ...rewardRows(referral)
                            else
                              ...peopleRows(referral),
                          ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The credit the passenger can use, with what was earned and used.
class RideCreditSummary extends StatelessWidget {
  const RideCreditSummary({super.key, required this.referral});

  final ReferralModel referral;

  @override
  Widget build(BuildContext context) {
    return TaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocale.rideCredit.tr,
            style:
                TaTextStyles.bodySmall.copyWith(color: TaColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            formatMoney(referral.rewardBalance ?? 0),
            style: TaTextStyles.displayLarge,
          ),
          const SizedBox(height: 10),
          const Divider(color: TaColors.border, height: 1),
          TaKVRow(
            label: AppLocale.totalEarnedLabel.tr,
            value: formatMoney(totalEarned(referral.rewards)),
          ),
          TaKVRow(
            label: AppLocale.usedOnTrips.tr,
            value: formatMoney(totalUsed(referral.uses)),
          ),
        ],
      ),
    );
  }
}

/// One line of the Rewards tab: money in from a person, or out on a trip.
class _Entry {
  const _Entry({
    required this.title,
    required this.amount,
    required this.at,
    required this.isUse,
  });

  final String title;
  final double amount;
  final String? at;
  final bool isUse;
}

/// Rewards and uses in one list, newest first. Dates sort as text: they are
/// `yyyy-MM-dd HH:mm:ss`.
List<Widget> rewardRows(ReferralModel referral) {
  final List<_Entry> entries = <_Entry>[
    for (final ReferralReward r in referral.rewards)
      _Entry(
        title: AppLocale.rewardFromName
            .trParams({'name': r.inviteeName ?? AppLocale.unKnown.tr}),
        amount: r.amount ?? 0,
        at: r.createdAt,
        isUse: false,
      ),
    for (final CreditUse u in referral.uses)
      _Entry(
        title: AppLocale.usedOnATrip.tr,
        amount: u.amount ?? 0,
        at: u.createdAt,
        isUse: true,
      ),
  ]..sort((a, b) => (b.at ?? '').compareTo(a.at ?? ''));

  if (entries.isEmpty) {
    return [
      _Empty(
        title: AppLocale.noRewardsYet.tr,
        message: AppLocale.noRewardsHint.tr,
      ),
    ];
  }
  return [
    for (final _Entry e in entries)
      _Row(
        icon: e.isUse ? Icons.local_taxi_outlined : Icons.card_giftcard,
        title: e.title,
        subtitle: historyCardDate(e.at),
        trailing: '${e.isUse ? '−' : '+'}${formatMoney(e.amount)}',
        trailingColor: e.isUse ? TaColors.textPrimary : TaColors.success,
      ),
  ];
}

List<Widget> peopleRows(ReferralModel referral) {
  if (referral.invitees.isEmpty) {
    return [
      _Empty(
        title: AppLocale.noPeopleYet.tr,
        message: AppLocale.noRewardsHint.tr,
      ),
    ];
  }
  return [
    for (final Invitee person in referral.invitees)
      _Row(
        initials: initialsFromName(person.name),
        title: person.name ?? AppLocale.unKnown.tr,
        subtitle: switch (InviteeRole.of(person.role)) {
          InviteeRole.driver => AppLocale.driver.tr,
          InviteeRole.passenger => AppLocale.passenger.tr,
          InviteeRole.unknown => historyCardDate(person.joinedAt),
        },
        trailing: AppLocale.earnedFromPerson
            .trParams({'amount': formatMoney(person.earned ?? 0)}),
        trailingColor: TaColors.textSecondary,
      ),
  ];
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.trailingColor,
    this.icon,
    this.initials,
  });

  final IconData? icon;
  final String? initials;
  final String title;
  final String subtitle;
  final String trailing;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return TaCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: TaColors.primaryBg,
              shape: BoxShape.circle,
            ),
            child: icon != null
                ? Icon(icon, size: 20, color: TaColors.primary)
                : Text(
                    initials ?? '',
                    style: TaTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: TaColors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TaTextStyles.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TaTextStyles.bodySmall
                      .copyWith(color: TaColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            trailing,
            style: TaTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: trailingColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard, size: 36, color: TaColors.textMuted),
          const SizedBox(height: 10),
          Text(title, style: TaTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                TaTextStyles.bodySmall.copyWith(color: TaColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
