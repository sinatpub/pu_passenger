import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 17 — Contact Us.
///
/// The `tel:`/`mailto:` launches are kept exactly as they were (roadmap S2
/// Risk: "Contact rows keep the `callPhone`/`sendEmail` launches") — the spec's
/// "→ toast" is prototype behaviour, since a prototype cannot place a call.
/// The address is the company's real one, not the spec's placeholder.
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  static const String smartPhone = '+85570427213';
  static const String cellcardPhone = '+85512285048';
  static const String email = 'tarataxi24@gmail.com';
  static const String address =
      '#74, Street 192, Sangkat Teuk Laok 3, Toul Kork District, Phnom Penh';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TaIconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    semanticLabel: AppLocale.back.tr,
                    onTap: Get.back,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocale.contactUs.tr,
                      style: TaTextStyles.titleLarge.copyWith(fontSize: 17),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Center(child: ContactLogoBadge()),
              const SizedBox(height: 12),
              Text(
                AppLocale.taarraaPhnomPenh.tr,
                textAlign: TextAlign.center,
                style: TaTextStyles.bodySmall
                    .copyWith(color: TaColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TaProfileRow(
                icon: const Icon(Icons.phone_outlined, size: 20),
                label: 'Smart: +855 70 427 213',
                onTap: () => launchPhone(smartPhone),
              ),
              TaProfileRow(
                icon: const Icon(Icons.phone_outlined, size: 20),
                label: 'Cellcard: +855 12 285 048',
                onTap: () => launchPhone(cellcardPhone),
              ),
              TaProfileRow(
                icon: const Icon(Icons.mail_outline, size: 20),
                label: email,
                onTap: () => launchEmail(email),
              ),

              /// Not tappable — there is nothing to launch — so it carries no
              /// chevron either.
              const TaProfileRow(
                icon: Icon(Icons.place_outlined, size: 20),
                label: address,
                trailing: SizedBox.shrink(),
              ),
              const SizedBox(height: 18),
              Text(
                '© 2025 TAARRAA. All rights reserved.',
                textAlign: TextAlign.center,
                style: TaTextStyles.bodySmall
                    .copyWith(color: TaColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 72×72 brand badge (`03 §Screen 17`).
class ContactLogoBadge extends StatelessWidget {
  const ContactLogoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TaColors.primary, TaColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Icon(Icons.star, size: 36, color: Colors.white),
    );
  }
}

/// Unchanged from the screen this replaced.
Future<void> launchPhone(String phoneNumber) async {
  final uri = Uri.parse('tel:$phoneNumber');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    debugPrint('Could not launch $phoneNumber');
  }
}

Future<void> launchEmail(String address) async {
  final uri = Uri(scheme: 'mailto', path: address);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    debugPrint('Could not launch $address');
  }
}
