import 'package:com.tara.passenger/presentation/screens/bottom_nav/logic.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNav extends StatelessWidget {
  BottomNav({super.key});

  final BottomNavController logic = Get.find<BottomNavController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => logic.pages[logic.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: logic.selectedIndex.value,
          onTap: logic.changePage,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocale.home.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.event),
              label: AppLocale.myBooking.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person,),
              label: AppLocale.profile.tr,
            ),
          ],
        ),
      ),
    );
  }
}
