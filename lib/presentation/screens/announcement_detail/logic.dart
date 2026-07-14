import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:get/get.dart';

import '../../../data/datasources/announcement_api.dart';
import 'state.dart';

class AnnouncementDetailLogic extends GetxController {
  final AnnouncementDetailState state = AnnouncementDetailState();

  @override
  void onInit() {
    var arg = Get.arguments;
    if (arg != null) {
      state.announcementID = arg["id"];
    }
    super.onInit();
  }

  @override
  onReady() async {
    await getAnnouncementDetail();
    super.onReady();
  }

  Future<void> getAnnouncementDetail() async {
    try {
      var result = await AnnouncementRepo()
          .getAnnouncementById(state.announcementID ?? 0);
      state.data = result;
      update();
    } catch (e) {
      xPrettyLog(message: "Get Announcement Detail Fail: $e");
    }
  }
}
