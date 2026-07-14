import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/presentation/screens/history/logic.dart';
import 'package:com.tara.passenger/presentation/screens/history/widgets/cancelled_tab.dart';
import 'package:com.tara.passenger/presentation/screens/history/widgets/completed_tab.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final HistoryLogic logic = Get.put(HistoryLogic(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          AppLocale.ridingHistory.tr,
          style: ThemeConstands.font22SemiBold.copyWith(color: AppColors.dark1),
        ),
        bottom: TabBar(
          controller: logic.tabController,
          indicatorColor: AppColors.main,
          dividerColor: Colors.transparent,
          labelColor: AppColors.main,
          unselectedLabelColor: AppColors.dark1,
          labelStyle: ThemeConstands.font16SemiBold,
          tabs: [
            Tab(text: AppLocale.completed.tr),
            Tab(text: AppLocale.cancelled.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: logic.tabController,
        children: [
          CompletedTabWidget(),
          CancelledTabWidget(),
        ],
      ),
    );
  }
}
