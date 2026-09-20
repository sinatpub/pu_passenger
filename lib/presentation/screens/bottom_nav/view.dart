import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/presentation/screens/bottom_nav/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class BottomNav extends StatelessWidget {
  BottomNav({super.key});

  final BottomNavController logic = Get.find<BottomNavController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => logic.pages[logic.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => TaBottomNav(
          currentIndex: logic.selectedIndex.value,
          onChanged: logic.changePage,
          items: [
            TaNavItem(
              label: AppLocale.home.tr,
              activeIcon: _navIcon('assets/nav_icon/home-angle-2-svgrepo-com.svg', true),
              inactiveIcon: _navIcon('assets/nav_icon/home.svg', false),
            ),
            TaNavItem(
              label: AppLocale.myBooking.tr,
              activeIcon: _navIcon('assets/nav_icon/book.svg', true),
              inactiveIcon: _navIcon('assets/nav_icon/book_outline.svg', false),
            ),
            TaNavItem(
              label: AppLocale.profile.tr,
              activeIcon: _navIcon('assets/nav_icon/profile_fill.svg', true),
              inactiveIcon: _navIcon('assets/nav_icon/profile.svg', false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(String asset, bool active) {
    return SvgPicture.asset(
      asset,
      width: 22,
      height: 22,
      colorFilter: active
          ? const ColorFilter.mode(TaColors.primary, BlendMode.srcIn)
          : null,
    );
  }
}