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
      function: _repo.getAllAnnouncement(),
      isRefresh: isRefresh,
      pageNo: pageNo,
    );
  }
}
