import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
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

/// Opens Screen 11 — Rating — as a dialog over the Thank you page.
///
/// Completes with the passenger's [RatingDraft] on Submit, and with null
/// when they skip, back out, or the dialog is closed for them. Every one of
/// those nulls is a skip; the caller records it.
///
/// [onInteraction] fires each time the passenger touches the rating, so the
/// page underneath can hold off returning home while they are still choosing.
Future<RatingDraft?> showRatingDialog(
  BuildContext context, {
  required String? driverName,
  VoidCallback? onInteraction,
}) {
  return TaDialog.showCustom<RatingDraft>(
    context,
    label: AppLocale.rateYourDriver.tr,
    builder: (context) => RatingDialog(
      driverName: driverName,
      onInteraction: onInteraction,
    ),
  );
}

/// The rating prompt's content. The star/tag/submit rules are N-10's
/// (`rate_driver/rating.dart`): tags appear only once a star is chosen, 4–5★
/// offer the positive set and 1–3★ offer none until negative tags are
/// written, and Submit needs a star. Skip is always available and costs
/// nothing.
class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, required this.driverName, this.onInteraction});

  final String? driverName;
  final VoidCallback? onInteraction;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  RatingDraft _draft = const RatingDraft();

  void _setStars(int value) {
    // N-10 drops tags the new count no longer offers, so a passenger who
    // picked 5★ + "Clean" and then chose 2★ cannot submit praise they chose
    // for a different answer.
    setState(() => _draft = _draft.withStars(value));
    widget.onInteraction?.call();
  }

  void _toggle(RatingTag tag) {
    setState(() => _draft = _draft.toggle(tag));
    widget.onInteraction?.call();
  }

  @override
  Widget build(BuildContext context) {
    final name = promptDriverName(widget.driverName);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: TaColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TaAvatar(
                  variant: TaAvatarVariant.driver,
                  initials: initialsFromName(name),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocale.rateYourDriver.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: TaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                /// Display degrades: with no driver name the prompt drops the
                /// name rather than rendering "with ?" (N-10
                /// `promptDriverName`).
                Text(
                  name == null
                      ? AppLocale.howWasYourTrip.tr
                      : '${AppLocale.howWasYourTripWith.tr} $name?',
                  textAlign: TextAlign.center,
                  style: TaTextStyles.bodyMedium
                      .copyWith(color: TaColors.textSecondary),
                ),
                const SizedBox(height: 16),
                // Five 44px stars are wider than a narrow phone's dialog.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TaStarRating(
                    rating: _draft.stars ?? 0,
                    onChanged: _setStars,
                  ),
                ),
                _tags(),
                const SizedBox(height: 14),

                /// `PDD-02` — there is no rating endpoint. The passenger is
                /// told plainly rather than shown a submit that silently
                /// goes nowhere.
                Text(
                  AppLocale.ratingPendingBackend.tr,
                  textAlign: TextAlign.center,
                  style:
                      TaTextStyles.bodySmall.copyWith(color: TaColors.textMuted),
                ),
                const SizedBox(height: 14),
                TaButton(
                  label: AppLocale.submit.tr,
                  width: double.infinity,
                  isEnabled: _draft.canSubmit,
                  onTap: () => Navigator.of(context).pop(_draft),
                ),

                /// Skip is a plain, unemphasised exit — "a forced rating
                /// produces noise, not data" (N-10).
                Semantics(
                  button: true,
                  child: TaPressable(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      child: Text(
                        AppLocale.skip.tr,
                        style: TaTextStyles.labelLarge
                            .copyWith(color: TaColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tags() {
    final offered = _draft.offeredTags;

    /// Nothing before a star, and nothing at 1–3★: N-10 names no negative
    /// tags, and the wording of a complaint about a driver is not invented
    /// here. A low rating simply offers a shorter dialog.
    if (offered.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (final tag in offered)
            TaChip(
              label: ratingTagLabel(tag),
              isSelected: _draft.tags.contains(tag),
              onTap: () => _toggle(tag),
            ),
        ],
      ),
    );
  }
}
