import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/history_cell_data.dart';
import 'package:com.tara.passenger/core/utils/x_paged_child_builder_delegate.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/history/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// One history tab (`03 §Screen 13`).
///
/// Replaces `completed_tab.dart` and `cancelled_tab.dart`, which were
/// byte-for-byte the same list apart from a stray `withOpacity(.1)` /
/// `withAlpha(10)` difference in a background colour that the redesign drops
/// anyway. Both tabs read the *same* paging controller — the filter is
/// switched by `HistoryLogic.switchTabBarController`, which is untouched — so
/// duplicating the widget only risked the two drifting.
///
/// [isCompleted] selects the empty-state copy, which is the only thing that
/// actually differs between the tabs.
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<HistoryLogic>();

    return Obx(
      () => RefreshIndicator(
        color: TaColors.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          logic.state.propertyPagingController.value.refresh();
        },
        child: PagedListView<int, Datum>(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
          pagingController: logic.state.propertyPagingController.value,
          builderDelegate: XPagedChildBuilderDelegate.list(
            /// Roadmap S1 Done When — both tabs get real empty and error
            /// states. The list previously fell through to the shared
            /// delegate's defaults, so an empty account and a failed fetch
            /// looked the same.
            noItemsFoundIndicatorBuilder: (context) => HistoryEmptyState(
              isCompleted: isCompleted,
            ),
            firstPageErrorIndicatorBuilder: (context) => HistoryErrorState(
              onRetry: logic.state.propertyPagingController.value.refresh,
            ),
            firstPageProgressIndicatorBuilder: (context) => const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  TaSkeletonCard(children: [TaSkeleton(height: 96)]),
                  SizedBox(height: 12),
                  TaSkeletonCard(children: [TaSkeleton(height: 96)]),
                  SizedBox(height: 12),
                  TaSkeletonCard(children: [TaSkeleton(height: 96)]),
                ],
              ),
            ),
            newPageProgressIndicatorBuilder: (context) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: TaColors.primary,
                  ),
                ),
              ),
            ),
            noMoreItemsIndicatorBuilder: (context) => Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  AppLocale.noMoreData.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TaColors.textMuted,
                  ),
                ),
              ),
            ),
            itemBuilder: (context, item, index) => HistoryRow(data: item),
          ),
        ),
      ),
    );
  }
}

/// A single card. Tapping anywhere on it opens the detail screen with the
/// **same argument the old inner `InkWell` passed** — the `Datum` itself
/// (roadmap S1: "identical arguments and formatters").
class HistoryRow extends StatelessWidget {
  const HistoryRow({super.key, required this.data});

  final Datum? data;

  @override
  Widget build(BuildContext context) {
    return TaHistoryCard(
      item: historyCellData(data),
      isCompleted: isCompletedHistory(data?.status),
      statusLabel: historyStatusLabel(data?.status),
      onTap: () => Get.toNamed(AppRoutes.HISTORYDETAIL, arguments: data),
    );
  }
}

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key, required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: EmptyData(
        message: isCompleted
            ? AppLocale.noCompletedTrips.tr
            : AppLocale.noCancelledTrips.tr,
      ),
    );
  }
}

class HistoryErrorState extends StatelessWidget {
  const HistoryErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 40, color: TaColors.textMuted),
          const SizedBox(height: 12),
          Text(
            AppLocale.couldNotLoadHistory.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: TaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          TaButton(
            label: AppLocale.retry.tr,
            variant: TaButtonVariant.ghost,
            size: TaButtonSize.small,
            width: 140,
            onTap: onRetry,
          ),
        ],
      ),
    );
  }
}
