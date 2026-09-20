import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Top bar over the map (Screen 7 §Map): back `TaIconButton` + a "My
/// Location" pill signalling which region the map is showing.
class MapAppbar extends StatelessWidget {
  const MapAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top + 10.d,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.d),
        child: Row(
          children: [
            TaIconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              semanticLabel: AppLocale.back.tr,
              color: TaColors.primary,
              onTap: () => Get.back(),
            ),
            SizedBox(width: 10.d),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.d, vertical: 10.d),
                    decoration: BoxDecoration(
                      color: TaColors.surface,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: TaShadows.shadowMd,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.my_location,
                          size: 16,
                          color: TaColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            AppLocale.myLocation.tr,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: TaColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 42.d),
          ],
        ),
      ),
    );
  }
}