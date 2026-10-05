import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Top bar over the map (Screen 7 §Map): just the back button, at the start
/// edge. The old "My Location" pill is gone — the my-location button on the
/// map does that job.
///
/// A plain row; the screen places it over the map inside the safe area.
class MapAppbar extends StatelessWidget {
  const MapAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TaIconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          semanticLabel: AppLocale.back.tr,
          color: TaColors.textPrimary,
          onTap: () => Get.back(),
        ),
      ],
    );
  }
}
