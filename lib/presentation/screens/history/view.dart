import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/presentation/screens/history/logic.dart';
import 'package:com.tara.passenger/presentation/screens/history/widgets/history_tab.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 13 — History.
///
/// The Material `AppBar` + `TabBar` is replaced by the plain header and the
/// `TaSegment` pill the spec calls for. The `TabController` stays the source
/// of truth for which tab is active — `HistoryLogic.switchTabBarController`
/// (which swaps the filter and refreshes the paging controller) is driven by
/// its listener exactly as before, so the segment only has to move the
/// controller's index.
class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final HistoryLogic logic = Get.put(HistoryLogic(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocale.ridingHistory.tr,
                    style: TaTextStyles.titleLarge.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 14),

                  /// Rebuilt on tab change so the pill follows swipes through
                  /// the `TabBarView` as well as taps on the segment itself.
                  AnimatedBuilder(
                    animation: logic.tabController,
                    builder: (context, _) => TaSegment(
                      options: [
                        AppLocale.completed.tr,
                        AppLocale.cancelled.tr,
                      ],
                      selectedIndex: logic.tabController.index,
                      onChanged: (index) =>
                          logic.tabController.animateTo(index),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: logic.tabController,
                children: const [
                  HistoryTab(isCompleted: true),
                  HistoryTab(isCompleted: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
