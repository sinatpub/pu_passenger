import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The terms, in order. Unchanged wording — this is legal copy, so S2
/// re-skins how it is presented and does not touch what it says.
const List<String> kTermsAndConditions = [
  'All payments are made directly to the driver and are accepted in cash or with QR code.',
  'The company and its member drivers cannot be held responsible for any actual or consequential financial or professional loss due to the late or non-arrival of any rickshaw or cab.',
  'The company cannot be held responsible for losses consequential from missed connections due to adverse weather or any other events.',
  'The company and its member drivers reserve the right to refuse to carry passengers who are deeply under the influence of alcohol or drugs.',
  'All bookings accepted by the company will be bound by these terms and conditions.',
];

/// Screen 16 — Terms & Conditions.
class TermConditionPage extends StatelessWidget {
  const TermConditionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                      AppLocale.termNCondition.tr,
                      style: TaTextStyles.titleLarge.copyWith(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: kTermsAndConditions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => TermRow(
                  number: index + 1,
                  text: kTermsAndConditions[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermRow extends StatelessWidget {
  const TermRow({super.key, required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: TaShadows.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: TaColors.primaryBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: TaColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TaTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w400,
                color: TaColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
