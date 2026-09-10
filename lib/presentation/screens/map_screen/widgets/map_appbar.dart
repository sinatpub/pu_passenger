import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/app_ext.dart';
import '../../../../translations/app_locale.dart';

class MapAppbar extends StatelessWidget {
  const MapAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top + 10.d,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.d),
        child: Row(
          children: [
            InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(10.d),
                decoration: BoxDecoration(
                  color: Colors.white, // White looks cleaner on maps
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new, // More modern icon
                  color: AppColors.main,
                  size: 20,
                ),
              ),
            ),

            SizedBox(width: 16.d),

            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.d, horizontal: 20.d),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.9), // Slight transparency
                  borderRadius: BorderRadius.circular(15),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    AppLocale.myLocation.tr,
                    style: ThemeConstands.font14SemiBold.copyWith(
                      color: AppColors.main,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Empty space to balance the back button (Optional)
            SizedBox(width: 44.d),
          ],
        ),
      ),
    );
  }
}
