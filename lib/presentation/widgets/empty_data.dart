import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Empty state (roadmap F3 re-skin).
///
/// Centered muted icon + message per the empty-state spec. `size` is kept
/// for call-site compatibility (reserved for a future illustration).
class EmptyData extends StatelessWidget {
  const EmptyData(
      {super.key, this.size, this.message, this.isNeedShowFullScreen = false});
  final double? size;
  final String? message;
  final bool isNeedShowFullScreen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isNeedShowFullScreen ? Get.height * 0.85 : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: TaColors.primaryBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 32,
              color: TaColors.primaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message ?? AppLocale.noResultFound.tr,
            textAlign: TextAlign.center,
            style: TaTextStyles.bodyMedium.copyWith(color: TaColors.textSecondary),
          ),
        ],
      ),
    );
  }
}