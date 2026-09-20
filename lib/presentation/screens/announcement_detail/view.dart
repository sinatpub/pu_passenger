import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/announcement_cell_data.dart';
import 'package:com.tara.passenger/data/models/announcement_model.dart';
import 'package:com.tara.passenger/presentation/screens/announcement_detail/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/presentation/widgets/x_network_image.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 19 — Announcement Detail.
///
/// `AnnouncementDetailLogic` is read-only (roadmap S3), including the
/// `Get.arguments["id"]` read that the FCM deep link depends on — this only
/// re-skins what it renders.
class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: GetBuilder<AnnouncementDetailLogic>(
                builder: (logic) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: logic.state.data == null
                      ? const AnnouncementDetailSkeleton()
                      : AnnouncementDetailCard(data: logic.state.data!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown until the fetch lands.
///
/// **Known limitation (S3):** `AnnouncementDetailLogic.getAnnouncementDetail`
/// swallows its error and never calls `update()` on failure, so a failed fetch
/// is indistinguishable from a slow one and this skeleton stays up. Surfacing
/// a real error needs a flag on the controller, which S3 holds read-only —
/// recorded in `IMPLEMENTATION_PROGRESS.md` rather than worked around here.
class AnnouncementDetailSkeleton extends StatelessWidget {
  const AnnouncementDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaSkeletonCard(
      children: [
        TaSkeleton(height: 22),
        SizedBox(height: 10),
        TaSkeleton(height: 12, width: 140),
        SizedBox(height: 14),
        TaSkeleton(height: 96),
      ],
    );
  }
}

/// Title, date, body and any attached images (`03 §Screen 19`).
class AnnouncementDetailCard extends StatelessWidget {
  const AnnouncementDetailCard({super.key, required this.data});

  final AnnouncementDetailModel data;

  @override
  Widget build(BuildContext context) {
    final body = announcementBody(data.description);
    final images = announcementImageUrls(data.files);

    return TaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            announcementTitle(data.title),
            style: TaTextStyles.titleLarge.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            announcementDate(data.createdAt),
            style: TaTextStyles.bodySmall.copyWith(color: TaColors.textMuted),
          ),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(
              body,
              style: TaTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: TaColors.textSecondary,
              ),
            ),
          ],

          /// The spec draws a gradient placeholder here. Real announcements
          /// carry real attachments, so the existing image strip is kept —
          /// a placeholder would be a downgrade.
          if (images.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: XNetworkImage(
                    src: images[index],
                    fit: BoxFit.cover,
                    height: 120,
                    errorWidget: const AnnouncementImageFallback(),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Stands in for an attachment that will not load.
class AnnouncementImageFallback extends StatelessWidget {
  const AnnouncementImageFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TaColors.primaryBorder, Color(0xFFD8E6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.notifications_none,
        size: 28,
        color: TaColors.primary,
      ),
    );
  }
}
