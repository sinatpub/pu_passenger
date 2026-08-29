import 'package:get/get.dart';

import '../../../core/utils/x_paging_data_handler.dart';
import '../../../data/datasources/announcement_api.dart';
import 'state.dart';

class AnnouncementLogic extends GetxController {
  final AnnouncementState state = AnnouncementState();
  final AnnouncementRepo _repo = Get.find<AnnouncementRepo>();

  @override
  onInit() {
    super.onInit();
    state.announcementPagingController.value.addPageRequestListener((pageNo) {
      getAllAnnouncementPaging(pageNo: pageNo);
    });
  }

  Future<void> getAllAnnouncementPaging(
      {required int pageNo,
      bool isRefresh = false,
      String? search,
      int? pptTypeId}) async {
    if (isRefresh) {
      state.announcementPagingController.value.refresh();
    }

    await xPagingDataHandler(
      pagingController: state.announcementPagingController.value,
      // P-13 — was called with no pageNo, so every "page" the paging
      // controller requested silently re-fetched page 1 forever.
      function: _repo.getAllAnnouncement(pageNo: pageNo),
      isRefresh: isRefresh,
      pageNo: pageNo,
    );
  }
}
