import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Audit S-7 — Screen 9's sheet when the ride could not be loaded and there
/// is nothing from before to show. Same frame as `BookingSheet`, so the map
/// above does not jump when the ride arrives; Retry asks again at once, and
/// the screen's poll keeps asking regardless.
class RideLoadErrorSheet extends StatelessWidget {
  const RideLoadErrorSheet({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: TaShadows.shadowLg,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(20.d),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 40, color: TaColors.textMuted),
              const SizedBox(height: 12),
              Text(
                AppLocale.somethingWentWrong.tr,
                textAlign: TextAlign.center,
                style: TaTextStyles.titleLarge
                    .copyWith(color: TaColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocale.bookingFailedBody.tr,
                textAlign: TextAlign.center,
                style: TaTextStyles.bodyMedium
                    .copyWith(color: TaColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TaButton(
                label: AppLocale.retry.tr,
                onTap: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
