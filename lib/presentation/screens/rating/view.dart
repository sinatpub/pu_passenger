import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The chip label for an N-10 tag.
///
/// Lives here, not in `rate_driver/rating.dart`: that module is the rules and
/// is reused read-only (roadmap C7 Scope), and it deliberately holds no copy.
String ratingTagLabel(RatingTag tag) {
  switch (tag) {
    case RatingTag.clean:
      return AppLocale.tagClean.tr;
    case RatingTag.onTime:
      return AppLocale.tagOnTime.tr;
    case RatingTag.friendly:
      return AppLocale.tagFriendly.tr;
    case RatingTag.goodRoute:
      return AppLocale.tagGoodRoute.tr;
  }
}

/// Screen 11 — Rating.
///
/// The star/tag/submit rules are N-10's (`rate_driver/rating.dart`): tags
/// appear only once a star is chosen, 4–5★ offer the positive set and 1–3★
/// offer none until negative tags are written, and Submit needs a star.
/// Skip is always available and costs nothing.
class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        child: GetBuilder<RatingLogic>(builder: (logic) {
          final state = logic.state;
          final name = state.driverName;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,

                  /// Skip is a plain, unemphasised exit — "a forced rating
                  /// produces noise, not data" (N-10).
                  child: TaButton(
                    label: AppLocale.skip.tr,
                    variant: TaButtonVariant.ghost,
                    size: TaButtonSize.small,
                    width: 96,
                    onTap: logic.skip,
                  ),
                ),
                const SizedBox(height: 8),
                TaAvatar(
                  variant: TaAvatarVariant.driver,
                  initials: initialsFromName(name),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocale.rateYourDriver.tr,
                  style: TaTextStyles.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                /// Display degrades: with no driver name the prompt drops the
                /// name rather than rendering "with ?" (N-10 `promptDriverName`).
                Text(
                  name == null
                      ? AppLocale.howWasYourTrip.tr
                      : '${AppLocale.howWasYourTripWith.tr} $name?',
                  style: TaTextStyles.bodyMedium
                      .copyWith(color: TaColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                TaStarRating(
                  rating: state.draft.stars ?? 0,
                  onChanged: logic.setStars,
                ),
                const SizedBox(height: 16),
                _tags(logic),
                const SizedBox(height: 16),
                TaNoteField(
                  controller: state.noteController,
                  hint: AppLocale.addNoteForDriver.tr,
                ),
                const Spacer(),
                _pendingBackendNotice(),
                const SizedBox(height: 10),
                TaButton(
                  label: AppLocale.submit.tr,
                  isEnabled: state.canSubmit,
                  onTap: logic.submit,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _tags(RatingLogic logic) {
    final offered = logic.state.offeredTags;

    /// Nothing before a star, and nothing at 1–3★: N-10 names no negative
    /// tags, and the wording of a complaint about a driver is not invented
    /// here. A low rating simply offers a shorter screen.
    if (offered.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final tag in offered)
          TaChip(
            label: ratingTagLabel(tag),
            isSelected: logic.state.draft.tags.contains(tag),
            onTap: () => logic.toggleTag(tag),
          ),
      ],
    );
  }

  /// `PDD-02` — there is no rating endpoint. The passenger is told plainly
  /// rather than shown a submit that silently goes nowhere.
  Widget _pendingBackendNotice() {
    return Text(
      AppLocale.ratingPendingBackend.tr,
      style: TaTextStyles.bodySmall.copyWith(color: TaColors.textMuted),
      textAlign: TextAlign.center,
    );
  }
}
