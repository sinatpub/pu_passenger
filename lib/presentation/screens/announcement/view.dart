import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/data/models/announcement_model.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/utils/app_ext.dart';
import '../../../core/utils/x_paged_child_builder_delegate.dart';
import '../../../translations/app_locale.dart';
import 'logic.dart';
import 'state.dart';

class AnnouncementPage extends StatelessWidget {
  AnnouncementPage({super.key});

  final AnnouncementLogic logic = Get.find<AnnouncementLogic>();
  final AnnouncementState state = Get.find<AnnouncementLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.announcement.tr),
        centerTitle: true,
      ),
      body: Obx(
        () => Container(
          color: Colors.grey.withOpacity(.1),
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              logic.state.announcementPagingController.value.refresh();
            },
            child: PagedListView<int, AnnouncementDetailModel>.separated(
              padding: EdgeInsets.only(top: 18.0, left: 18.d, right: 18.d),
              pagingController: logic.state.announcementPagingController.value,
              builderDelegate: XPagedChildBuilderDelegate.list(
                  newPageProgressIndicatorBuilder: (context) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                  itemBuilder: (context, item, index) {
                    return _announcementCard(item);
                  }),
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 18.d,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _announcementCard(AnnouncementDetailModel item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.d, vertical: 8.d),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.d),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.ANNOUNCEMENTDETAIL, arguments: {"id": item.id});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title ?? AppLocale.unKnown.tr,
              style: ThemeConstands.font14SemiBold,
            ),
            Text(
              item.description ?? AppLocale.unKnown.tr,
              style: ThemeConstands.font12Regular,
            ),
            SizedBox(
              height: 4.d,
            ),
            Text(
              item.createdAt != null
                  ? DateTime.parse("${item.createdAt}").formatDateTime()
                  : AppLocale.unKnown.tr,
              style: ThemeConstands.font12Regular,
            ),
          ],
        ),
      ),
    );
  }
}
