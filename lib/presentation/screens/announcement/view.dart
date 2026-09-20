import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/announcement_cell_data.dart';
import 'package:com.tara.passenger/core/utils/x_paged_child_builder_delegate.dart';
import 'package:com.tara.passenger/data/models/announcement_model.dart';
import 'package:com.tara.passenger/presentation/screens/announcement/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 18 — Announcements.
///
/// `AnnouncementLogic` and `announcement_api.dart` are read-only (roadmap S3):
/// the paging controller, P-13's `pageNo` fix and the detail arguments are all
/// untouched. This re-skins the list and gives it the states it never had.
class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<AnnouncementLogic>();

    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  TaIconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    semanticLabel: AppLocale.back.tr,
                    onTap: Get.back,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocale.announcement.tr,
                      style: TaTextStyles.titleLarge.copyWith(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Obx(
                () => RefreshIndicator(
                  color: TaColors.primary,
                  onRefresh: () async {
                    HapticFeedback.mediumImpact();
                    logic.state.announcementPagingController.value.refresh();
                  },
                  child: PagedListView<int, AnnouncementDetailModel>(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    pagingController:
                        logic.state.announcementPagingController.value,
                    builderDelegate: XPagedChildBuilderDelegate.list(
                      /// Roadmap S3 Done When — "the list has a true empty
                      /// state". It previously fell through to the shared
                      /// delegate's default, so an account with no
                      /// announcements and a failed fetch looked identical.
                      noItemsFoundIndicatorBuilder: (context) =>
                          const AnnouncementEmptyState(),
                      firstPageErrorIndicatorBuilder: (context) =>
                          AnnouncementErrorState(
                        onRetry: logic
                            .state.announcementPagingController.value.refresh,
                      ),
                      firstPageProgressIndicatorBuilder: (context) =>
                          const Column(
                        children: [
                          TaSkeletonCard(children: [TaSkeleton(height: 64)]),
                          SizedBox(height: 10),
                          TaSkeletonCard(children: [TaSkeleton(height: 64)]),
                          SizedBox(height: 10),
                          TaSkeletonCard(children: [TaSkeleton(height: 64)]),
                        ],
                      ),
                      newPageProgressIndicatorBuilder: (context) =>
                          const Padding(
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
                      itemBuilder: (context, item, index) =>
                          AnnouncementCard(item: item),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Title, excerpt and date (`03 §Screen 18`). The whole card is the tap
/// target, and it passes the **same `{"id": ...}` argument** the inner
/// `InkWell` passed before, so the detail screen and the FCM deep link keep
/// working unchanged.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.item});

  final AnnouncementDetailModel? item;

  @override
  Widget build(BuildContext context) {
    final excerpt = announcementExcerpt(item?.description);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TaPressable(
        onTap: () => Get.toNamed(
          AppRoutes.ANNOUNCEMENTDETAIL,
          arguments: {'id': item?.id},
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TaColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: TaShadows.shadowMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcementTitle(item?.title),
                style: TaTextStyles.titleMedium,
              ),

              /// Dropped rather than printing "Unknown" under every title
              /// when an announcement carries no body.
              if (excerpt != null) ...[
                const SizedBox(height: 4),
                Text(
                  excerpt,
                  style: TaTextStyles.bodyMedium
                      .copyWith(color: TaColors.textSecondary),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                announcementDate(item?.createdAt),
                style: TaTextStyles.bodySmall
                    .copyWith(color: TaColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnnouncementEmptyState extends StatelessWidget {
  const AnnouncementEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: EmptyData(message: AppLocale.noAnnouncements.tr),
    );
  }
}

class AnnouncementErrorState extends StatelessWidget {
  const AnnouncementErrorState({super.key, required this.onRetry});

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
            AppLocale.couldNotLoadAnnouncements.tr,
            textAlign: TextAlign.center,
            style: TaTextStyles.bodyMedium
                .copyWith(color: TaColors.textSecondary),
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
